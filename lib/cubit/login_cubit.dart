import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gpiod/flutter_gpiod.dart';
import 'package:laserauth/config.dart';
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

  final Configuration configuration;
  final Hardware hardware;

  Future<void> login({required Uint8List iButtonId, required String name}) async {
    try {
      emit(LoggedIn(
        iButtonId: iButtonId,
        name: name,
        loginTime: DateTime.now().toUtc(),
      ));
      hardware.power = true;
    } on Error catch (e) {
      log.e(e.toString(), stackTrace: e.stackTrace);
    }
  }

  void setExtern({required bool extern}) {
    switch (state) {
      case LoggedIn(
          :final iButtonId,
          :final name,
          :final laserDuration,
          :final loginTime,
          :final laserTubeTurnOnTimestamp
        ):
        log.i('Switch to extern');
        emit(LoggedIn(
          iButtonId: iButtonId,
          name: name,
          laserDuration: laserDuration,
          extern: extern,
          loginTime: loginTime,
          laserTubeTurnOnTimestamp: laserTubeTurnOnTimestamp,
        ));
      case LoggedOut():
      case ConnectionFailed():
      // nothing to do
    }
  }

  void logout() {
    switch (state) {
      case LoggedIn(:final name, :final laserDuration, :final extern):
        log.i('Logout $name with $laserDuration (extern $extern)');
        emit(LoggedOut(
          lastCosts: centsForLaserTime(laserDuration, extern: extern, configuration: configuration),
          lastName: name,
        ));
      case LoggedOut():
      // nothing to do
      case ConnectionFailed():
      // nothing to do
    }
    hardware.power = false;
  }

  void _laserSenseChanged(SignalEvent event) {
    final state = this.state; // avoid having to cast this after the type check every time
    if (state is LoggedIn) {
      if (event.edge == SignalEdge.falling && state.laserTubeTurnOnTimestamp != null) {
        emit(LoggedIn(
          iButtonId: state.iButtonId,
          name: state.name,
          loginTime: state.loginTime,
          laserDuration: state.laserDuration + (event.timestamp - state.laserTubeTurnOnTimestamp!),
          laserTubeTurnOnTimestamp: null,
          extern: state.extern,
        ));
      } else if (event.edge == SignalEdge.rising && state.laserTubeTurnOnTimestamp == null) {
        emit(LoggedIn(
          iButtonId: state.iButtonId,
          name: state.name,
          loginTime: state.loginTime,
          laserDuration: state.laserDuration,
          laserTubeTurnOnTimestamp: event.timestamp,
          extern: state.extern,
        ));
      }
    }
  }
}
