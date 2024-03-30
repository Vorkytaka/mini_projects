import 'dart:async';

import 'package:flutter/foundation.dart';

typedef FEither<L, R> = Future<Either<L, R>>;

/// Class that represent either [L] left or [R] right value.
@immutable
abstract class Either<L, R> {
  const Either._();

  factory Either.right(R value) => Right<L, R>(value);

  factory Either.left(L value) => Left<L, R>(value);

  T fold<T>({
    required T Function(L value) ifLeft,
    required T Function(R value) ifRight,
  });

  Either<L, T> flatMap<T>(Either<L, T> Function(R value) f);

  Either<L, T> map<T>(T Function(R value) f);
}

@immutable
class Left<L, R> extends Either<L, R> {
  const Left(this.value) : super._();

  final L value;

  @override
  String toString() => 'Left<$L>($value)';

  @override
  T fold<T>({
    required T Function(L value) ifLeft,
    required T Function(R value) ifRight,
  }) {
    return ifLeft(value);
  }

  @override
  Either<L, T> flatMap<T>(Either<L, T> Function(R value) f) {
    return Left<L, T>(value);
  }

  @override
  Either<L, T> map<T>(T Function(R value) f) {
    return Left<L, T>(value);
  }

  @override
  bool operator ==(Object other) => other is Left<L, R> && value == other.value;

  @override
  int get hashCode => value.hashCode;
}

@immutable
class Right<L, R> extends Either<L, R> {
  const Right(this.value) : super._();

  final R value;

  @override
  String toString() => 'Right<$R>($value)';

  @override
  T fold<T>({
    required T Function(L value) ifLeft,
    required T Function(R value) ifRight,
  }) {
    return ifRight(value);
  }

  @override
  Either<L, T> flatMap<T>(Either<L, T> Function(R value) f) {
    return f(value);
  }

  @override
  Either<L, T> map<T>(T Function(R value) f) {
    return flatMap((value) => Either.right(f(value)));
  }

  @override
  bool operator ==(Object other) =>
      other is Right<L, R> && value == other.value;

  @override
  int get hashCode => value.hashCode;
}

extension FutureEitherUtils<L, R> on Future<Either<L, R>> {
  Future<T> fold<T>({
    required T Function(L value) ifLeft,
    required T Function(R value) ifRight,
  }) =>
      then((value) => value.fold(ifLeft: ifLeft, ifRight: ifRight));

  Future<Either<L, T>> flatMap<T>(Either<L, T> Function(R value) f) =>
      then((value) => value.flatMap(f));

  Future<Either<L, T>> map<T>(T Function(R value) f) =>
      then((value) => value.map(f));
}
