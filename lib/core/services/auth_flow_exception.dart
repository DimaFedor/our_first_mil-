class AuthFlowException implements Exception {
  final String code;
  final String message;

  const AuthFlowException({required this.code, required this.message});

  @override
  String toString() => '$code: $message';
}
