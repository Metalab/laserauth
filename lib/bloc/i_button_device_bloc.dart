import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:laserauth/log.dart';
import 'package:laserauth/util.dart';
import 'package:udev/udev.dart';

final iButtonDevices = IButtonDeviceBloc();

class IButtonDeviceBloc extends Bloc<Uint8List?, Uint8List?> {
  IButtonDeviceBloc()
      : context = UdevContext(),
        super(null) {
    on<Uint8List?>((event, emit) {
      emit(event);
    });

    _subscription = context.monitorDevices(subsystems: ['w1']).listen((event) {
      final address = event.sysname.replaceAll('-', '');
      log.d('${event.action} device $address event $event');
      final addressList = hexStringToUint8List(address);
      log.d('parsed address = $addressList');

      add(addressList);
    });
  }

  final UdevContext context;
  late final StreamSubscription _subscription;

  void reset() {
    add(null);
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
