/// A condition that returns true/false.
typedef Condition = bool Function();

/// Called when data is emitted.
typedef OnData<T> = void Function(T data);

/// A generic void callback.
typedef Callback = void Function();
