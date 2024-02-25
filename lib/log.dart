import 'package:logging/logging.dart';

final log = Logger('laserauth');

enum EventKind {
  login(name: 'LOGIN'),
  logout(name: 'LOGOUT'),
  usageMember(name: 'USAGE_MEMBER'),
  usageNonmember(name: 'USAGE_NONMEMBER');

  final String name;
  const EventKind({required this.name});
}

final class ThingEvent {
  final EventKind kind;
  final String? user;
  final int? usageSeconds;

  ThingEvent({required this.kind, this.user, this.usageSeconds});

  @override
  String toString() => usageSeconds != null ? '${kind.name} [$user] seconds = $usageSeconds' : '${kind.name} [$user]';

  Map<String, dynamic> toJson() {
    return {
      'kind': kind.name,
      'user': user,
      'usage_seconds': usageSeconds,
    };
  }
}
