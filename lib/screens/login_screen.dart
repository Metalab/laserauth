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
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Who is this job for?', style: theme.textTheme.labelLarge),
                    TextButton(
                      onPressed: () => context.read<LoginCubit>().loginMember(memberName: name),
                      child: const Text('Myself'),
                    ),
                    TextButton(
                      onPressed: () => context.read<LoginCubit>().loginMemberInput(),
                      child: const Text('Other member'),
                    ),
                    TextButton(
                      onPressed: () => context.read<LoginCubit>().loginMetalab(),
                      child: const Text('Metalab Infrastructure'),
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
                ),
              )),
        ),
      ),
    );
  }
}
