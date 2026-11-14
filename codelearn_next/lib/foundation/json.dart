typedef JsonMap = Map<String, Object?>;

JsonMap jsonMap(Object? value) => value is Map
    ? value.map((key, value) => MapEntry(key.toString(), value))
    : <String, Object?>{};

List<Object?> jsonList(Object? value) => value is List ? value : const [];
String jsonString(Object? value, [String fallback = '']) =>
    value is String ? value : fallback;
int jsonInt(Object? value, [int fallback = 0]) =>
    value is num ? value.toInt() : fallback;
bool jsonBool(Object? value) => value == true;
DateTime? jsonDate(Object? value) =>
    value is String ? DateTime.tryParse(value) : null;

class AppFailure implements Exception {
  final String code;
  const AppFailure(this.code);
  @override
  String toString() => code;
}
