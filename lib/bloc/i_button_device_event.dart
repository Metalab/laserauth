part of 'i_button_device_bloc.dart';

sealed class IButtonDeviceEvent {
  const IButtonDeviceEvent();
}

final class IButtonConnectedEvent extends IButtonDeviceEvent {
  const IButtonConnectedEvent(this.address);

  final Uint8List address;
}

final class IButtonDisconnectedEvent extends IButtonDeviceEvent {
  const IButtonDisconnectedEvent(this.address);

  final Uint8List address;
}
