import 'view_model.dart';

/// ViewModel экрана приветствия (3 страницы, только первый запуск).
///
/// Ответственность (SRP): индекс текущей страницы приветствия.
///
/// Дата создания: 19-10-2026
/// Автор: Участник №00
class OnboardingViewModel extends ViewModel {
  /// Индекс текущей страницы (0..2).
  int _page = 0;

  /// Общее количество страниц приветствия.
  static const int pageCount = 3;

  /// Текущий индекс страницы.
  int get page => _page;

  /// Последняя страница достигнута (кнопка «Начать» вместо «Далее»).
  bool get isLastPage => _page == pageCount - 1;

  /// Переходит на страницу [index] с клампом в допустимые границы.
  ///
  /// [index] — запрошенный индекс.
  void goTo(int index) {
    if (index < 0 || index >= pageCount || index == _page) return;
    _page = index;
    notifyListeners();
  }

  /// Переходит к следующей странице (не дальше последней).
  void nextPage() => goTo(_page + 1);
}
