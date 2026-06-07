import 'package:hive_ce/hive.dart';
import '../models/book.dart';

class BookLocalDatabase {
  static Box get _box => Hive.box("books");

  static List<Book> getBooks() {
    return _box.values
        .map((item) => Book.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  static Future<void> saveBooks(List<Book> books) async {
    await _box.clear();
    for (final book in books) {
      await _box.put(book.id, book.toMap());
    }
  }

  static Future<void> addBook(Book book) async {
    await _box.put(book.id, book.toMap());
  }

  static Future<void> updateBook(Book book) async {
    await _box.put(book.id, book.toMap());
  }

  static bool isEmpty() => _box.isEmpty;

  static Book? getBook(int id) {
    final item = _box.get(id);
    if (item == null) return null;
    return Book.fromMap(Map<String, dynamic>.from(item as Map));
  }
  static Future<void> deleteBook(int id) async {
    await _box.delete(id);
  }
}
