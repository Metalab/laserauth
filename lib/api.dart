import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:laserauth/log.dart';
import 'package:laserauth/util.dart';

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
        var separator = line.indexOf(',');
        if (separator == -1) {
          separator = line.length - 1; // empty name
        }
        final id = hexStringToUint8List(line.substring(0, separator).replaceAll('-', ''));

        return AuthorizedUser(name: line.substring(separator + 1).trim(), iButtonId: id);
      })
      .whereType<AuthorizedUser>()
      .toList(growable: false);
}

Stream<List<AuthorizedUser>> userList(String updateUrl, String authToken) async* {
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
      final response = await http.get(Uri.parse(updateUrl), headers: {
        'X-TOKEN': authToken,
      });
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
