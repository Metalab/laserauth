import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gpiod/flutter_gpiod.dart';
import 'package:laserauth/cubit/configuration_state.dart';
import 'package:laserauth/hardware.dart';
import 'package:laserauth/log.dart';
import 'package:laserauth/price.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({required this.configuration})
      : hardware = Hardware(configuration),
        super(const LoggedOut()) {
    hardware.laserSenseStream.listen(_laserSenseChanged);
  }

  @override
  Future<void> close() {
    hardware.dispose();
    return super.close();
  }

  final Configuration configuration;
  final Hardware hardware;

  Future<void> login({required Uint8List iButtonId, required String name}) async {
    try {
      emit(LoggedIn(
        iButtonId: iButtonId,
        name: name,
      ));
      hardware.power = true;
    } on Error catch (e) {
      log.severe(e.toString(), e, e.stackTrace);
    }
  }

  void loginMember({required String memberName}) {
    switch (state) {
      case LoggedIn(:final iButtonId, :final laserDuration, :final laserTubeTurnOnTimestamp, :final name):
        log.info('Switch to member');
        emit(LoggedInMember(
          iButtonId: iButtonId,
          name: name,
          memberName: memberName,
          laserDuration: laserDuration,
          laserTubeTurnOnTimestamp: laserTubeTurnOnTimestamp,
        ));
      case LoggedOut():
      // Nothing to do
    }
  }

  void loginExtern() {
    switch (state) {
      case LoggedIn(:final iButtonId, :final name, :final laserDuration, :final laserTubeTurnOnTimestamp):
        log.info('Switch to extern');
        emit(LoggedInExtern(
          iButtonId: iButtonId,
          name: name,
          laserDuration: laserDuration,
          laserTubeTurnOnTimestamp: laserTubeTurnOnTimestamp,
        ));
      case LoggedOut():
      // nothing to do
    }
  }

  void logout() {
    switch (state) {
      case LoggedInExtern(:final name, :final laserDuration):
        log.info(ThingEvent(
          kind: EventKind.usageNonmember,
          user: name,
          usageSeconds: laserDuration.inSeconds,
        ));
        log.info(ThingEvent(kind: EventKind.logout, user: name));
        emit(LoggedOut(
          lastCosts: centsForLaserTime(laserDuration, extern: true, configuration: configuration),
          lastName: name,
        ));
      case LoggedInMember(:final name, :final laserDuration):
        log.info(ThingEvent(
          kind: EventKind.usageMember,
          user: name,
          usageSeconds: laserDuration.inSeconds,
        ));
        log.info(ThingEvent(kind: EventKind.logout, user: name));
        emit(LoggedOut(
          lastCosts: centsForLaserTime(laserDuration, extern: false, configuration: configuration),
          lastName: name,
        ));
      case LoggedIn(:final name):
        emit(LoggedOut(
          lastCosts: 0,
          lastName: name,
        ));
      case LoggedOut():
      // nothing to do
    }
    hardware.power = false;
  }

  void _laserSenseChanged(SignalEvent event) {
    final state = this.state; // avoid having to cast this after the type check every time
    if (state is LoggedIn) {
      if (event.edge == SignalEdge.falling && state.laserTubeTurnOnTimestamp != null) {
        emit(state.copyWith(
          laserDuration: state.laserDuration + (event.timestamp - state.laserTubeTurnOnTimestamp!),
          laserTubeTurnOnTimestamp: null,
        ));
      } else if (event.edge == SignalEdge.rising && state.laserTubeTurnOnTimestamp == null) {
        emit(state.copyWith(
          laserDuration: state.laserDuration,
          laserTubeTurnOnTimestamp: event.timestamp,
        ));
      }
    }
  }
}
