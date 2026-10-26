import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:uikit/uikit.dart';

import '../../../common/di/app_scope.dart';
import '../../../common/logging/app_logger.dart';
import '../widgets/screen_app_bar.dart';
import '../widgets/screen_lifecycle.dart';

/// Экран Политики конфиденциальности (PDF).
///
/// Документ генерируется локально (пакет pdf, шрифт Inter для кириллицы)
/// и отображается встроенным просмотрщиком с сохранением и отправкой.
///
/// Ответственность (SRP): показ политики конфиденциальности.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class PrivacyPolicyScreen extends StatefulWidget {
  /// Создаёт экран политики.
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

/// Состояние экрана политики: генерация PDF и отображение просмотра.
class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen>
    with ScreenLifecycle<PrivacyPolicyScreen> {
  @override
  String get screenName => 'PrivacyPolicy';

  /// Байты сгенерированного документа (генерация стартует в didChangeDeps).
  late final Future<List<int>> _document;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _document = AppScope.of(context).documents.buildPrivacyPolicyPdf();
    AppLogger.info('PrivacyPolicy', 'Документ', 'Генерация PDF запущена');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScreenAppBar(title: 'Политика конфиденциальности'),
      body: FutureBuilder<List<int>>(
        future: _document,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (snapshot.hasError || !snapshot.hasData) {
            AppLogger.error(
              'PrivacyPolicy',
              'Документ — ошибка',
              snapshot.error ?? 'нет данных',
              StackTrace.current,
            );
            return Center(
              child: Text(
                'Не удалось сформировать документ',
                style: AppTypography.body.copyWith(color: AppColors.error),
              ),
            );
          }
          final bytes = Uint8List.fromList(snapshot.data!);
          return PdfPreview(
            build: (_) => bytes,
            pdfFileName: 'privacy_policy.pdf',
          );
        },
      ),
    );
  }
}
