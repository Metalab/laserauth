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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) => Center(
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
                  '${(state as LoggedIn).laserDuration.inMinutes} min ${(state.laserDuration.inSeconds % 60).toString().padLeft(2, '0')} sec',
                ).applyConstraint(
                  left: parent.center.margin(4),
                  baseline: laserTimeLabel.baseline,
                ),
                Guideline(
                  id: guidelineLabel,
                  horizontal: true,
                  guidelinePercent: 0.5,
                ),
                const Text('Costs:').applyConstraint(
                  id: costsLabel,
                  right: parent.center.margin(4),
                  top: guidelineLabel.bottom.margin(8),
                ),
                BlocBuilder<ConfigurationCubit, Configuration>(
                  builder: (context, configuration) => Text(
                    '€ ${(centsForLaserTime(state.laserDuration, extern: state is LoggedInExtern, configuration: configuration) / 100).toStringAsFixed(2)}',
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
      ),
    );
  }
}
