import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_constraintlayout/flutter_constraintlayout.dart';
import 'package:laserauth/api.dart';
import 'package:laserauth/bloc/i_button_device_bloc.dart';
import 'package:laserauth/cubit/authorized_user_cubit.dart';
import 'package:laserauth/cubit/login_cubit.dart';
import 'package:laserauth/log.dart';
import 'package:laserauth/price.dart';
import 'package:laserauth/util.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final laserTimeLabel = ConstraintId('lasertime');
  final powerLabel = ConstraintId('power');
  final costsLabel = ConstraintId('costs');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) => switch (state) {
        LoggedOut(:final lastCosts, :final lastName) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BlocBuilder<AuthorizedUserCubit, List<AuthorizedUser>>(
                builder: (context, authorizedUsers) {
                  return BlocListener<IButtonDeviceBloc, Uint8List?>(
                    listener: (context, state) {
                      if (state != null) {
                        log.d('looking for $state in authorized: $authorizedUsers');
                        final user = authorizedUsers.tryFirstWhere((user) => user.compareIButtonId(state));
                        if (user != null) {
                          login.login(iButtonId: user.iButtonId, name: user.name);
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
                    child: Text(
                      'Please log in using your iButton.',
                      style: theme.textTheme.headlineLarge,
                    ),
                  );
                },
              ),
              const SizedBox(
                height: 16,
              ),
              if (lastCosts > 0) Text('Last job: € ${(lastCosts / 100).toStringAsFixed(2)} (operator $lastName)'),
            ],
          ),
        LoggedIn(:final laserSeconds, :final laserEnergy, :final extern) => Center(
            child: Card(
              child: DefaultTextStyle(
                style: theme.textTheme.headlineLarge!,
                child: ConstraintLayout(
                  children: [
                    const Text('Laser time:').applyConstraint(
                      id: laserTimeLabel,
                      right: parent.center.margin(4),
                      bottom: powerLabel.top.margin(8),
                    ),
                    Text('${laserSeconds ~/ 60} min ${(laserSeconds % 60).toString().padLeft(2, '0')} sec')
                        .applyConstraint(
                      left: parent.center.margin(4),
                      baseline: laserTimeLabel.baseline,
                    ),
                    const Text('Energy usage:').applyConstraint(
                      id: powerLabel,
                      centerVerticalTo: parent,
                      right: parent.center.margin(4),
                    ),
                    Text('${(laserEnergy * 1000).round()} Wh').applyConstraint(
                      left: parent.center.margin(4),
                      baseline: powerLabel.baseline,
                    ),
                    const Text('Costs:').applyConstraint(
                      id: costsLabel,
                      right: parent.center.margin(4),
                      top: powerLabel.bottom.margin(4),
                    ),
                    Text(
                      '€ ${(centsForLaserTime(laserSeconds, extern: extern) / 100).toStringAsFixed(2)}',
                    ).applyConstraint(
                      left: parent.center.margin(4),
                      baseline: costsLabel.baseline,
                    ),
                  ],
                ),
              ),
            ),
          ),
      },
    );
  }
}
