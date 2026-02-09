import 'dart:async';

import 'package:signals/signals.dart';

class FutureHandler<T> {
  final AsyncSignal<T> asyncState;
  Future<T> futureFunction;
  FutureOr<void> Function(T)? onValue;
  void Function(Object e, StackTrace s)? catchError;

  FutureHandler({
    required this.asyncState,
    required this.futureFunction,
    this.onValue,
    this.catchError,
  });

  Future<void> call() async {
    asyncState.value = AsyncLoading<T>();
    await futureFunction
        .then((T response) async {
          asyncState.value = AsyncData(response);
          if (onValue != null) await onValue!(response);
        })
        .catchError((Object e, StackTrace s) {
          asyncState.value = AsyncError(e, s);
          if (catchError != null) catchError!(e, s);
          throw e;
        });
  }
}
