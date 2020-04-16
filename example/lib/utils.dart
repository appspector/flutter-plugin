class DataObservable<T> {

  T _value;

  Function(T) observer;

  void setValue(T value) {
    this._value = value;
    if (observer != null) {
      observer(value);
    }
  }

  T getValue() => _value;

}
