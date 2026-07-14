/// Safe numeric parsing for JSON / Postgres values that may be int or double.
double asDouble(dynamic value, [double fallback = 0.0]) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

int asInt(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

Map<String, double> asDoubleMap(Map<String, dynamic> source) {
  return source.map((key, value) => MapEntry(key, asDouble(value)));
}
