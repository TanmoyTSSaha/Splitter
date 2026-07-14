import 'package:flutter_test/flutter_test.dart';
import 'package:splitr/Model/product_category_model.dart';

void main() {
  test('CategoryOnlyModel round-trips through JSON', () {
    final model = CategoryOnlyModel(
      category: 'Food',
      categoryLogo: 'https://example.com/food.svg',
    );
    final restored = CategoryOnlyModel.fromJSON(model.toJSON());
    expect(restored.category, 'Food');
    expect(restored.categoryLogo, 'https://example.com/food.svg');
  });

  test('feature request row uses vote_count not votes', () {
    final row = {
      'id': 'abc',
      'title': 'Dark mode',
      'vote_count': 12,
      'created_at': '2026-07-01T00:00:00Z',
    };
    expect(row['vote_count'], 12);
    expect(row.containsKey('votes'), isFalse);
  });
}
