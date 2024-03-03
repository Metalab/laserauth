import 'package:laserauth/cubit/configuration_state.dart';

int centsForLaserTime(Duration duration, {required bool extern, required Configuration configuration}) {
  return (duration.inMilliseconds *
          (extern ? configuration.externPricePerMinute : configuration.pricePerMinute) /
          60000)
      .round();
}
