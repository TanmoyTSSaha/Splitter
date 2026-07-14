import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'helpers/mock_http_overrides.dart';

void main() {
  test('runWithMockHttp returns stub SVG bytes', () async {
    await runWithMockHttp(() async {
      final client = HttpClient();
      final request =
          await client.getUrl(Uri.parse('https://api.dicebear.com/test.svg'));
      final response = await request.close();
      expect(response.statusCode, 200);

      final bytes = <int>[];
      await for (final chunk in response) {
        bytes.addAll(chunk);
      }
      expect(String.fromCharCodes(bytes), contains('<svg'));
    });
  });

  test('runWithMockHttp returns stub PNG bytes for raster URLs', () async {
    await runWithMockHttp(() async {
      final client = HttpClient();
      final request =
          await client.getUrl(Uri.parse('https://example.com/avatar.png'));
      final response = await request.close();
      expect(response.statusCode, 200);

      final bytes = <int>[];
      await for (final chunk in response) {
        bytes.addAll(chunk);
      }
      expect(bytes.first, 0x89);
    });
  });
}
