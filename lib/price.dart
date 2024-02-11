import 'package:laserauth/config.dart';

int centsForLaserTime(int seconds, {required bool extern, required Configuration configuration}) {
  return (seconds * (extern ? configuration.externPricePerMinute : configuration.pricePerMinute) / 60).round();
}
