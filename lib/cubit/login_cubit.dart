import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:laserauth/api.dart';
import 'package:laserauth/config.dart';
import 'package:laserauth/log.dart';
import 'package:laserauth/price.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({required this.configuration}) : super(const LoggedOut());

  final Configuration configuration;

  Future<void> login({required Uint8List iButtonId, required String name}) async {
    final pollTimer = Timer.periodic(const Duration(seconds: 1), _pollLaserTime);
    try {
      final status = await fetchStatus(powerMeterIP: configuration.powerMeterIP, password: configuration.password);

      emit(LoggedIn(
        iButtonId: iButtonId,
        name: name,
        pollTimer: pollTimer,
        startLaserEnergy: status.total,
      ));
      setPowerStatus(power: true, powerMeterIP: configuration.powerMeterIP, password: configuration.password);
    } on Error catch (e) {
      log.e(e.toString(), stackTrace: e.stackTrace);
    }
  }

  void setExtern() {
    switch (state) {
      case LoggedIn(
          :final iButtonId,
          :final name,
          :final laserSeconds,
          :final laserEnergy,
          :final startLaserEnergy,
          :final pollTimer,
        ):
        log.i('Switch to extern');
        emit(LoggedIn(
          iButtonId: iButtonId,
          name: name,
          pollTimer: pollTimer,
          laserSeconds: laserSeconds,
          laserEnergy: laserEnergy,
          startLaserEnergy: startLaserEnergy,
          extern: true,
        ));
      case LoggedOut():
      // nothing to do
    }
  }

  void logout() {
    switch (state) {
      case LoggedIn(:final name, :final pollTimer, :final laserSeconds, :final extern):
        pollTimer.cancel();
        log.i('Logout $name with $laserSeconds seconds (extern $extern)');
        emit(LoggedOut(
          lastCosts: centsForLaserTime(laserSeconds, extern: extern, configuration: configuration),
          lastName: name,
        ));
      case LoggedOut():
      // nothing to do
    }
    setPowerStatus(power: false, powerMeterIP: configuration.powerMeterIP, password: configuration.password);
  }

  void _pollLaserTime(Timer t) async {
    try {
      final response = await fetchStatus(powerMeterIP: configuration.powerMeterIP, password: configuration.password);
      log.d('Status: $response');
      switch (state) {
        case LoggedOut():
          t.cancel();
          return;
        case LoggedIn(
            :final iButtonId,
            :final name,
            :var laserSeconds,
            :final extern,
            :final startLaserEnergy,
          ):
          if (response.power >= configuration.laserPowerMinimum) {
            laserSeconds++;
          }
          emit(LoggedIn(
            iButtonId: iButtonId,
            name: name,
            laserSeconds: laserSeconds,
            laserEnergy: response.total - startLaserEnergy,
            startLaserEnergy: startLaserEnergy,
            pollTimer: t,
            extern: extern,
          ));
      }
    } catch (e) {
      log.e(e);
    }
  }
}
