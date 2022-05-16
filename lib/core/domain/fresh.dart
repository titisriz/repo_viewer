import 'package:freezed_annotation/freezed_annotation.dart';

part 'fresh.freezed.dart';

@freezed
abstract class Fresh<T> with _$Fresh<T> {
  const Fresh._();
  const factory Fresh({
    required T entity,
    required bool isFresh,
    bool? isNextPageAvailable,
  }) = _Fresh<T>;

  factory Fresh.yes(
    T entity, {
    bool? isNextpageAvailable,
  }) =>
      Fresh(
        entity: entity,
        isFresh: true,
        isNextPageAvailable: isNextpageAvailable,
      );
  factory Fresh.no(
    T entity, {
    bool? isNextpageAvailable,
  }) =>
      Fresh(
        entity: entity,
        isFresh: false,
        isNextPageAvailable: isNextpageAvailable,
      );
}