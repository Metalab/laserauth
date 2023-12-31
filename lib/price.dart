import 'package:laserauth/constants.dart';

int centsForLaserTime(int seconds, {required bool extern}) {
  return (seconds * (extern ? externPricePerMinute : pricePerMinute) / 60).round();
}
