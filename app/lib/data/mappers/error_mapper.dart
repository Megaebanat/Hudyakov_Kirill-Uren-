import 'package:network/network.dart';

import '../../domain/errors/domain_exception.dart';

/// Преобразование ошибок сетевого слоя в доменные ошибки (граница слоёв).
///
/// Presentation не знает о типах сети: оно получает [DomainException]
/// с готовым сообщением для уведомления.
///
/// Ответственность (SRP): только маппинг ошибок.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
abstract final class ErrorMapper {
  /// Преобразует [error] в [DomainException].
  ///
  /// [error] — исходная ошибка; возвращает доменную ошибку с сообщением.
  static DomainException map(Object error) {
    if (error is DomainException) return error;
    if (error is NetworkException) return DomainException(error.message);
    return const DomainException('Непредвиденная ошибка. Попробуйте позже.');
  }
}
