import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Constants/domain_values.dart';
import 'package:splitr/Utils/recap_persona_theme.dart';

void main() {
  test('shareGradient varies by persona type', () {
    final hero = RecapPersonaTheme.shareGradient(
      RecapPersonaTypes.settlementHero,
    );
    final steady = RecapPersonaTheme.shareGradient(
      RecapPersonaTypes.steadySplitter,
    );

    expect(hero.length, 3);
    expect(steady.length, 3);
    expect(hero.first, isNot(equals(steady.first)));
  });
}
