import 'package:material_ui/material_ui.dart';

@immutable
sealed class Result<T> {
  const Result();

  T? get valueOrNull => switch (this) {
    Success(:final value) => value,
    _ => null,
  };

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Object error, StackTrace stackTrace) onFailure,
  }) => switch (this) {
    Success(:final value) => onSuccess(value),
    Failure(:final error, :final stackTrace) => onFailure(error, stackTrace),
  };
}

class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

class Failure<T> extends Result<T> {
  const Failure(this.error, this.stackTrace);
  final Object error;
  final StackTrace stackTrace;
}
