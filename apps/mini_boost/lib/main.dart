import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:mini_design/base.dart';
import 'package:mini_design/components.dart';
import 'package:rxdart/rxdart.dart';
import 'package:streaming_shared_preferences/streaming_shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await StreamingSharedPreferences.instance;
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
    return preferences(context).getInt('goal', defaultValue: 0);
  }

  static Preference<int> howManyLeft(BuildContext context) {
    return preferences(context).getInt('how_many_left', defaultValue: -1);
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
        body: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              largeTitle: Text('miniBoost'),
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
    final howManyPref = SharedPreferencesWidget.howManyLeft(context);

    return Column(
      children: [
        StreamBuilder(
          stream: CombineLatestStream.combine2(
            goalPref,
            howManyPref,
            (goal, howMany) => (goal, howMany),
          ),
          initialData: (goalPref.getValue(), howManyPref.getValue()),
          builder: (context, snapshot) {
            final data = snapshot.data!;

            final theme = Theme.of(context);

            final goal = data.$1;
            final howMany = data.$2;

            if (goal == 0) {
              return Padding(
                padding: const EdgeInsets.all(12),
                child: CupertinoButton.filled(
                  child: const Text('Установить цель'),
                  onPressed: () {
                    final goalPref = SharedPreferencesWidget.goal(context);
                    final howManyLeftPref =
                        SharedPreferencesWidget.howManyLeft(context);

                    showSelectGoalDialog(context: context).then(
                      (goal) {
                        if (goal != null) {
                          goalPref.setValue(goal);
                          howManyLeftPref.setValue(goal);
                        }
                      },
                    );
                  },
                ),
              );
            }

            return Padding(
              padding: kGroupHorizontalPadding.copyWith(
                top: 12,
              ),
              child: MiniGroup(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MiniListTile(
                      leading: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: howMany / goal,
                            strokeCap: StrokeCap.round,
                            backgroundColor: Colors.red,
                            strokeWidth: 6,
                          ),
                          Icon(
                            Icons.fitness_center_rounded,
                            color: theme.colorScheme.primary,
                          )
                        ],
                      ),
                      title: Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(text: 'Осталось '),
                            TextSpan(
                              text: '$howMany',
                              style: theme.textTheme.title,
                            ),
                            TextSpan(text: ' из $goal'),
                          ],
                        ),
                        style: theme.textTheme.body,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: CupertinoButton.filled(
                        child: const Text('Я потренировалась'),
                        onPressed: () {
                          SystemSound.play(SystemSoundType.click);

                          final newHowMany = howMany - 1;
                          if (newHowMany <= 0) {
                            goalPref.setValue(0);
                            howManyPref.setValue(-1);
                          } else {
                            howManyPref.setValue(newHowMany);
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
              if (goal != null) {
                setState(() {
                  _goal = goal;
                });
              }
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
