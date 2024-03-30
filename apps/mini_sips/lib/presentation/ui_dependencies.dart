import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../dependencies.dart';
import '../manager/auth_guard_manager.dart';
import 'platform/platform.dart';

abstract class UiDependency {
  Future<void> init();

  Future<void> dispose();
}

abstract class UiDependencies {
  GlobalKey<NavigatorState> get navigatorKey;

  AuthGuardManager get authGuardManager;
}

class UiDependenciesImpl implements UiDependencies, UiDependency {
  final Dependencies dependencies;

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  UiDependenciesImpl({
    required this.dependencies,
    required this.navigatorKey,
  });

  @override
  Future<void> init() async {
    await authGuardManager.init();
  }

  @override
  Future<void> dispose() async {
    await authGuardManager.dispose();
  }

  @override
  late final AuthGuardManager authGuardManager = AuthGuardManager(
    navigatorKey: navigatorKey,
    authManager: dependencies.authManager,
  );
}

class UiDependenciesWidget extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;
  final Dependencies dependencies;

  const UiDependenciesWidget({
    required this.child,
    required this.navigatorKey,
    required this.dependencies,
    super.key,
  });

  @override
  State<UiDependenciesWidget> createState() => _UiDependenciesWidgetState();
}

class _UiDependenciesWidgetState extends State<UiDependenciesWidget> {
  late final uiDependencies = UiDependenciesImpl(
    dependencies: widget.dependencies,
    navigatorKey: widget.navigatorKey,
  );

  @override
  void initState() {
    super.initState();
    uiDependencies.init();
  }

  @override
  void dispose() {
    uiDependencies.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<UiDependencies>.value(
      value: uiDependencies,
      child: PlatformProviderHolder(
        platform: TargetPlatform.iOS,
        child: widget.child,
      ),
    );
  }
}
