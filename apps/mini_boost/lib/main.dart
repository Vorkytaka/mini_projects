import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:mini_design/base.dart';
import 'package:mini_design/components.dart';
import 'package:rxdart/rxdart.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

const String kGoalKey = 'goal';
const String kCurrentKey = 'current';

const String kAppGroup = 'group.tv.vrk.mini.boost';
const String kIOSWidgetName = 'Widgets';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await StreamingSharedPreferences.instance;
  HomeWidgetManager(sharedPreferences: sharedPreferences).init();
  runApp(App(sharedPreferences: sharedPreferences));
}

class SharedPreferencesWidget extends InheritedWidget {
  final StreamingSharedPreferences sharedPreferences;

  const SharedPreferencesWidget({
    required this.sharedPreferences,
    required super.child,
    super.key,
  });

  @override
  bool updateShouldNotify(SharedPreferencesWidget oldWidget) => false;

  static StreamingSharedPreferences preferences(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<SharedPreferencesWidget>()!
        .sharedPreferences;
  }

  static Preference<int> goal(BuildContext context) {
    return preferences(context).getInt(kGoalKey, defaultValue: 0);
  }

  static Preference<int> currentLeft(BuildContext context) {
    return preferences(context).getInt(kCurrentKey, defaultValue: -1);
  }
}

class HomeWidgetManager {
  final StreamingSharedPreferences sharedPreferences;

  const HomeWidgetManager({
    required this.sharedPreferences,
  });

  Future<void> init() async {
    await HomeWidget.setAppGroupId(kAppGroup);

    final goalPref = sharedPreferences.getInt(kGoalKey, defaultValue: 0);
    final currentPref = sharedPreferences.getInt(kCurrentKey, defaultValue: -1);

    goalPref.listen((value) {
      HomeWidget.saveWidgetData(kGoalKey, value)
          .then((value) => HomeWidget.updateWidget(iOSName: kIOSWidgetName));
    });

    currentPref.listen((value) {
      HomeWidget.saveWidgetData(kCurrentKey, value)
          .then((value) => HomeWidget.updateWidget(iOSName: kIOSWidgetName));
    });
  }
}

class App extends StatelessWidget {
  final StreamingSharedPreferences sharedPreferences;

  const App({
    required this.sharedPreferences,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SharedPreferencesWidget(
      sharedPreferences: sharedPreferences,
      child: MaterialApp(
        theme: miniThemeFactory(
          brightness: Brightness.light,
          primaryColor: Colors.blue,
        ),
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RevertBackgroundTheme(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              largeTitle: Text('Сводка'),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Body(),
            ),
          ],
        ),
      ),
    );
  }
}

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    final goalPref = SharedPreferencesWidget.goal(context);
    final currentPref = SharedPreferencesWidget.currentLeft(context);
    final confettiController =
        ConfettiController(duration: const Duration(seconds: 5));

    return ConfettiWidget(
      confettiController: confettiController,
      blastDirectionality: BlastDirectionality.explosive,
      shouldLoop: false,
      colors: const [
        Colors.green,
        Colors.blue,
        Colors.pink,
        Colors.orange,
        Colors.purple
      ],
      numberOfParticles: 30,
      blastDirection: pi / 2,
      child: StreamBuilder(
        stream: CombineLatestStream.combine2(
          goalPref,
          currentPref,
          (goal, current) => (goal, current),
        ),
        initialData: (goalPref.getValue(), currentPref.getValue()),
        builder: (context, snapshot) {
          final data = snapshot.data!;

          final theme = Theme.of(context);

          final goal = data.$1;
          final current = data.$2;

          if (goal == 0) {
            return const SetGoalBody();
          }

          return Padding(
            padding: kGroupHorizontalPadding.copyWith(
              top: 12,
            ),
            child: MiniGroup(
              footer: const Text(
                  'Регулярные тренировки в спортзале укрепляют тело, повышают выносливость, улучшают обмен веществ и снижают стресс. Это инвестиция в ваше будущее здоровье.'),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox.square(
                            dimension: 240,
                            child: CircularProgressIndicator(
                              value: 1 - current / goal,
                              strokeCap: StrokeCap.round,
                              color: theme.colorScheme.primary,
                              backgroundColor:
                                  theme.colorScheme.primary.withOpacity(0.2),
                              strokeWidth: 24,
                              strokeAlign: -1,
                            ),
                          ),
                          Text.rich(
                            TextSpan(
                              children: [
                                const TextSpan(text: 'Осталось\n'),
                                TextSpan(
                                  text: '$current',
                                  style: theme.textTheme.headline?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const TextSpan(text: '  из '),
                                TextSpan(
                                  text: '$goal',
                                  style: theme.textTheme.title?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const TextSpan(text: '\nтренировок'),
                              ],
                            ),
                            style: theme.textTheme.body,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: CupertinoButton.filled(
                      child: const Text('Я потренировалась'),
                      onPressed: () {
                        SystemSound.play(SystemSoundType.click);

                        final newCurrent = current - 1;
                        final isTen =
                            checkTransition(goal, current, newCurrent);

                        if (isTen) {
                          confettiController.play();
                        }

                        if (newCurrent <= 0) {
                          goalPref.setValue(0);
                          currentPref.setValue(-1);
                        } else {
                          currentPref.setValue(newCurrent);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class SetGoalBody extends StatelessWidget {
  const SetGoalBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Column(
                  children: [
                    HintItem(
                      icon: Text('🏅'),
                      title: Text('Отслеживайте прогресс'),
                      description: Text(
                          'Наше приложение подсчитывает и показывает, сколько осталось тренировок до конца года.'),
                    ),
                    SizedBox(height: 32),
                    HintItem(
                      icon: Text('🏊‍♀️'),
                      title: Text('Регулярные тренировки'),
                      description: Text(
                          'Приложение помогает вам не пропускать тренировки и держать ритм.'),
                    ),
                    SizedBox(height: 32),
                    HintItem(
                      icon: Text('🎯'),
                      title: Text('Мотивирует на успех'),
                      description: Text(
                          'Визуализация прогресса способствует поддержанию мотивации и улучшению результатов.'),
                    ),
                  ],
                ),
              ),
            ),
            CupertinoButton.filled(
              child: const Text('Установить цель'),
              onPressed: () {
                final goalPref = SharedPreferencesWidget.goal(context);
                final currentPref =
                    SharedPreferencesWidget.currentLeft(context);

                showSelectGoalDialog(context: context).then(
                  (goal) {
                    if (goal != null) {
                      goalPref.setValue(goal);
                      currentPref.setValue(goal);
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class HintItem extends StatelessWidget {
  final Widget icon;
  final Widget title;
  final Widget description;

  const HintItem({
    required this.icon,
    required this.title,
    required this.description,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        DefaultTextStyle.merge(
          style: const TextStyle(fontSize: 56),
          child: icon,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DefaultTextStyle.merge(
                style:
                    theme.textTheme.body?.copyWith(fontWeight: FontWeight.bold),
                child: title,
              ),
              const SizedBox(height: 4),
              DefaultTextStyle.merge(
                style: theme.textTheme.body?.copyWith(height: 1.4),
                child: description,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<int?> showSelectGoalDialog({
  required BuildContext context,
}) {
  return showAdaptiveDialog<int>(
    context: context,
    builder: (context) => const SelectGoalDialog(),
  );
}

class SelectGoalDialog extends StatefulWidget {
  const SelectGoalDialog({super.key});

  @override
  State<SelectGoalDialog> createState() => _SelectGoalDialogState();
}

class _SelectGoalDialogState extends State<SelectGoalDialog> {
  int? _goal;

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: const Text('Давай установим цель'),
      content: Column(
        children: [
          const SizedBox(height: 12),
          const Text('Как много тренеровок ты хочешь провести до конца года?'),
          const SizedBox(height: 12),
          CupertinoTextField(
            placeholder: '100',
            keyboardType: TextInputType.number,
            autofocus: true,
            onChanged: (str) {
              final goal = int.tryParse(str);
              if (goal != null && goal > 0) {
                _goal = goal;
              } else {
                _goal = null;
              }
              setState(() {});
            },
          ),
        ],
      ),
      actions: [
        CupertinoDialogAction(
          onPressed:
              _goal == null ? null : () => Navigator.of(context).pop(_goal),
          child: const Text('Принять'),
        ),
      ],
    );
  }
}

/// Проверяет, если переход от [current] к [newCurrent] перешагнул 10% от [goal]
bool checkTransition(int goal, int current, int newCurrent) {
  for (int i = 10; i <= 100; i += 10) {
    int checkPoint = (goal * i) ~/ 100;
    if (current > checkPoint && newCurrent <= checkPoint) {
      return true;
    }
  }
  return false;
}
