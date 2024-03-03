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
    _updateServerTimer?.cancel();
    _updateServerTimer = null;
    _loginIdleTimer?.cancel();
    _loginIdleTimer = null;
    return super.close();
  }

  final Configuration configuration;
  final Hardware hardware;
  Timer? _updateServerTimer;
  Timer? _loginIdleTimer;

  void _resetIdleTimer() {
    _loginIdleTimer?.cancel();
    _loginIdleTimer ??= Timer(Duration(minutes: configuration.idleLogoutMinutes), logout);
  }

  Future<void> login({required Uint8List iButtonId, required String name}) async {
    try {
      emit(LoggedIn(
        iButtonId: iButtonId,
        name: name,
      ));
      log.info(ThingEvent(kind: EventKind.login, user: name));
      hardware.power = true;
      _resetIdleTimer();
    } on Error catch (e) {
      log.severe(e.toString(), e, e.stackTrace);
    }
  }

  void loginMemberInput() {
    switch (state) {
      case LoggedIn(:final iButtonId, :final name):
        log.info('Switch to member input');
        _resetIdleTimer();
        emit(LoggedInMemberInput(
          iButtonId: iButtonId,
          name: name,
        ));
      case LoggedOut():
      // Nothing to do
    }
  }

  void loginMember({required String memberName}) {
    switch (state) {
      case LoggedIn(
          :final iButtonId,
          :final laserDuration,
          :final laserTubeTurnOnTimestamp,
          :final laserTubeTurnOnTime,
          :final name
        ):
        log.info('Switch to member');
        _resetIdleTimer();
        emit(LoggedInMember(
          iButtonId: iButtonId,
          name: name,
          memberName: memberName,
          laserDuration: laserDuration,
          laserTubeTurnOnTimestamp: laserTubeTurnOnTimestamp,
          laserTubeTurnOnTime: laserTubeTurnOnTime,
        ));
      case LoggedOut():
      // Nothing to do
    }
  }

  void loginExtern() {
    switch (state) {
      case LoggedIn(
          :final iButtonId,
          :final name,
          :final laserDuration,
          :final laserTubeTurnOnTimestamp,
          :final laserTubeTurnOnTime
        ):
        log.info('Switch to extern');
        _resetIdleTimer();
        emit(LoggedInExtern(
          iButtonId: iButtonId,
          name: name,
          laserDuration: laserDuration,
          laserTubeTurnOnTimestamp: laserTubeTurnOnTimestamp,
          laserTubeTurnOnTime: laserTubeTurnOnTime,
        ));
      case LoggedOut():
      // nothing to do
    }
  }

  void logout() {
    _loginIdleTimer?.cancel();
    _loginIdleTimer = null;

    switch (state) {
      case LoggedInExtern(:final name, :var laserDuration, :final laserTubeTurnOnTime, :final serverSubmittedDuration):
        if (laserTubeTurnOnTime != null) {
          laserDuration = DateTime.now().difference(laserTubeTurnOnTime);
        }
        log.info(ThingEvent(
          kind: EventKind.usageNonmember,
          user: name,
          usageSeconds: (laserDuration - serverSubmittedDuration).inSeconds,
        ));
        log.info(ThingEvent(kind: EventKind.logout, user: name));
        emit(LoggedOut(
          lastCosts: centsForLaserTime(laserDuration, extern: true, configuration: configuration),
          lastName: name,
        ));
      case LoggedInMember(:final name, :var laserDuration, :final laserTubeTurnOnTime, :final serverSubmittedDuration):
        if (laserTubeTurnOnTime != null) {
          laserDuration = DateTime.now().difference(laserTubeTurnOnTime);
        }
        log.info(ThingEvent(
          kind: EventKind.usageMember,
          user: name,
          usageSeconds: (laserDuration - serverSubmittedDuration).inSeconds,
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

  void _updateServerTime(Timer timer) {
    if (_loginIdleTimer != null) {
      _resetIdleTimer();
    }

    final state = this.state; // avoid having to cast this after the type check every time
    if (state is LoggedInExtern || state is LoggedInMember) {
      final duration = (state as LoggedIn).laserDuration - state.serverSubmittedDuration;
      if (duration > const Duration(seconds: 1)) {
        if (state is LoggedInMember) {
          log.info(ThingEvent(
            kind: EventKind.usageMember,
            user: state.memberName,
            usageSeconds: duration.inSeconds,
          ));
        } else if (state is LoggedInExtern) {
          log.info(ThingEvent(
            kind: EventKind.usageNonmember,
            user: state.name,
            usageSeconds: duration.inSeconds,
          ));
        }
        emit(state.copyWith(serverSubmittedDuration: state.laserDuration));
      }
    }
  }

  void _laserSenseChanged(SignalEvent event) {
    log.fine('Laser sense changed: $event');
    if (_loginIdleTimer != null) {
      _resetIdleTimer();
    }

    final state = this.state; // avoid having to cast this after the type check every time
    if (state is LoggedIn) {
      if (event.edge == SignalEdge.rising && state.laserTubeTurnOnTimestamp != null) {
        emit(state.updateTime(
          laserDuration: state.laserDuration + (event.timestamp - state.laserTubeTurnOnTimestamp!),
          laserTubeTurnOnTimestamp: null,
          laserTubeTurnOnTime: null,
        ));
        _updateServerTimer ??= Timer.periodic(const Duration(minutes: 1), _updateServerTime);
      } else if (event.edge == SignalEdge.falling && state.laserTubeTurnOnTimestamp == null) {
        emit(state.updateTime(
          laserDuration: state.laserDuration,
          laserTubeTurnOnTimestamp: event.timestamp,
          laserTubeTurnOnTime: event.time,
        ));
        if (_updateServerTimer != null) {
          _updateServerTimer!.cancel();
          _updateServerTimer = null;
        }
      }
    }
  }
}
