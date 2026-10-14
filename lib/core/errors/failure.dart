/// Ek simple error type. Poore app me errors isi format me handle honge.
/// (fpdart ke Either ke saath: Left = Failure, Right = success data)
class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}