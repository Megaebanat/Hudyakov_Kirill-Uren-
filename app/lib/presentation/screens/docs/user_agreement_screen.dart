import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:uikit/uikit.dart';

import '../../../common/di/app_scope.dart';
import '../../../common/logging/app_logger.dart';
import '../widgets/screen_app_bar.dart';
import '../widgets/screen_lifecycle.dart';

/// Экран Пользовательского соглашения (PDF).
///
/// Документ генерируется локально и отображается встроенным просмотрщиком
/// с сохранением и отправкой (шрифт Inter — кириллица не «кракозябрит»).
///
/// Ответственность (SRP): показ пользовательского соглашения.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class UserAgreementScreen extends StatefulWidget {
  /// Создаёт экран соглашения.
  const UserAgreementScreen({super.key});

  @override
  State<UserAgreementScreen> createState() => _UserAgreementScreenState();
}

/// Состояние экрана соглашения: генерация PDF и отображение просмотра.
class _UserAgreementScreenState extends State<UserAgreementScreen>
    with ScreenLifecycle<UserAgreementScreen> {
  @override
  String get screenName => 'UserAgreement';

  /// Байты сгенерированного документа.
  late final Future<List<int>> _document;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _document = AppScope.of(context).documents.buildUserAgreementPdf();
    AppLogger.info('UserAgreement', 'Документ', 'Генерация PDF запущена');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScreenAppBar(title: 'Пользовательское соглашение'),
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
              'UserAgreement',
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
            pdfFileName: 'user_agreement.pdf',
          );
        },
      ),
    );
  }
}
