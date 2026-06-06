import 'api_service.dart';
import 'local_database.dart';

class BookSyncService {
  static Future<void> loadInitialDataIfNeeded() async {
    if (!BookLocalDatabase.isEmpty()) return;
    final books = await BookApiService.fetchBooks(page: 1);
    await BookLocalDatabase.saveBooks(books);
  }
}
