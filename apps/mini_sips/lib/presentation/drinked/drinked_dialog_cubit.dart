import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../common/bloc_effect.dart';
import '../../common/either.dart';
import '../../domain/alcohol.dart';
import '../../manager/data_manager.dart';
import '../../manager/location_manager.dart';

enum DrinkedDialogEffect {
  success,
}

class DrinkedDialogCubit extends Cubit<DrinkedDialogState>
    with BlocEffectStream<DrinkedDialogState, DrinkedDialogEffect> {
  final DataManager dataManager;
  final LocationManager locationManager;

  StreamSubscription? _permissionSubscription;

  DrinkedDialogCubit({
    required this.dataManager,
    required this.locationManager,
  }) : super(const DrinkedDialogState.init());

  Future<void> init() async {
    _permissionSubscription = locationManager.permissionStream
        .map((permission) =>
            permission != LocationPermission.denied &&
            permission != LocationPermission.deniedForever)
        .listen((isGranted) {
      emit(state.copyWith(isLocationPermissionGranted: isGranted));
    });

    await locationManager.getLocation().then((location) {
      if (location != null) {
        emit(state.copyWith(location: location));
      }
    });
  }

  @override
  Future<void> close() async {
    await _permissionSubscription?.cancel();
    return super.close();
  }

  void setAlcohol(AlcoholUI alcohol) => emit(state.copyWith(alcohol: alcohol));

  void setAlcoholByVolume(double alcoholByVolume) =>
      emit(state.copyWith(alcoholByVolume: alcoholByVolume));

  void setVolume(int volume) => emit(state.copyWith(volume: volume));

  void setNote(String note) => emit(state.copyWith(note: note));

  void setPrice(double price) => emit(state.copyWith(price: price));

  void setTrackLocation({required bool trackLocation}) =>
      emit(state.copyWith(trackLocation: trackLocation));

  Future<void> add() async {
    emit(state.copyWith(status: DrinkedDialogStatus.loading));

    final alcohol = Alcohol(
      id: state.alcohol.id,
      alcoholByVolume: state.alcoholByVolume,
      volume: state.volume,
      datetime: DateTime.timestamp(),
      note: state.note,
      price: state.price,
      location: state.trackLocation ? state.location : null,
    );

    await dataManager.addDrink(alcohol).fold(
      ifLeft: (_) {
        emit(state.copyWith(status: DrinkedDialogStatus.fail));
      },
      ifRight: (_) {
        sendEffect(DrinkedDialogEffect.success);
        emit(state.copyWith(status: DrinkedDialogStatus.success));
      },
    );
  }
}

enum DrinkedDialogStatus {
  idle,
  loading,
  success,
  fail,
}

@immutable
class DrinkedDialogState {
  final DrinkedDialogStatus status;
  final AlcoholUI alcohol;
  final double? alcoholByVolume;
  final int? volume;
  final String? note;
  final double? price;
  final GeoPoint? location;
  final bool trackLocation;

  final bool isLocationPermissionGranted;

  const DrinkedDialogState({
    required this.status,
    required this.alcohol,
    required this.alcoholByVolume,
    required this.volume,
    required this.note,
    required this.price,
    required this.location,
    required this.trackLocation,
    required this.isLocationPermissionGranted,
  });

  const DrinkedDialogState.init()
      : status = DrinkedDialogStatus.idle,
        alcohol = AlcoholUI.any,
        alcoholByVolume = null,
        volume = null,
        note = null,
        price = null,
        location = null,
        trackLocation = true,
        isLocationPermissionGranted = true;

  DrinkedDialogState copyWith({
    DrinkedDialogStatus? status,
    AlcoholUI? alcohol,
    double? alcoholByVolume,
    int? volume,
    String? note,
    double? price,
    GeoPoint? location,
    bool? trackLocation,
    bool? isLocationPermissionGranted,
  }) =>
      DrinkedDialogState(
        status: status ?? this.status,
        alcohol: alcohol ?? this.alcohol,
        alcoholByVolume: alcoholByVolume ?? this.alcoholByVolume,
        volume: volume ?? this.volume,
        note: note ?? this.note,
        price: price ?? this.price,
        location: location ?? this.location,
        trackLocation: trackLocation ?? this.trackLocation,
        isLocationPermissionGranted:
            isLocationPermissionGranted ?? this.isLocationPermissionGranted,
      );
}
