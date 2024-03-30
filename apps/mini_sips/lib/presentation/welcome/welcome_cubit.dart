import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/either.dart';
import '../../manager/auth_manager.dart';

class WelcomeCubit extends Cubit<WelcomeStatus> {
  final AuthManager authManager;

  WelcomeCubit({
    required this.authManager,
  }) : super(WelcomeStatus.idle);

  Future<void> auth() async {
    emit(WelcomeStatus.loading);

    await authManager.signInAnon().fold(
      ifLeft: (e) {
        emit(WelcomeStatus.fail);
      },
      ifRight: (_) {
        emit(WelcomeStatus.success);
      },
    );
  }
}

enum WelcomeStatus {
  idle,
  loading,
  success,
  fail,
}
