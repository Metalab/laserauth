import 'dart:typed_data';

extension PairIterating<E> on Iterable<E> {
  Iterable<(E, E)> get pair => PairIterable._(this);
}

class PairIterable<E> extends Iterable<(E, E)> {
  PairIterable._(this.inner);
  final Iterable<E> inner;

  @override
  Iterator<(E, E)> get iterator => PairIterator._(inner.iterator);
}

class PairIterator<E> implements Iterator<(E, E)> {
  PairIterator._(this.inner);
  final Iterator<E> inner;

  late E left;

  @override
  (E, E) get current => (left, inner.current);

  @override
  bool moveNext() {
    if (!inner.moveNext()) {
      return false;
    }
    left = inner.current;
    return inner.moveNext();
  }
}

extension TryFirstWhere<E> on Iterable<E> {
  E? tryFirstWhere(bool Function(E element) test) {
    for (final item in this) {
      if (test(item)) {
        return item;
      }
    }
    return null;
  }
}

Uint8List hexStringToUint8List(String hex) {
  int length = hex.length;
  Uint8List bytes = Uint8List(length ~/ 2);
  for (int i = 0; i < length; i += 2) {
    int byteValue = int.parse(hex.substring(i, i + 2), radix: 16);
    bytes[i ~/ 2] = byteValue;
  }
  return bytes;
}
