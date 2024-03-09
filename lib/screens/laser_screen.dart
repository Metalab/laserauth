import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';
import 'package:laserauth/cubit/configuration_cubit.dart';
import 'package:laserauth/cubit/configuration_state.dart';
import 'package:laserauth/cubit/login_cubit.dart';
import 'package:laserauth/price.dart';

class LaserScreen extends StatefulWidget {
  const LaserScreen({super.key});

  @override
  State<LaserScreen> createState() => _LaserScreenState();
}

class _LaserScreenState extends State<LaserScreen> {
  final laserTimeLabel = ConstraintId('lasertime');
  final costsLabel = ConstraintId('costs');
  final guidelineLabel = ConstraintId('guideline');

  // only temporary until the laser is off again, just to display the current duration while the laser is in operation and not just update at the end
  var _currentTime = Duration.zero;
  Timer? _displayUpdateTimer;

  @override
  void dispose() {
    _displayUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<LoginCubit, LoginState>(
      listenWhen: (previous, current) =>
          (previous is LoggedIn &&
              current is LoggedIn &&
              previous.laserTubeTurnOnTime != current.laserTubeTurnOnTime) ||
          (previous is LoggedIn != current is LoggedIn),
      listener: (context, state) {
        if (state is LoggedIn) {
          if (state.laserTubeTurnOnTime != null) {
            _displayUpdateTimer = Timer.periodic(
              const Duration(milliseconds: 200),
              (timer) => setState(() {
                _currentTime = DateTime.now().difference(state.laserTubeTurnOnTime!);
              }),
            );
          } else if (_displayUpdateTimer != null) {
            _displayUpdateTimer!.cancel();
            _displayUpdateTimer = null;
            setState(() {
              _currentTime = Duration.zero;
            });
          }
        } else if (_displayUpdateTimer != null) {
          _displayUpdateTimer!.cancel();
          _displayUpdateTimer = null;
          setState(() {
            _currentTime = Duration.zero;
          });
        }
      },
      builder: (context, state) {
        final duration = (state as LoggedIn).laserDuration + _currentTime;

        return Center(
          child: Card(
            child: DefaultTextStyle(
              style: theme.textTheme.headlineLarge!,
              child: ConstraintLayout(
                children: [
                  const Text('Laser time:').applyConstraint(
                    id: laserTimeLabel,
                    right: parent.center.margin(4),
                    bottom: guidelineLabel.top.margin(8),
                  ),
                  Text(
                    '${duration.inMinutes} min ${(duration.inSeconds % 60).toString().padLeft(2, '0')} sec',
                  ).applyConstraint(
                    left: parent.center.margin(4),
                    baseline: laserTimeLabel.baseline,
                  ),
                  Guideline(
                    id: guidelineLabel,
                    horizontal: true,
                    guidelinePercent: 0.5,
                  ),
                  if (state is! LoggedInMetalab)
                    const Text('Costs:').applyConstraint(
                      id: costsLabel,
                      right: parent.center.margin(4),
                      top: guidelineLabel.bottom.margin(8),
                    ),
                  if (state is! LoggedInMetalab)
                    BlocBuilder<ConfigurationCubit, Configuration>(
                      builder: (context, configuration) => Text(
                        '€ ${(centsForLaserTime(duration, extern: state is LoggedInExtern, configuration: configuration) / 100).toStringAsFixed(2)}',
                      ),
                    ).applyConstraint(
                      left: parent.center.margin(4),
                      baseline: costsLabel.baseline,
                    ),
                  if (state.laserTubeTurnOnTimestamp == null)
                    FilledButton(
                      onPressed: () {
                        context.read<LoginCubit>().logout();
                      },
                      child: const Text('Log out'),
                    ).applyConstraint(
                      right: parent.right.margin(16),
                      bottom: parent.bottom.margin(16),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
