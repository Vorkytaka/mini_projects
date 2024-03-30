import 'package:flutter/cupertino.dart' hide CupertinoTextField;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../../common/bloc_effect.dart';
import '../../dependencies.dart';
import '../../domain/user_data.dart';
import '../common/cupertino_text_field.dart';
import 'user_data_cubit.dart';

class UserDataScreen extends StatelessWidget {
  const UserDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final dependencies = context.read<Dependencies>();
        return UserDataScreenCubit(authManager: dependencies.authManager);
      },
      child: BlocEffectListener<UserDataScreenCubit, UserDataScreenState,
          UserDataScreenEffect>(
        onEffect: (context, effect) {
          switch (effect) {
            case UserDataScreenEffect.success:
              Navigator.of(context).pop();
          }
        },
        child: const _Screen(),
      ),
    );
  }
}

class _Screen extends StatelessWidget {
  const _Screen();

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);

    return Scaffold(
      appBar: CupertinoNavigationBar(
        middle: const Text('Данные пользователя'),
        trailing: CupertinoButton(
          onPressed: () => context.read<UserDataScreenCubit>().submit(),
          padding: EdgeInsets.zero,
          child: const Text('Сохранить'),
        ),
      ),
      body: ListView(
        physics: const ScrollPhysics(),
        children: [
          CupertinoListSection.insetGrouped(
            backgroundColor: Colors.transparent,
            additionalDividerMargin: 0,
            footer: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DefaultTextStyle(
                style: cupertinoTheme.textTheme.textStyle.merge(
                  TextStyle(
                    fontSize: 12,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
                child: const Text(
                    'Ваши данные не обязательны, но помогают нам персонализировать ваш опыт использования. Ваша информация остается конфиденциальной.'),
              ),
            ),
            children: [
              CupertinoTextField(
                title: const Text('Вес'),
                onChanged: (str) =>
                    context.read<UserDataScreenCubit>().updateWeight(str),
              ),
              CupertinoTextField(
                title: const Text('Рост'),
                onChanged: (str) =>
                    context.read<UserDataScreenCubit>().updateHeight(str),
              ),
              CupertinoTextField(
                title: const Text('Возраст'),
                onChanged: (str) =>
                    context.read<UserDataScreenCubit>().updateAge(str),
              ),
              CupertinoListTile(
                title: const Text('Пол'),
                trailing: PullDownButton(
                  itemBuilder: (context) => [
                    for (final sex in BiologicalSex.values)
                      PullDownMenuItem(
                        onTap: () =>
                            context.read<UserDataScreenCubit>().updateSex(sex),
                        title: sex.name,
                      ),
                  ],
                  buttonBuilder: (context, showMenu) => BlocSelector<
                      UserDataScreenCubit, UserDataScreenState, BiologicalSex>(
                    selector: (state) => state.sex,
                    builder: (context, sex) => CupertinoButton(
                      onPressed: showMenu,
                      child: Text(sex.name),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
