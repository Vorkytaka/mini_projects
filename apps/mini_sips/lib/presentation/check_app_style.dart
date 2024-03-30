import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../dependencies.dart';

class CheckAppStyleScreen extends StatefulWidget {
  const CheckAppStyleScreen({super.key});

  @override
  State<CheckAppStyleScreen> createState() => _CheckAppStyleScreenState();
}

class _CheckAppStyleScreenState extends State<CheckAppStyleScreen> {
  @override
  void initState() {
    super.initState();

    final dependencies = context.read<Dependencies>();
    final authManager = dependencies.authManager;

    authManager.isAppStyleSelected.then(_isAppStyleSelected);
  }

  void _isAppStyleSelected(bool isSelected) {
    final String nextScreenPath;
    if (isSelected) {
      // navigate to main screen
      nextScreenPath = '/main';
    } else {
      // navigate to select screen
      nextScreenPath = '/select_app_style';
    }

    Navigator.of(context).pushReplacementNamed(nextScreenPath);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
