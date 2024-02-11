import 'package:flutter/material.dart';
import 'package:laserauth/config.dart';
import 'package:laserauth/login_screen.dart';

class Content extends StatelessWidget {
  const Content({required this.configuration, super.key});

  final Configuration configuration;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
            child: LoginScreen(
          configuration: configuration,
        )),
      ),
    );
  }
}
