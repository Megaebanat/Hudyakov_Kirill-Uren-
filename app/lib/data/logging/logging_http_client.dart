import 'package:network/network.dart';

import '../../common/logging/app_logger.dart';

/// Декоратор HTTP-клиента: централизованное логирование сетевых запросов.
///
/// Обязательные точки логирования по ТЗ:
///  * начало запроса — INFO;
///  * успешный ответ — DEBUG;
///  * ошибка/неуспешный статус — ERROR.
/// Формат: `[Тег_компонента]: Событие — Детали`.
///
/// Ответственность (SRP): единственная обязанность — журналирование запросов.
/// Реализован декоратором, поэтому не меняет поведение клиентов (OCP).
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class LoggingHttpClient implements HttpClient {
  /// Декорируемый клиент (REST или mock).
  final HttpClient inner;

  /// Создаёт логирующий декоратор.
  ///
  /// [inner] — клиент, выполняющий реальные запросы.
  LoggingHttpClient(this.inner);

  @override
  Future<HttpResponse> get(
    String path, {
    Map<String, String> query = const {},
    Map<String, String> headers = const {},
  }) =>
      _log('GET', path, () => inner.get(path, query: query, headers: headers));

  @override
  Future<HttpResponse> post(
    String path, {
    Object? body,
    Map<String, String> query = const {},
    Map<String, String> headers = const {},
  }) => _log(
    'POST',
    path,
    () => inner.post(path, body: body, query: query, headers: headers),
  );

  @override
  Future<HttpResponse> put(
    String path, {
    Object? body,
    Map<String, String> query = const {},
    Map<String, String> headers = const {},
  }) => _log(
    'PUT',
    path,
    () => inner.put(path, body: body, query: query, headers: headers),
  );

  @override
  Future<HttpResponse> delete(
    String path, {
    Map<String, String> query = const {},
    Map<String, String> headers = const {},
  }) => _log(
    'DELETE',
    path,
    () => inner.delete(path, query: query, headers: headers),
  );

  /// Выполняет [request] с обязательным логированием этапов.
  ///
  /// [method] — HTTP-метод; [path] — путь; [request] — вызов клиента.
  Future<HttpResponse> _log(
    String method,
    String path,
    Future<HttpResponse> Function() request,
  ) async {
    AppLogger.info('NetworkClient', 'Сетевой запрос', '$method $path');
    try {
      final response = await request();
      if (response.isSuccess) {
        AppLogger.debug(
          'NetworkClient',
          'Ответ сервера получен',
          '$method $path → ${response.statusCode}',
        );
      } else {
        AppLogger.error(
          'NetworkClient',
          'Ошибка ответа сервера',
          '$method $path → ${response.statusCode}',
        );
      }
      return response;
    } catch (error, stackTrace) {
      AppLogger.error(
        'NetworkClient',
        'Ошибка сетевого запроса',
        error,
        stackTrace,
      );
      rethrow;
    }
  }
}
