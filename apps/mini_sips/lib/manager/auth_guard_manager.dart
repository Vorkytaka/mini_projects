import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../presentation/ui_dependencies.dart';
import 'auth_manager.dart';

class AuthGuardManager implements UiDependency {
  final GlobalKey<NavigatorState> navigatorKey;
  final AuthManager authManager;

  StreamSubscription? _authSubscription;

  AuthGuardManager({
    required this.navigatorKey,
    required this.authManager,
  });

  @override
  Future<void> init() async {
    _authSubscription = authManager.isAuthStream.listen((isAuth) {
      if (!isAuth) {
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/welcome',
          (route) => false,
        );
      }
    });
  }

  @override
  Future<void> dispose() async {
    await _authSubscription?.cancel();
  }
}
