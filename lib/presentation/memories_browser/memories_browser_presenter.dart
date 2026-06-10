import '../../domain/models/memory.dart';
import '../../domain/repositories/memory_repository.dart';

abstract class MemoriesBrowserView {
  void showMessage(String message);
  void onSaveSuccess();
}

class MemoriesBrowserPresenter {
  final MemoryRepository repository;
  final MemoriesBrowserView view;

  MemoriesBrowserPresenter(this.repository, this.view);

  Future<void> saveMemory(String text, String title) async {
    if (text.trim().isEmpty) {
      view.showMessage('write_something');
      return;
    }

    try {
      final memory = Memory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        createdAt: DateTime.now(),
        isJournal: true,
        pages: [MemoryPageData(text: text)],
      );

      await repository.saveMemory(memory);
      view.onSaveSuccess();
    } catch (e) {
      view.showMessage('error');
    }
  }
}
