import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:laserauth/bloc/i_button_device_bloc.dart';
import 'package:laserauth/config.dart';
import 'package:laserauth/content.dart';
import 'package:laserauth/cubit/authorized_user_cubit.dart';
import 'package:laserauth/cubit/login_cubit.dart';

Future<void> main() async {
  final configuration = await readConfigFile();
  runApp(MyApp(configuration: configuration));
}

class MyApp extends StatelessWidget {
  const MyApp({required this.configuration, super.key});

  final Configuration configuration;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LoginCubit(configuration: configuration)),
        BlocProvider.value(value: iButtonDevices),
        BlocProvider(create: (_) => AuthorizedUserCubit(configuration: configuration)),
      ],
      child: MaterialApp(
        title: 'Laserauth',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0B0835),
            brightness: Brightness.dark,
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: BlocBuilder<LoginCubit, LoginState>(
          builder: (context, state) {
            final theme = Theme.of(context);

            return Scaffold(
              appBar: AppBar(
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: state is LoggedIn
                      ? [
                          state.extern
                              ? Text('Responsible: ${state.name}')
                              : Text('Accountable Operator: ${state.name}'),
                          const SizedBox(width: 8),
                          if (!state.extern)
                            IconButton(
                                onPressed: () {
                                  context.read<LoginCubit>().setExtern();
                                },
                                icon: Image.asset(
                                  'assets/alien-head.png',
                                  height: 32,
                                  color: theme.colorScheme.primary,
                                )),
                        ]
                      : [const Text('Laserauth')],
                ),
                actions: [
                  state is LoggedOut
                      ? const SizedBox()
                      : IconButton(
                          onPressed: () {
                            context.read<LoginCubit>().logout();
                          },
                          icon: Icon(
                            Icons.power_off,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                ],
              ),
              body: Content(
                configuration: configuration,
              ),
            );
          },
        ),
      ),
    );
  }
}
