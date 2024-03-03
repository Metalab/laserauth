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
    this.laserTubeTurnOnTime,
  });

  final Uint8List iButtonId;
  final Duration laserDuration;
  final Duration? laserTubeTurnOnTimestamp;
  final DateTime? laserTubeTurnOnTime;
  final String name;

  LoggedIn updateTime({
    required Duration laserDuration,
    Duration? laserTubeTurnOnTimestamp,
    DateTime? laserTubeTurnOnTime,
  }) {
    return LoggedIn(
      iButtonId: iButtonId,
      laserDuration: laserDuration,
      laserTubeTurnOnTimestamp: laserTubeTurnOnTimestamp,
      laserTubeTurnOnTime: laserTubeTurnOnTime,
      name: name,
    );
  }

  LoggedIn copyWith({
    Uint8List? iButtonId,
    Duration? laserDuration,
    Duration? laserTubeTurnOnTimestamp,
    DateTime? laserTubeTurnOnTime,
    String? name,
  }) =>
      LoggedIn(
        iButtonId: iButtonId ?? this.iButtonId,
        laserDuration: laserDuration ?? this.laserDuration,
        laserTubeTurnOnTimestamp: laserTubeTurnOnTimestamp ?? this.laserTubeTurnOnTimestamp,
        laserTubeTurnOnTime: laserTubeTurnOnTime ?? this.laserTubeTurnOnTime,
        name: name ?? this.name,
      );
}

final class LoggedInExtern extends LoggedIn {
  const LoggedInExtern({
    required super.iButtonId,
    required super.name,
    super.laserDuration = Duration.zero,
    super.laserTubeTurnOnTimestamp,
    super.laserTubeTurnOnTime,
  });

  @override
  LoggedInExtern updateTime({
    required Duration laserDuration,
    Duration? laserTubeTurnOnTimestamp,
    DateTime? laserTubeTurnOnTime,
  }) {
    return LoggedInExtern(
      iButtonId: iButtonId,
      laserDuration: laserDuration,
      laserTubeTurnOnTimestamp: laserTubeTurnOnTimestamp,
      laserTubeTurnOnTime: laserTubeTurnOnTime,
      name: name,
    );
  }

  @override
  LoggedIn copyWith({
    Uint8List? iButtonId,
    Duration? laserDuration,
    DateTime? loginTime,
    Duration? laserTubeTurnOnTimestamp,
    DateTime? laserTubeTurnOnTime,
    String? name,
  }) =>
      LoggedInExtern(
        iButtonId: iButtonId ?? this.iButtonId,
        laserDuration: laserDuration ?? this.laserDuration,
        laserTubeTurnOnTimestamp: laserTubeTurnOnTimestamp ?? this.laserTubeTurnOnTimestamp,
        laserTubeTurnOnTime: laserTubeTurnOnTime ?? this.laserTubeTurnOnTime,
        name: name ?? this.name,
      );
}

final class LoggedInMemberInput extends LoggedIn {
  const LoggedInMemberInput({
    required super.iButtonId,
    required super.name,
    super.laserDuration = Duration.zero,
    super.laserTubeTurnOnTimestamp,
    super.laserTubeTurnOnTime,
  });
}

final class LoggedInMember extends LoggedIn {
  const LoggedInMember({
    required super.iButtonId,
    required super.name,
    required this.memberName,
    super.laserDuration = Duration.zero,
    super.laserTubeTurnOnTimestamp,
    super.laserTubeTurnOnTime,
  });

  final String memberName;

  @override
  LoggedInMember updateTime({
    required Duration laserDuration,
    Duration? laserTubeTurnOnTimestamp,
    DateTime? laserTubeTurnOnTime,
  }) {
    return LoggedInMember(
      iButtonId: iButtonId,
      laserDuration: laserDuration,
      laserTubeTurnOnTimestamp: laserTubeTurnOnTimestamp,
      laserTubeTurnOnTime: laserTubeTurnOnTime,
      name: name,
      memberName: memberName,
    );
  }

  @override
  LoggedIn copyWith({
    Uint8List? iButtonId,
    Duration? laserDuration,
    Duration? laserTubeTurnOnTimestamp,
    DateTime? laserTubeTurnOnTime,
    String? name,
    String? memberName,
  }) =>
      LoggedInMember(
        iButtonId: iButtonId ?? this.iButtonId,
        laserDuration: laserDuration ?? this.laserDuration,
        laserTubeTurnOnTimestamp: laserTubeTurnOnTimestamp ?? this.laserTubeTurnOnTimestamp,
        laserTubeTurnOnTime: laserTubeTurnOnTime ?? this.laserTubeTurnOnTime,
        name: name ?? this.name,
        memberName: memberName ?? this.memberName,
      );
}
