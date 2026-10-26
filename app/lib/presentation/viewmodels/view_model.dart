import 'package:flutter/foundation.dart';

import '../../common/errors/app_error_handler.dart';
import '../../common/logging/app_logger.dart';
import '../../domain/errors/domain_exception.dart';

/// Базовый класс ViewModel (ChangeNotifier) с единым управлением
/// состоянием загрузки и обработкой ошибок.
///
/// [guard] — шаблон «попытка выполнить действие»: фиксирует ERROR в лог при
/// любом исключении (требование ТЗ), показывает уведомление об ошибке через
/// [AppErrorHandler] и возвращает null при сбое.
///
/// Ответственность (SRP): инфраструктурные заботы всех ViewModel.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
abstract class ViewModel extends ChangeNotifier {
  bool _busy = false;
  bool _disposed = false;

  /// Идёт ли фоновая операция (для индикаторов загрузки).
  bool get busy => _busy;

  /// Уведомление подписантов (защита от вызова после dispose).
  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// Меняет флаг загрузки и уведомляет подписчиков.
  ///
  /// [value] — новое значение флага.
  void setBusy(bool value) {
    if (_busy == value) return;
    _busy = value;
    notifyListeners();
  }

  /// Выполняет [action] под флагом загрузки с обработкой ошибок.
  ///
  /// [tag] — тег компонента для лога; [event] — событие;
  /// [action] — выполняемое действие; возвращает результат или null при
  /// ошибке (текст ошибки показывается пользователю уведомлением на 5 сек).
  Future<T?> guard<T>({
    required String tag,
    required String event,
    required Future<T> Function() action,
  }) async {
    try {
      setBusy(true);
      return await action();
    } on DomainException catch (error, stackTrace) {
      AppLogger.error(tag, '$event — ошибка', error, stackTrace);
      AppErrorHandler.report(error.message);
      return null;
    } catch (error, stackTrace) {
      AppLogger.error(tag, '$event — непредвиденная ошибка', error, stackTrace);
      AppErrorHandler.report('Непредвиденная ошибка. Попробуйте позже.');
      return null;
    } finally {
      setBusy(false);
    }
  }
}
