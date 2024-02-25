import 'package:flutter_gpiod/flutter_gpiod.dart';
import 'package:laserauth/config.dart';

class Hardware {
  Hardware(Configuration configuration) {
    final chips = FlutterGpiod.instance.chips;
    _chip = chips.singleWhere(
      (chip) => chip.label == 'pinctrl-bcm2711',
      orElse: () => chips.singleWhere((chip) => chip.label == 'pinctrl-bcm2835'),
    );

    _powerPin = _chip.lines[configuration.powerPin];
    _powerPin.requestOutput(consumer: 'Laserauth', initialValue: false);
    _laserSensePin = _chip.lines[configuration.laserSensePin];
    _laserSensePin
        .requestInput(consumer: 'Laserauth', bias: Bias.pullUp, triggers: {SignalEdge.falling, SignalEdge.rising});
  }

  void dispose() {
    _powerPin.release();
    _laserSensePin.release();
  }

  late final GpioChip _chip;
  late final GpioLine _powerPin;
  late final GpioLine _laserSensePin;

  set power(bool flag) {
    _powerPin.setValue(flag);
  }

  bool get laserSense => _laserSensePin.getValue();
  Stream<SignalEvent> get laserSenseStream => _laserSensePin.onEvent;
}
