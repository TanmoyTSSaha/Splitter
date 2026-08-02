import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

const _mockSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48">
  <rect width="48" height="48" fill="#cccccc"/>
</svg>
''';

/// Smallest valid 1x1 PNG (transparent).
final Uint8List _transparentPng = Uint8List.fromList(<int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);

/// Stubs network image/SVG fetches in widget tests.
class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return MockHttpClient();
  }
}

class MockHttpClient extends Fake implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return MockHttpClientRequest(url);
  }

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return MockHttpClientRequest(url);
  }
}

class MockHttpClientRequest extends Fake implements HttpClientRequest {
  MockHttpClientRequest(this.uri);

  final Uri uri;

  @override
  Future<HttpClientResponse> close() async {
    return MockHttpClientResponse(uri);
  }
}

class MockHttpClientResponse extends Fake implements HttpClientResponse {
  MockHttpClientResponse(this.uri);

  final Uri uri;

  @override
  int get statusCode => 200;

  @override
  int get contentLength => _bodyBytes.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<Uint8List> listen(
    void Function(Uint8List event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<Uint8List>.value(_bodyBytes).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  Uint8List get _bodyBytes {
    final path = uri.path.toLowerCase();
    if (path.endsWith('.svg') || uri.toString().contains('dicebear')) {
      return Uint8List.fromList(_mockSvg.codeUnits);
    }
    return _transparentPng;
  }
}

/// Runs [body] with [MockHttpOverrides] active.
Future<T> runWithMockHttp<T>(Future<T> Function() body) async {
  final previous = HttpOverrides.current;
  HttpOverrides.global = MockHttpOverrides();
  try {
    return await body();
  } finally {
    HttpOverrides.global = previous;
  }
}
