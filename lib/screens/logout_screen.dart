import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:laserauth/api.dart';
import 'package:laserauth/bloc/i_button_device_bloc.dart';
import 'package:laserauth/cubit/authorized_user_cubit.dart';
import 'package:laserauth/cubit/login_cubit.dart';
import 'package:laserauth/log.dart';
import 'package:laserauth/util.dart';

class LogoutScreen extends StatelessWidget {
  const LogoutScreen({super.key, this.lastCosts, this.lastName, this.error});

  final int? lastCosts;
  final String? lastName;
  final String? error;

  @override
  Widget build(BuildContext context) {
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
                          error!,
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
        if (lastCosts != null && lastCosts! > 0)
          Text('Last job: € ${(lastCosts! / 100).toStringAsFixed(2)} (operator $lastName)'),
      ],
    );
  }
}
