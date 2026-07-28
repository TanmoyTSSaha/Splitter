import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Constants/app_strings.dart';

void main() {
  test('recapSquareFilename suffix distinguishes square export', () {
    const ts = 1234567890;
    final story = AppStringFormat.recapFilename(ts);
    final square = AppStringFormat.recapSquareFilename(ts);

    expect(square, contains('_square'));
    expect(square, isNot(equals(story)));
  });
}
