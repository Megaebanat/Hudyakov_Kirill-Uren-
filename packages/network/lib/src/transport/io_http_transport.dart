import 'dart:async' as async;
import 'dart:convert';
import 'dart:io';

import '../errors/network_exception.dart';
import 'http_request.dart';
import 'http_transport.dart';

/// Реализация [HttpTransport] на базе `dart:io` (стандартная библиотека Dart).
///
/// Ответственность (SRP): преобразование [HttpRequest] в вызов [HttpClient]
/// и обратно + трансформация транспортных ошибок (SocketException, таймауты)
/// в типизированные [NetworkException]. Никакой бизнес-логики не содержит.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class IoHttpTransport implements HttpTransport {
  /// HTTP-клиент стандартной библиотеки (может быть подменён тестовым).
  final HttpClient _client;

  /// Таймаут установки соединения.
  final Duration connectTimeout;

  /// Таймаут ожидания ответа.
  final Duration receiveTimeout;

  /// Создаёт транспорт на dart:io.
  ///
  /// [connectTimeout] — таймаут соединения; [receiveTimeout] — таймаут ответа;
  /// [client] — готовый [HttpClient] (для тестов), иначе создаётся новый.
  IoHttpTransport({
    required this.connectTimeout,
    required this.receiveTimeout,
    HttpClient? client,
  }) : _client = client ?? (HttpClient()..connectionTimeout = connectTimeout);

  @override
  Future<HttpResponse> send(HttpRequest request) async {
    try {
      // Полный URI (base URL + путь) формируется в HttpClient — здесь отправка.
      final url = Uri.parse(request.path);

      final ioRequest =
          await _client.openUrl(request.method, url).timeout(connectTimeout);
      request.headers.forEach(ioRequest.headers.set);

      if (request.body != null) {
        ioRequest.write(jsonEncode(request.body));
      }

      final ioResponse = await ioRequest.close().timeout(receiveTimeout);
      final body = await ioResponse.transform(utf8.decoder).join();

      return HttpResponse(
        statusCode: ioResponse.statusCode,
        headers: _flattenHeaders(ioResponse.headers),
        body: body,
      );
    } on async.TimeoutException {
      throw const TimeoutException();
    } on SocketException {
      throw const ConnectionException();
    } on HttpException {
      throw const ConnectionException();
    } on HandshakeException {
      throw const ConnectionException();
    }
  }

  /// Приводит заголовки [io] dart:io к плоской Map<String, String>.
  ///
  /// [io] — заголовки ответа; значения склеиваются через запятую.
  Map<String, String> _flattenHeaders(HttpHeaders io) {
    final result = <String, String>{};
    io.forEach((name, values) {
      result[name] = values.join(', ');
    });
    return result;
  }
}
