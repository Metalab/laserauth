import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:laserauth/cubit/login_cubit.dart';
import 'package:laserauth/screens/laser_screen.dart';
import 'package:laserauth/screens/login_screen.dart';
import 'package:laserauth/screens/logout_screen.dart';
import 'package:laserauth/screens/member_input_screen.dart';

class Content extends StatelessWidget {
  const Content({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
            child: BlocBuilder<LoginCubit, LoginState>(
          builder: (context, state) => switch (state) {
            LoggedOut(:final lastCosts, :final lastName) => LogoutScreen(lastCosts: lastCosts, lastName: lastName),
            LoggedInMemberInput() => const MemberInputScreen(),
            LoggedInMember() || LoggedInExtern() || LoggedInMetalab() => const LaserScreen(),
            LoggedIn(:final name) => LoginScreen(name: name),
          },
        )),
      ),
    );
  }
}
