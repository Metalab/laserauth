import 'dart:convert';

import 'package:laserauth/constants.dart';
import 'package:http/http.dart' as http;

final class Status {
  final DateTime time;
  final DateTime totalStartTime;
  final double total;
  final double yesterday;
  final double today;
  final int power;
  final int apparentPower;
  final int reactivePower;
  final double factor;
  final int voltage;
  final double current;

  const Status({
    required this.time,
    required this.totalStartTime,
    required this.total,
    required this.yesterday,
    required this.today,
    required this.power,
    required this.apparentPower,
    required this.reactivePower,
    required this.factor,
    required this.voltage,
    required this.current,
  });

  Status.fromJson(Map<String, dynamic> json)
      : time = DateTime.parse(json['Time'] as String),
        totalStartTime = DateTime.parse((json['ENERGY'] as Map<String, dynamic>)['TotalStartTime'] as String),
        total = (json['ENERGY'] as Map<String, dynamic>)['Total'],
        yesterday = (json['ENERGY'] as Map<String, dynamic>)['Yesterday'],
        today = (json['ENERGY'] as Map<String, dynamic>)['Today'],
        power = (json['ENERGY'] as Map<String, dynamic>)['Power'],
        apparentPower = (json['ENERGY'] as Map<String, dynamic>)['ApparentPower'],
        reactivePower = (json['ENERGY'] as Map<String, dynamic>)['ReactivePower'],
        factor = (json['ENERGY'] as Map<String, dynamic>)['Factor'],
        voltage = (json['ENERGY'] as Map<String, dynamic>)['Voltage'],
        current = (json['ENERGY'] as Map<String, dynamic>)['Current'];
}

Future<Status> fetchStatus() async {
  final url = Uri.http(powerMeterIP, 'cm', {'cmnd': 'Status 10'});
  final response = await http.get(url);
  final json = jsonDecode(response.body);

  return Status.fromJson(json['StatusSNS']);
}
