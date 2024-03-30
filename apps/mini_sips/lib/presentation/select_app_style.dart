import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/either.dart';
import '../dependencies.dart';
import '../domain/user_data.dart';
import 'common/cupertino_card.dart';

class SelectAppStyleScreen extends StatelessWidget {
  const SelectAppStyleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CupertinoNavigationBar(
        middle: Text('Выберите хрень'),
      ),
      body: _Body(),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  AppStyle? _appStyle;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _Selector(
                appStyle: _appStyle,
                onStyleChanged: (appStyle) => setState(() {
                  _appStyle = appStyle;
                }),
              ),
            ),
            const SizedBox(height: 12),
            CupertinoButton.filled(
              onPressed: _appStyle == null ? null : _onSubmit,
              child: const Text('Принять'),
            ),
          ],
        ),
      ),
    );
  }

  void _onSubmit() {
    final appStyle = _appStyle;

    if (appStyle == null) {
      throw Exception('App style cannot be null');
    }

    final dependencies = context.read<Dependencies>();
    final authManager = dependencies.authManager;
    authManager.setAppStyle(appStyle).fold(
      ifLeft: (e) {
        // TODO(Vorkytaka): Tell about error
      },
      ifRight: (_) {
        Navigator.of(context).pushReplacementNamed('/main');
      },
    );
  }
}

class _Selector extends StatelessWidget {
  final AppStyle? appStyle;
  final ValueChanged<AppStyle> onStyleChanged;

  const _Selector({
    required this.appStyle,
    required this.onStyleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: CupertinoCard(
            title: const Text('Tracking'),
            onTap: () => onStyleChanged(AppStyle.tracking),
            backgroundColor: appStyle == AppStyle.tracking
                ? theme.primaryColor
                : theme.hintColor,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: CupertinoCard(
            title: const Text('Quitting'),
            onTap: () => onStyleChanged(AppStyle.quitting),
            backgroundColor: appStyle == AppStyle.quitting
                ? theme.primaryColor
                : theme.hintColor,
          ),
        ),
      ],
    );
  }
}
