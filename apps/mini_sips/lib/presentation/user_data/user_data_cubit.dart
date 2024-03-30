import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/bloc_effect.dart';
import '../../common/either.dart';
import '../../domain/user_data.dart';
import '../../manager/auth_manager.dart';

enum UserDataScreenEffect {
  success,
}

class UserDataScreenCubit extends Cubit<UserDataScreenState>
    with BlocEffectStream<UserDataScreenState, UserDataScreenEffect> {
  final AuthManager authManager;

  UserDataScreenCubit({
    required this.authManager,
  }) : super(const UserDataScreenState.init());

  void updateWeight(String? weightStr) {
    final weight = double.tryParse(weightStr?.replaceAll(',', '.') ?? '');
    emit(UserDataScreenState(
      weight: weight,
      height: state.height,
      age: state.age,
      sex: state.sex,
    ));
  }

  void updateHeight(String? heightStr) {
    final height = double.tryParse(heightStr?.replaceAll(',', '.') ?? '');
    emit(UserDataScreenState(
      weight: state.weight,
      height: height,
      age: state.age,
      sex: state.sex,
    ));
  }

  void updateAge(String? ageStr) {
    final age = int.tryParse(ageStr ?? '');
    emit(UserDataScreenState(
      weight: state.weight,
      height: state.height,
      age: age,
      sex: state.sex,
    ));
  }

  void updateSex(BiologicalSex sex) => emit(UserDataScreenState(
        weight: state.weight,
        height: state.height,
        age: state.age,
        sex: sex,
      ));

  void submit() {
    authManager
        .setUserData(
          weight: state.weight,
          height: state.height,
          age: state.age,
          sex: state.sex,
        )
        .fold(
          ifLeft: (e) {},
          ifRight: (_) {
            sendEffect(UserDataScreenEffect.success);
          },
        );
  }
}

@immutable
class UserDataScreenState {
  final double? weight;
  final double? height;
  final int? age;
  final BiologicalSex sex;

  const UserDataScreenState({
    required this.weight,
    required this.height,
    required this.age,
    required this.sex,
  });

  const UserDataScreenState.init()
      : weight = null,
        height = null,
        age = null,
        sex = BiologicalSex.notDefine;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserDataScreenState &&
          runtimeType == other.runtimeType &&
          weight == other.weight &&
          height == other.height &&
          age == other.age &&
          sex == other.sex;

  @override
  int get hashCode =>
      weight.hashCode ^ height.hashCode ^ age.hashCode ^ sex.hashCode;
}
