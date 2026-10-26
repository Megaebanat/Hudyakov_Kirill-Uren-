import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../common/logging/app_logger.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/usecases/get_profile_use_case.dart';
import '../../domain/usecases/update_profile_use_case.dart';
import 'view_model.dart';

/// ViewModel экрана Player Information (профиль игрока).
///
/// Для собственного профиля доступны: выбор фото с камеры или из галереи,
/// изменение имени, настройка уведомлений. Изменения сохраняются через
/// [UpdateProfileUseCase] (согласовано с локальной сессией).
///
/// Ответственность (SRP): состояние экрана профиля и операции над ним.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class PlayerInfoViewModel extends ViewModel {
  final GetProfileUseCase _getProfile;
  final UpdateProfileUseCase _updateProfile;
  final ImagePicker _picker;

  /// Отображаемый игрок.
  AppUser user;

  /// Экран открыт для собственного профиля.
  final bool isOwnProfile;

  /// Контроллер имени.
  final TextEditingController nameController = TextEditingController();

  /// Создаёт ViewModel.
  ///
  /// [initial] — стартовые данные (null → загрузка с сервера);
  /// [isOwnProfile] — собственный профиль; [getProfile] — загрузка;
  /// [updateProfile] — изменение; [picker] — выбор фото.
  PlayerInfoViewModel({
    required AppUser? initial,
    required this.isOwnProfile,
    required this._getProfile,
    required this._updateProfile,
    ImagePicker? picker,
  }) : user = initial ?? AppUser.empty,
       _picker = picker ?? ImagePicker() {
    nameController.text = user.name;
  }

  /// Локальный файл недавно выбранного фото (отображается до сохранения).
  File? pickedPhoto;

  @override
  void dispose() {
    AppLogger.info('PlayerInfoViewModel', 'Жизненный цикл', 'Уничтожен');
    nameController.dispose();
    super.dispose();
  }

  /// Загружает профиль, если стартовых данных не было.
  Future<void> load() async {
    if (user.id.isNotEmpty) return;
    final result = await guard<AppUser>(
      tag: 'PlayerInfoViewModel',
      event: 'Загрузка профиля',
      action: _getProfile.call,
    );
    if (result != null) {
      user = result;
      nameController.text = result.name;
      notifyListeners();
    }
  }

  /// Выбирает фото [source] (камера/галерея) и сохраняет его в профиль.
  ///
  /// [source] — источник фото; [onPicked] — колбэк с локальным файлом.
  Future<void> pickPhoto({
    required ImageSource source,
    required void Function(File file) onPicked,
  }) async {
    AppLogger.info(
      'PlayerInfoViewModel',
      'Нажатие кнопки',
      '«Фото» (${source == ImageSource.camera ? 'камера' : 'галерея'})',
    );
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (file == null) return; // пользователь отменил выбор
      pickedPhoto = File(file.path);
      notifyListeners();
      onPicked(pickedPhoto!);
      // Локальный путь передаётся как photoUrl: в демо-режиме сервер
      // сохраняет строку, приложение отображает локальные пути через Image.file.
      await _save(photoUrl: file.path);
    } catch (error, stackTrace) {
      AppLogger.error(
        'PlayerInfoViewModel',
        'Выбор фото — ошибка',
        error,
        stackTrace,
      );
    }
  }

  /// Переключает настройку уведомлений [value] (с сохранением на сервере).
  Future<void> setNotifications(bool value) async {
    user = user.copyWith(notificationsEnabled: value);
    notifyListeners();
    await _save(notificationsEnabled: value);
  }

  /// Сохраняет изменение имени из контроллера (кнопка «Сохранить»).
  Future<void> saveName() => _save(name: nameController.text);

  /// Общий сценарий сохранения профиля с логированием и уведомлением об ошибке.
  ///
  /// Параметры опциональны (передаются изменяемые поля).
  Future<void> _save({
    String? name,
    String? photoUrl,
    bool? notificationsEnabled,
  }) async {
    AppLogger.info(
      'PlayerInfoViewModel',
      'Изменение профиля',
      'Сохранение на сервер',
    );
    final result = await guard<AppUser>(
      tag: 'PlayerInfoViewModel',
      event: 'Изменение профиля',
      action: () => _updateProfile(
        name: name,
        photoUrl: photoUrl,
        notificationsEnabled: notificationsEnabled,
      ),
    );
    if (result != null) {
      user = result;
      if (name != null) nameController.text = result.name;
      AppLogger.info(
        'PlayerInfoViewModel',
        'Изменение профиля',
        'Успех для ${result.email}',
      );
      notifyListeners();
    }
  }
}
