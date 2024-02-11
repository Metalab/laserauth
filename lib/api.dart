import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:laserauth/constants.dart';
import 'package:laserauth/log.dart';
import 'package:laserauth/util.dart';

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

final class AuthorizedUser {
  final String name;
  final Uint8List iButtonId;

  const AuthorizedUser({required this.name, required this.iButtonId});

  bool compareIButtonId(Uint8List inputId) => listEquals(iButtonId, inputId);

  @override
  String toString() => 'AuthorizedUser(name: $name, iButtonId: $iButtonId)';
}

const iButtonFile = 'iButtons.csv';

List<AuthorizedUser> parseData(Uint8List data) {
  return utf8
      .decode(data)
      .split('\n')
      .map((line) {
        if (line.isEmpty) {
          return null;
        }
        log.d('line = "$line"');
        var separator = line.indexOf(',');
        if (separator == -1) {
          separator = line.length - 1; // empty name
        }
        final id = hexStringToUint8List(line.substring(0, separator).replaceAll('-', ''));
        log.d('id = $id, name = ${line.substring(separator + 1).trim()}');

        return AuthorizedUser(name: line.substring(separator + 1).trim(), iButtonId: id);
      })
      .whereType<AuthorizedUser>()
      .toList(growable: false);
}

Stream<List<AuthorizedUser>> userList() async* {
  Uint8List? data;
  try {
    data = await File(iButtonFile).readAsBytes();
  } catch (e) {
    log.e(e);
  }

  if (data != null) {
    try {
      yield parseData(data);
    } catch (e) {
      log.e(e);
      return;
    }
  }

  var digest = data != null ? sha1.convert(data) : null;
  while (true) {
    var failed = true;
    try {
      final response = await http.get(Uri.parse(updateUrl));
      if (response.statusCode == 200) {
        failed = false;

        final body = response.bodyBytes;
        final newDigest = sha1.convert(body);

        if (newDigest != digest) {
          digest = newDigest;
          yield parseData(body);
          unawaited(File(iButtonFile).writeAsBytes(body).catchError((e) {
            log.e(e);
            throw e;
          }));
        }
      }
    } catch (e) {
      log.e(e);
    }

    await Future.delayed(failed ? const Duration(minutes: 10) : const Duration(hours: 1));
  }
}
