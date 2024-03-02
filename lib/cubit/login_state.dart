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
    this.laserTubeTurnOnTimestamp,
  });

  final Uint8List iButtonId;
  final Duration laserDuration;
  final Duration? laserTubeTurnOnTimestamp;
  final String name;

  LoggedIn copyWith({
    Uint8List? iButtonId,
    Duration? laserDuration,
    Duration? laserTubeTurnOnTimestamp,
    String? name,
  }) =>
      LoggedIn(
        iButtonId: iButtonId ?? this.iButtonId,
        laserDuration: laserDuration ?? this.laserDuration,
        laserTubeTurnOnTimestamp: laserTubeTurnOnTimestamp ?? this.laserTubeTurnOnTimestamp,
        name: name ?? this.name,
      );
}

final class LoggedInExtern extends LoggedIn {
  const LoggedInExtern({
    required super.iButtonId,
    required super.name,
    super.laserDuration = Duration.zero,
    super.laserTubeTurnOnTimestamp,
  });

  @override
  LoggedIn copyWith({
    Uint8List? iButtonId,
    Duration? laserDuration,
    DateTime? loginTime,
    Duration? laserTubeTurnOnTimestamp,
    String? name,
  }) =>
      LoggedInExtern(
        iButtonId: iButtonId ?? this.iButtonId,
        laserDuration: laserDuration ?? this.laserDuration,
        laserTubeTurnOnTimestamp: laserTubeTurnOnTimestamp ?? this.laserTubeTurnOnTimestamp,
        name: name ?? this.name,
      );
}

final class LoggedInMember extends LoggedIn {
  const LoggedInMember({
    required super.iButtonId,
    required super.name,
    required this.memberName,
    super.laserDuration = Duration.zero,
    super.laserTubeTurnOnTimestamp,
  });

  final String memberName;

  @override
  LoggedIn copyWith({
    Uint8List? iButtonId,
    Duration? laserDuration,
    Duration? laserTubeTurnOnTimestamp,
    String? name,
    String? memberName,
  }) =>
      LoggedInMember(
        iButtonId: iButtonId ?? this.iButtonId,
        laserDuration: laserDuration ?? this.laserDuration,
        laserTubeTurnOnTimestamp: laserTubeTurnOnTimestamp ?? this.laserTubeTurnOnTimestamp,
        name: name ?? this.name,
        memberName: memberName ?? this.memberName,
      );
}
