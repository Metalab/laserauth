import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:laserauth/api.dart';
import 'package:laserauth/constants.dart';
import 'package:laserauth/log.dart';
import 'package:laserauth/price.dart';

part 'login_state.dart';

final LoginCubit login = LoginCubit();

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(const LoggedOut());

  Future<void> login({required Uint8List iButtonId, required String name}) async {
    final pollTimer = Timer.periodic(const Duration(seconds: 1), _pollLaserTime);
    log.i('Login $name with iButton $iButtonId');
    try {
      final status = await fetchStatus();

      emit(LoggedIn(
        iButtonId: iButtonId,
        name: name,
        pollTimer: pollTimer,
        startLaserEnergy: status.total,
      ));
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
        emit(LoggedOut(lastCosts: centsForLaserTime(laserSeconds, extern: extern), lastName: name));
      case LoggedOut():
      // nothing to do
    }
  }

  void _pollLaserTime(Timer t) async {
    try {
      final response = await fetchStatus();
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
          if (response.power >= laserPowerMinimum) {
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
