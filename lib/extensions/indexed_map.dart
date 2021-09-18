extension IndexedMap on Iterable {
  Iterable<T> indexedMap<T>(T Function(dynamic, int) f) {
    int count = 0;
    return this.map((item) {
      return f(item, count++);
    });
  }
}
