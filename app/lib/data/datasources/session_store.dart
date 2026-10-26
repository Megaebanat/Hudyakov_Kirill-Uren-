import 'dart:convert';

import 'package:network/network.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/entities/session.dart';
import '../mappers/user_mapper.dart';

/// Локальное хранилище сессии (активный вход) в SharedPreferences.
///
/// Сохраняет токен и профиль пользователя — активная сессия переживает
/// перезапуск приложения (требование модуля Г).
///
/// Ответственность (SRP): только персистентность сессии.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class SessionStore {
  static const _tokenKey = 'session.token';
  static const _userKey = 'session.user';

  /// Параметры хранилища (подменяются в тестах).
  final SharedPreferences _prefs;

  /// Создаёт хранилище сессии.
  ///
  /// [prefs] — инициализированные SharedPreferences.
  SessionStore(this._prefs);

  /// Текущий токен (null — не авторизован).
  String? get token => _prefs.getString(_tokenKey);

  /// Пользователь из сохранённой сессии (null — сессии нет).
  AppUser? get user {
    final raw = _prefs.getString(_userKey);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw);
      if (json is Map<String, Object?>) {
        return UserMapper.toEntity(UserProfileDto.fromJson(json));
      }
    } catch (_) {
      // Повреждённые данные сессии приравниваем к отсутствию сессии.
    }
    return null;
  }

  /// Сохраняет [session] локально.
  ///
  /// [session] — данные успешного входа/регистрации.
  Future<void> save(Session session) async {
    await _prefs.setString(_tokenKey, session.token);
    await _prefs.setString(
      _userKey,
      jsonEncode(UserMapper.toDto(session.user).toJson()),
    );
  }

  /// Обновляет профиль в сохранённой сессии (после изменения на сервере).
  ///
  /// [user] — обновлённый профиль.
  Future<void> updateUser(AppUser user) async {
    final currentToken = token;
    if (currentToken == null) return;
    await _prefs.setString(
      _userKey,
      jsonEncode(UserMapper.toDto(user).toJson()),
    );
  }

  /// Очищает локальную сессию (выход).
  Future<void> clear() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
  }

  /// Восстанавливает сессию из хранилища (после перезапуска).
  ///
  /// Возвращает [Session.none], если сессии нет.
  Session restore() {
    final currentToken = token;
    final currentUser = user;
    if (currentToken == null || currentUser == null) return Session.none;
    return Session(token: currentToken, user: currentUser);
  }
}
