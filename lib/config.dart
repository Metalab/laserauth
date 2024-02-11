import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:laserauth/constants.dart';
import 'package:laserauth/log.dart';
import 'package:yaml/yaml.dart';

@immutable
final class Configuration {
  final int laserPowerMinimum;
  final String powerMeterIP;
  final String updateUrl;
  final int pricePerMinute;
  final int externPricePerMinute;
  final String password;

  const Configuration({
    required this.laserPowerMinimum,
    required this.powerMeterIP,
    required this.updateUrl,
    required this.pricePerMinute,
    required this.externPricePerMinute,
    required this.password,
  });

  factory Configuration.fromJson(Map<dynamic, dynamic> json) {
    return Configuration(
      laserPowerMinimum: json['laserPowerMinimum'] as int,
      powerMeterIP: json['powerMeterIP'] as String,
      updateUrl: json['updateUrl'] as String,
      pricePerMinute: json['pricePerMinute'] as int,
      externPricePerMinute: json['externPricePerMinute'] as int,
      password: json['password'] as String,
    );
  }
}

Future<Configuration> readConfigFile() async {
  final Uint8List data;
  try {
    data = await File(configFile).readAsBytes();
  } catch (e) {
    log.e(e);
    rethrow;
  }

  final yaml = loadYaml(utf8.decode(data)) as YamlMap;

  return Configuration.fromJson(yaml.value);
}
