import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udev/udev.dart';

part 'i_button_device_event.dart';

final iButtonDevices = IButtonDeviceBloc();

class IButtonDeviceBloc extends Bloc<IButtonDeviceEvent, Set<Uint8List>> {
  IButtonDeviceBloc()
      : context = UdevContext(),
        super(const {}) {
    on<IButtonDeviceEvent>((event, emit) {
      switch (event) {
        case IButtonConnectedEvent(:final address):
          final devices = Set<Uint8List>.from(state);
          devices.add(address);
          emit(devices);
        case IButtonDisconnectedEvent(:final address):
          final devices = Set<Uint8List>.from(state);
          devices.remove(address);
          emit(devices);
      }
    });

    _subscription = context.monitorDevices(subsystems: ['1wire']).listen((event) {
      // final address = event.devnode;

      switch (event.action) {
        case 'add':
        // add(IButtonConnectedEvent(address));
        case 'remove':
        // add(IButtonDisconnectedEvent(address));
      }
    });
  }

  final UdevContext context;
  late final StreamSubscription _subscription;

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
