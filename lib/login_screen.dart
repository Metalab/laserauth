import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';
import 'package:laserauth/api.dart';
import 'package:laserauth/bloc/i_button_device_bloc.dart';
import 'package:laserauth/config.dart';
import 'package:laserauth/cubit/authorized_user_cubit.dart';
import 'package:laserauth/cubit/login_cubit.dart';
import 'package:laserauth/log.dart';
import 'package:laserauth/price.dart';
import 'package:laserauth/util.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({required this.configuration, super.key});

  final Configuration configuration;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final laserTimeLabel = ConstraintId('lasertime');
  final costsLabel = ConstraintId('costs');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) => switch (state) {
        LoggedOut(:final lastCosts, :final lastName) => logoutScreen(context, lastCosts: lastCosts, lastName: lastName),
        ConnectionFailed(:final message) => logoutScreen(context, error: message),
        LoggedIn(:final laserDuration, :final extern, :final laserTubeTurnOnTimestamp) => Center(
            child: Card(
              child: DefaultTextStyle(
                style: theme.textTheme.headlineLarge!,
                child: ConstraintLayout(
                  children: [
                    const Text('Laser time:').applyConstraint(
                      id: laserTimeLabel,
                      right: parent.center.margin(4),
                      bottom: parent.top.margin(8),
                    ),
                    Text('${laserDuration.inMinutes} min ${(laserDuration.inSeconds % 60).toString().padLeft(2, '0')} sec')
                        .applyConstraint(
                      left: parent.center.margin(4),
                      baseline: laserTimeLabel.baseline,
                    ),
                    const Text('Costs:').applyConstraint(
                      id: costsLabel,
                      right: parent.center.margin(4),
                      top: laserTimeLabel.bottom.margin(4),
                    ),
                    Text(
                      '€ ${(centsForLaserTime(laserDuration, extern: extern, configuration: widget.configuration) / 100).toStringAsFixed(2)}',
                    ).applyConstraint(
                      left: parent.center.margin(4),
                      baseline: costsLabel.baseline,
                    ),
                    if (laserTubeTurnOnTimestamp == null)
                      FilledButton(
                        onPressed: () {
                          context.read<LoginCubit>().logout();
                        },
                        child: const Text('Turn off'),
                      ).applyConstraint(
                        right: parent.right.margin(8),
                        bottom: parent.bottom.margin(8),
                      ),
                    extern
                        ? FilledButton(
                            onPressed: () {
                              context.read<LoginCubit>().setExtern(extern: false);
                            },
                            child: const Text('Switch to Member'),
                          ).applyConstraint(
                            left: parent.left.margin(8),
                            bottom: parent.bottom.margin(8),
                          )
                        : OutlinedButton(
                            onPressed: () {
                              context.read<LoginCubit>().setExtern(extern: true);
                            },
                            child: const Text('Switch to Extern'),
                          ).applyConstraint(
                            left: parent.left.margin(8),
                            bottom: parent.bottom.margin(8),
                          ),
                  ],
                ),
              ),
            ),
          ),
      },
    );
  }

  Column logoutScreen(BuildContext context, {int? lastCosts, String? lastName, String? error}) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        BlocBuilder<AuthorizedUserCubit, List<AuthorizedUser>>(
          builder: (context, authorizedUsers) {
            return BlocListener<IButtonDeviceBloc, Uint8List?>(
              listener: (context, state) {
                if (state != null) {
                  final user = authorizedUsers.tryFirstWhere((user) => user.compareIButtonId(state));
                  log.info(ThingEvent(
                    kind: EventKind.login,
                    user: user?.name,
                  ));
                  if (user != null) {
                    context.read<LoginCubit>().login(iButtonId: user.iButtonId, name: user.name);
                  } else {
                    final theme = Theme.of(context);

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('You are not authorized!'),
                      backgroundColor: theme.colorScheme.error,
                    ));
                  }
                  context.read<IButtonDeviceBloc>().reset();
                }
              },
              child: error == null
                  ? Text(
                      'Please log in using your iButton.',
                      style: theme.textTheme.headlineLarge,
                    )
                  : Center(
                      child: Card(
                        child: Text(
                          error,
                          style: theme.textTheme.headlineLarge?.copyWith(color: theme.colorScheme.error),
                        ),
                      ),
                    ),
            );
          },
        ),
        const SizedBox(
          height: 16,
        ),
        if (lastCosts != null && lastCosts > 0)
          Text('Last job: € ${(lastCosts / 100).toStringAsFixed(2)} (operator $lastName)'),
      ],
    );
  }
}
