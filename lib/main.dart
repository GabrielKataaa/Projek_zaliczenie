import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'models/book.dart';
import 'services/local_database.dart';
import 'services/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox("books");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Książki',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A3728)),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4A3728),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      home: const BookListScreen(),
    );
  }
}

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  String _selectedFilter = "wszystkie";
  late Future<List<Book>> _booksFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _booksFuture = _loadBooks();
  }

  Future<List<Book>> _loadBooks() async {
    try {
      await BookSyncService.loadInitialDataIfNeeded();
    } catch (e) {
      if (BookLocalDatabase.isEmpty()) rethrow;
    }
    return BookLocalDatabase.getBooks();
  }

  void _reload() {
    setState(() {
      _booksFuture = Future.value(BookLocalDatabase.getBooks());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Książki")),
      body: FutureBuilder<List<Book>>(
        future: _booksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Ładowanie książek..."),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Błąd: ${snapshot.error}",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            );
          }

          final allBooks = snapshot.data ?? [];

          List<Book> filtered = allBooks;
          if (_selectedFilter == "ulubione") {
            filtered = allBooks.where((b) => b.isFavorite).toList();
          } else if (_selectedFilter == "do przeczytania") {
            filtered = allBooks.where((b) => b.isToRead).toList();
          }

          if (_searchQuery.isNotEmpty) {
            final q = _searchQuery.toLowerCase();
            filtered = filtered.where((b) {
              return b.title.toLowerCase().contains(q) ||
                  b.author.toLowerCase().contains(q);
            }).toList();
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Szukaj po tytule lub autorze...",
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = "");
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    _FilterChip(
                      label: "Wszystkie",
                      count: allBooks.length,
                      selected: _selectedFilter == "wszystkie",
                      onTap: () =>
                          setState(() => _selectedFilter = "wszystkie"),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: "Ulubione",
                      count: allBooks.where((b) => b.isFavorite).length,
                      selected: _selectedFilter == "ulubione",
                      icon: Icons.favorite,
                      onTap: () => setState(() => _selectedFilter = "ulubione"),
                    ),
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: "Do przeczytania",
                      count: allBooks.where((b) => b.isToRead).length,
                      selected: _selectedFilter == "do przeczytania",
                      icon: Icons.bookmark,
                      onTap: () =>
                          setState(() => _selectedFilter = "do przeczytania"),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Znaleziono: ${filtered.length} książek",
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? _EmptyState(filter: _selectedFilter)
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final book = filtered[index];
                          return BookCard(book: book, onTap: () {});
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final IconData? icon;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF4A3728);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: selected ? Colors.white : Colors.grey[600],
              ),
              const SizedBox(width: 4),
            ],
            Text(
              "$label ($count)",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const BookCard({super.key, required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: book.coverUrl.isNotEmpty
                    ? Image.network(
                        book.coverUrl,
                        width: 60,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _PlaceholderCover(),
                      )
                    : _PlaceholderCover(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Pobrania: ${book.downloadCount}",
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderCover extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.brown[100],
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(Icons.book, color: Colors.brown, size: 32),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String filter;

  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    String msg;
    IconData icon;
    if (filter == "ulubione") {
      msg = "Nie masz jeszcze ulubionych książek.";
      icon = Icons.favorite_border;
    } else if (filter == "do przeczytania") {
      msg = "Lista do przeczytania jest pusta.";
      icon = Icons.bookmark_border;
    } else {
      msg = "Brak książek.";
      icon = Icons.menu_book;
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
