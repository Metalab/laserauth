import 'package:flutter/material.dart';
import 'package:laserauth/login_screen.dart';

class Content extends StatelessWidget {
  const Content({super.key});

  @override
  Widget build(BuildContext context) {
    return const Material(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(child: LoginScreen()),
      ),
    );
  }
}
