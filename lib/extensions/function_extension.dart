/// An extension on [Function] that provides a method to call functions
/// safely, which means if the function throws an error, it will catch that
/// error and return `null`, instead of letting the error propagate.
///
/// This can be useful when working with functions that may throw exceptions
/// but you don't want to handle those exceptions explicitly or when you
/// prefer to deal with a `null` return value in the case of an error.
extension TryOrNull on Function {
  /// Calls the function safely and returns the result of the function if it's
  /// successful, or `null` if an error occurs.
  ///
  /// Here, `T` represents the expected return type of the function.
  ///
  /// Example:
  /// ```dart
  /// Function riskyFunction = () => throw Exception('Oops!');
  /// final result = riskyFunction.callSafely(); // result will be `null`.
  /// ```
  T? callSafely<T>() {
    try {
      return this.call() as T;
    } catch (e) {
      return null;
    }
  }
}
