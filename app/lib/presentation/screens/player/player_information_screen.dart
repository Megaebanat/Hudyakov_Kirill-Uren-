import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uikit/uikit.dart';

import '../../../common/di/app_scope.dart';
import '../../../common/logging/app_logger.dart';
import '../../../domain/usecases/get_profile_use_case.dart';
import '../../../domain/usecases/update_profile_use_case.dart';
import '../../navigation/route_args.dart';
import '../../viewmodels/player_info_viewmodel.dart';
import '../widgets/app_avatar.dart';
import '../widgets/screen_app_bar.dart';
import '../widgets/screen_lifecycle.dart';

/// Экран информации об игроке (Player Information).
///
/// Для своего профиля: смена фото (камера/галерея через шторку), изменение
/// имени, настройка уведомлений. Для чужого профиля: просмотр данных.
///
/// Ответственность (SRP): отображение и редактирование профиля игрока.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class PlayerInformationScreen extends StatefulWidget {
  /// Аргументы маршрута (null — загрузить собственный профиль).
  final PlayerRouteArgs? args;

  /// Создаёт экран профиля.
  ///
  /// [args] — аргументы маршрута.
  const PlayerInformationScreen({super.key, required this.args});

  @override
  State<PlayerInformationScreen> createState() =>
      _PlayerInformationScreenState();
}

/// Состояние экрана профиля.
class _PlayerInformationScreenState extends State<PlayerInformationScreen>
    with ScreenLifecycle<PlayerInformationScreen> {
  @override
  String get screenName => 'PlayerInformation';

  /// ViewModel экрана.
  late final PlayerInfoViewModel _vm;

  /// Зависимости созданы.
  bool _inited = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_inited) return;
    _inited = true;
    final services = AppScope.of(context);
    final args = widget.args;
    _vm = PlayerInfoViewModel(
      initial:
          args?.user ??
          (services.sessionStore.restore().user.id.isNotEmpty
              ? services.sessionStore.restore().user
              : null),
      isOwnProfile: args?.isOwnProfile ?? true,
      getProfile: GetProfileUseCase(services.profileRepository),
      updateProfile: UpdateProfileUseCase(services.profileRepository),
    );
    _vm.addListener(() => setState(() {}));
    _vm.load();
  }

  @override
  void dispose() {
    if (_inited) _vm.dispose();
    super.dispose();
  }

  /// Шторка выбора источника фото (камера/галерея).
  Future<void> _pickPhotoSource() async {
    AppLogger.info(
      'PlayerInformation',
      'Нажатие кнопки',
      '«Фото» — выбор источника',
    );
    final source = await AppBottomSheet.show<ImageSource>(
      context: context,
      title: 'Откуда взять фото?',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(
              Icons.photo_camera_outlined,
              color: AppColors.primary,
            ),
            title: Text('Камера', style: AppTypography.bodySmall),
            onTap: () => Navigator.of(context).pop(ImageSource.camera),
          ),
          const Divider(height: 1, color: AppColors.outline),
          ListTile(
            leading: const Icon(
              Icons.photo_library_outlined,
              color: AppColors.primary,
            ),
            title: Text('Галерея', style: AppTypography.bodySmall),
            onTap: () => Navigator.of(context).pop(ImageSource.gallery),
          ),
        ],
      ),
    );
    if (source == null || !mounted) return;
    await _vm.pickPhoto(
      source: source,
      onPicked: (file) {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_inited) {
      return const Scaffold(backgroundColor: AppColors.background);
    }
    final user = _vm.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ScreenAppBar(title: _vm.isOwnProfile ? 'Мой профиль' : 'Игрок'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Аватар и кнопка смены фото (только свой профиль).
              Center(
                child: Stack(
                  children: [
                    AppAvatar(photoUrl: user.photoUrl, size: 112),
                    if (_vm.isOwnProfile)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: _pickPhotoSource,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.photo_camera_rounded,
                              size: 20,
                              color: AppColors.onPrimary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  user.name.isEmpty ? 'Игрок без имени' : user.name,
                  style: AppTypography.h2,
                  textAlign: TextAlign.center,
                ),
              ),
              Center(
                child: Text(
                  user.email,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Рейтинг.
              AppCard(
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.16),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.emoji_events_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text('Очки рейтинга', style: AppTypography.bodySmall),
                    const Spacer(),
                    Text(
                      '${user.rating}',
                      style: AppTypography.h2.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              if (_vm.isOwnProfile) ...[
                const SizedBox(height: 24),
                AppTextField(
                  controller: _vm.nameController,
                  label: 'Имя',
                  hint: 'Введите имя',
                  enabled: !_vm.busy,
                  textInputAction: TextInputAction.done,
                  prefixIcon: const Icon(
                    Icons.person_outline_rounded,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Сохранить имя',
                  variant: AppButtonVariant.secondary,
                  loading: _vm.busy,
                  onPressed: _vm.busy ? null : _vm.saveName,
                ),
                const SizedBox(height: 24),
                AppCard(
                  child: AppCheckbox(
                    value: user.notificationsEnabled,
                    label: 'Получать уведомления о начале игр',
                    onChanged: _vm.busy ? (_) {} : _vm.setNotifications,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
