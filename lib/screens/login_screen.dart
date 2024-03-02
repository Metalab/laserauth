import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:laserauth/cubit/login_cubit.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({required this.name, super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<LoginCubit, LoginState>(
      builder: (context, state) => Center(
        child: Card(
          child: DefaultTextStyle(
              style: theme.textTheme.headlineLarge!,
              child: Column(
                children: [
                  const Text('Who is this job for?'),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.read<LoginCubit>().loginMember(memberName: name),
                    child: const Text('Myself'),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO
                    },
                    child: const Text('Other member'),
                  ),
                  TextButton(
                    onPressed: () => context.read<LoginCubit>().loginExtern(),
                    child: const Text('External'),
                  ),
                  TextButton(
                    onPressed: () => context.read<LoginCubit>().logout(),
                    child: const Text('Get me out of here!'),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
