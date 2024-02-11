import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:laserauth/bloc/i_button_device_bloc.dart';
import 'package:laserauth/content.dart';
import 'package:laserauth/cubit/authorized_user_cubit.dart';
import 'package:laserauth/cubit/login_cubit.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: login),
        BlocProvider.value(value: iButtonDevices),
        BlocProvider.value(value: authorizedUser),
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
                                  login.setExtern();
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
                            login.logout();
                          },
                          icon: Icon(
                            Icons.power_off,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                ],
              ),
              body: const Content(),
            );
          },
        ),
      ),
    );
  }
}
