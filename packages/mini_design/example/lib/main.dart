import 'package:example/components_page.dart';
import 'package:flutter/material.dart';
import 'package:mini_design/base.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'miniDesign',
      theme: miniThemeFactory(
        brightness: Brightness.light,
        primaryColor: Colors.purple,
      ),
      routes: {
        HomePage.path: (context) => const HomePage(),
        ComponentsPage.path: (context) => const ComponentsPage(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  static const path = Navigator.defaultRouteName;

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('miniDesign')),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(ComponentsPage.path),
            child: const Text('Components'),
          ),
        ],
      ),
    );
  }
}
