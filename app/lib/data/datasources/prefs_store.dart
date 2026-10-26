import 'dart:convert';

import 'package:network/network.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/game.dart';
import '../mappers/game_mapper.dart';

/// Локальное хранилище настроек и состояния последнего экрана.
///
/// Сохраняет: последний открытый экран (восстановление после перезапуска),
/// факт просмотра приветствия, данные формы входа, кэш списка игр.
///
/// Ответственность (SRP): только персистентность настроек/состояния UI.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class PrefsStore {
  static const _lastRouteKey = 'prefs.last_route';
  static const _onboardingKey = 'prefs.onboarding_shown';
  static const _loginEmailKey = 'prefs.login_email';
  static const _loginPasswordKey = 'prefs.login_password';
  static const _gamesCacheKey = 'prefs.games_cache';

  /// Параметры хранилища.
  final SharedPreferences _prefs;

  /// Создаёт хранилище настроек.
  ///
  /// [prefs] — инициализированные SharedPreferences.
  PrefsStore(this._prefs);

  /// Последний открытый экран (null — ещё не было переходов).
  String? get lastRoute => _prefs.getString(_lastRouteKey);

  /// Сохраняет последний открытый экран [route].
  Future<void> saveLastRoute(String route) =>
      _prefs.setString(_lastRouteKey, route);

  /// Приветствие уже показывалось (после переустановки сбрасывается).
  bool get onboardingShown => _prefs.getBool(_onboardingKey) ?? false;

  /// Отмечает, что приветствие показано.
  Future<void> markOnboardingShown() => _prefs.setBool(_onboardingKey, true);

  /// Сохранённые данные входа для предзаполнения формы.
  ({String email, String password}) get savedCredentials => (
    email: _prefs.getString(_loginEmailKey) ?? '',
    password: _prefs.getString(_loginPasswordKey) ?? '',
  );

  /// Сохраняет данные входа [email]/[password] после успешного входа.
  ///
  /// Примечание: пароль хранится в открытом виде для демо-требования
  /// «данные входа сохраняются после перезапуска»; в продакшене
  /// используется хранилище ключей платформы (Keystore/Keychain).
  Future<void> saveCredentials({
    required String email,
    required String password,
  }) async {
    await _prefs.setString(_loginEmailKey, email);
    await _prefs.setString(_loginPasswordKey, password);
  }

  /// Очищает сохранённые данные входа (выход из аккаунта).
  Future<void> clearCredentials() async {
    await _prefs.remove(_loginEmailKey);
    await _prefs.remove(_loginPasswordKey);
  }

  /// Сохраняет JSON списка игр [games] (кэш для восстановления экрана).
  Future<void> saveGamesCache(List<Game> games) => _prefs.setString(
    _gamesCacheKey,
    jsonEncode(games.map((game) => GameMapper.toDto(game).toJson()).toList()),
  );

  /// Возвращает закэшированный список игр (пустой, если кэша нет).
  List<Game> loadGamesCache() {
    final raw = _prefs.getString(_gamesCacheKey);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List<Object?>) {
        return decoded
            .whereType<Map<String, Object?>>()
            .map((json) => GameMapper.toEntity(GameDto.fromJson(json)))
            .toList();
      }
    } catch (error) {
      // Повреждённый кэш не должен ронять приложение — считаем его пустым.
      assert(() {
        // Ошибка разбора кэша фиксируется в debug-режиме.
        return true;
      }());
    }
    return [];
  }
}
