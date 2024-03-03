import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:laserauth/constants.dart';
import 'package:laserauth/log.dart';
import 'package:yaml/yaml.dart';

@immutable
final class Configuration {
  final String updateUrl;
  final String authToken;
  final String logUrl;
  final int pricePerMinute;
  final int externPricePerMinute;
  final int powerPin;
  final int laserSensePin;
  final int idleLogoutMinutes;

  const Configuration({
    required this.updateUrl,
    required this.authToken,
    required this.logUrl,
    required this.pricePerMinute,
    required this.externPricePerMinute,
    required this.powerPin,
    required this.laserSensePin,
    required this.idleLogoutMinutes,
  });

  factory Configuration.fromJson(Map<dynamic, dynamic> json) {
    return Configuration(
      updateUrl: json['updateUrl'] as String,
      authToken: json['authToken'] as String,
      logUrl: json['logUrl'] as String,
      pricePerMinute: json['pricePerMinute'] as int,
      externPricePerMinute: json['externPricePerMinute'] as int,
      powerPin: json['powerPin'] as int,
      laserSensePin: json['laserSensePin'] as int,
      idleLogoutMinutes: json['idleLogoutMinutes'] as int,
    );
  }
}

Future<Configuration> readConfigFile() async {
  final Uint8List data;
  try {
    data = await File(configFile).readAsBytes();
  } catch (e) {
    log.severe(e);
    rethrow;
  }

  final yaml = loadYaml(utf8.decode(data)) as YamlMap;

  return Configuration.fromJson(yaml.value);
}
