import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/local_database.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late Book _book;

  @override
  void initState() {
    super.initState();
    _book = BookLocalDatabase.getBook(widget.book.id) ?? widget.book;
  }

  Future<void> _toggleFavorite() async {
    final updated = _book.copyWith(isFavorite: !_book.isFavorite);
    await BookLocalDatabase.updateBook(updated);
    setState(() => _book = updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(updated.isFavorite
              ? "Dodano do ulubionych"
              : "Usunięto z ulubionych"),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _toggleToRead() async {
    final updated = _book.copyWith(isToRead: !_book.isToRead);
    await BookLocalDatabase.updateBook(updated);
    setState(() => _book = updated);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(updated.isToRead
              ? "Dodano do listy do przeczytania"
              : "Usunięto z listy do przeczytania"),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Szczegóły książki"),
        actions: [
          IconButton(
            icon: Icon(
              _book.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _book.isFavorite ? Colors.red[200] : Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: Icon(
              _book.isToRead ? Icons.bookmark : Icons.bookmark_border,
              color: _book.isToRead ? Colors.blue[200] : Colors.white,
            ),
            onPressed: _toggleToRead,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              color: const Color(0xFF4A3728).withOpacity(0.08),
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _book.coverUrl.isNotEmpty
                        ? Image.network(
                      _book.coverUrl,
                      width: 100,
                      height: 135,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholderCover(),
                    )
                        : _placeholderCover(),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _book.title,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _book.author,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF4A3728),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_book.isFavorite || _book.isToRead)
                          Wrap(
                            spacing: 8,
                            children: [
                              if (_book.isFavorite)
                                _Badge(
                                    icon: Icons.favorite,
                                    label: "Ulubiona",
                                    color: Colors.red),
                              if (_book.isToRead)
                                _Badge(
                                    icon: Icons.bookmark,
                                    label: "Do przeczytania",
                                    color: Colors.blue),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_book.isCustom) ...[
                    _InfoRow(
                        icon: Icons.download,
                        label: "Liczba pobrań",
                        value: _book.downloadCount.toString()),
                    const SizedBox(height: 12),
                  ],
                  if (_book.languages.isNotEmpty) ...[
                    _InfoRow(
                        icon: Icons.language,
                        label: "Język",
                        value: _book.languages.join(", ").toUpperCase()),
                    const SizedBox(height: 12),
                  ],
                  if (_book.isCustom)
                    _InfoRow(
                        icon: Icons.person,
                        label: "Typ",
                        value: "Własna książka"),
                  const SizedBox(height: 20),
                  const Text("Opis",
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    _book.description.isNotEmpty
                        ? _book.description
                        : "Brak opisu",
                    style: const TextStyle(fontSize: 15, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _toggleFavorite,
                          icon: Icon(
                              _book.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.red),
                          label: Text(_book.isFavorite
                              ? "Usuń z ulubionych"
                              : "Dodaj do ulubionych"),
                          style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              foregroundColor: Colors.red),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _toggleToRead,
                          icon: Icon(
                              _book.isToRead
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: Colors.blue),
                          label: Text(_book.isToRead
                              ? "Usuń z listy"
                              : "Do przeczytania"),
                          style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.blue),
                              foregroundColor: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderCover() {
    return Container(
      width: 100,
      height: 135,
      decoration: BoxDecoration(
          color: Colors.brown[100], borderRadius: BorderRadius.circular(10)),
      child: const Icon(Icons.book, color: Colors.brown, size: 48),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF4A3728)),
        const SizedBox(width: 8),
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
        Flexible(child: Text(value)),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Badge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
