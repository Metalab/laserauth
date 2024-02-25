import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:laserauth/api.dart';
import 'package:laserauth/bloc/i_button_device_bloc.dart';
import 'package:laserauth/config.dart';
import 'package:laserauth/content.dart';
import 'package:laserauth/cubit/authorized_user_cubit.dart';
import 'package:laserauth/cubit/login_cubit.dart';
import 'package:laserauth/log.dart';
import 'package:logging/logging.dart';

Future<void> main() async {
  Logger.root.level = Level.ALL;
  final configuration = await readConfigFile();

  final serverLogger = ServerLogger(
    logUri: Uri.parse(configuration.logUrl),
    token: configuration.authToken,
  );

  Logger.root.onRecord.listen((record) {
    if (record is ThingEvent) {
      serverLogger.sendLogEvent(record as ThingEvent);
    }
    debugPrint('[${record.level.name}] ${record.time}: ${record.message}');
  });
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
            return Scaffold(
              appBar: AppBar(
                title: state is LoggedIn
                    ? state.extern
                        ? Text('Responsible: ${state.name}')
                        : Text('Accountable Operator: ${state.name}')
                    : const Text('Laserauth'),
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
