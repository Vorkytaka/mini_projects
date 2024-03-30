import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../dependencies.dart';
import 'welcome_cubit.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WelcomeCubit(
        authManager: context.read<Dependencies>().authManager,
      ),
      lazy: false,
      child: BlocListener<WelcomeCubit, WelcomeStatus>(
        listener: (context, status) {
          if (status == WelcomeStatus.success) {
            Navigator.of(context).pushReplacementNamed('/check_app_style');
          }
        },
        child: const _Content(),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.read<WelcomeCubit>().auth(),
          child: const Text('Войти'),
        ),
      ),
    );
  }
}
