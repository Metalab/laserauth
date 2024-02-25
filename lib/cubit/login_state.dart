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
    this.laserDuration = Duration.zero,
    this.extern = false,
    this.laserTubeTurnOnTimestamp,
    required this.loginTime,
  });

  final Uint8List iButtonId;
  final String name;
  final Duration laserDuration;
  final bool extern;
  final DateTime loginTime;
  final Duration? laserTubeTurnOnTimestamp;
}

final class ConnectionFailed extends LoginState {
  const ConnectionFailed(this.message);

  final String message;
}
