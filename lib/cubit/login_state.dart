part of 'login_cubit.dart';

@immutable
sealed class LoginState {
  const LoginState();
}

final class LoggedOut extends LoginState {
  const LoggedOut({this.lastCosts = 0, this.lastName});

  final int lastCosts;
  final String? lastName;
}

final class LoggedIn extends LoginState {
  const LoggedIn({
    required this.iButtonId,
    required this.name,
    this.laserSeconds = 0,
    this.laserEnergy = 0,
    required this.startLaserEnergy,
    required this.pollTimer,
    this.extern = false,
    this.currentlyActive = false,
  });

  final Uint8List iButtonId;
  final String name;
  final int laserSeconds;
  final double laserEnergy;
  final double startLaserEnergy;
  final Timer pollTimer;
  final bool extern;
  final bool currentlyActive;
}

final class ConnectionFailed extends LoginState {
  const ConnectionFailed(this.message);

  final String message;
}
