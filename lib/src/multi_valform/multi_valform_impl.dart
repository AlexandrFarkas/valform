import 'package:valform/src/multi_valform/multi_valform.dart';

typedef OnInvalidKey = bool Function(
    dynamic key, dynamic ownerId, Map cells, Function(bool) setIsSealed);

class MultiValformImpl<T> implements MultiValform<T> {
  final _cells = {};
  final T? _value;

  bool _isSealed;

  final OnInvalidKey? _handler;

  MultiValformImpl(OnInvalidKey handler, [T? value])
      : _handler = handler,
        _value = value,
        _isSealed = false;

  @override
  bool get isSealed => _isSealed;
  @override
  bool get isNotSealed => !isSealed;

  /// If owner doesn't have their cell,
  /// they can choose any key and assign it to cell.
  ///
  /// While owner accesses with initial key and valform remains [isNotSealed], it returns [_value]
  /// if owner loses the key and tries to peek with different key,
  /// see [AccessStrategy]
  @override
  T? access(key, {required ownerId}) {
    final isAllowed = _checkValidity(key, ownerId) && !_isSealed;
    if (T == dynamic && _value == null) {
      if (isAllowed) {
        return true as T;
      } else {
        return false as T;
      }
    } else {
      if (isAllowed) {
        return _value;
      } else {
        return null;
      }
    }
  }

  bool _checkValidity(key, ownerId) {
    final savedKey = _cells[ownerId];
    if (savedKey == null) {
      _cells[ownerId] = key;
    }

    final handler = _handler;
    if (_cells[ownerId] != key && handler != null) {
      return handler.call(key, ownerId, _cells, (isSealed) => _isSealed = isSealed);
      // switch (strategy) {
      //   case AccessStrategy.reproduce:
      //     return false;
      //   case AccessStrategy.sealOnFailure:
      //     _isSealed = true;
      //     break;
      //   case AccessStrategy.expelOnFailure:
      //     _cells[ownerId] = _expelled;
      //     return false;
      // }
    }
    return !_isSealed;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MultiValformImpl &&
            runtimeType == other.runtimeType

            /// 1) Events not spent are never considered equal to any other,
            /// and they will always "fire", forcing the widget to rebuild.
            /// 2) Spent events are considered "empty", so they are all equal.
            &&
            (isSealed && other.isSealed);
  }

  /// 1) If two objects are equal according to the equals method, then hashcode of both must
  /// be the same. Since spent events are all equal, they should produce the same hashcode.
  /// 2) If two objects are NOT equal, hashcode may be the same or not, but it's better
  /// when they are not the same. However, events are mutable, and this could mean the hashcode
  /// of the state could be changed when an event is consumed. To avoid this, we make events
  /// always return the same hashCode.
  @override
  int get hashCode => 0;
}