extension ListUtils<E> on List<E> {
  /// Return new [List] with elements separated by [separator]
  List<E> interpose(E separator) {
    if (isEmpty) {
      return this;
    }

    final list = <E>[];
    final iterator = this.iterator;

    if (iterator.moveNext()) {
      list.add(iterator.current);
      while (iterator.moveNext()) {
        list.add(separator);
        list.add(iterator.current);
      }
    }

    return list;
  }
}
