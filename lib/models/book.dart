class Book {
  final int id;
  final String title;
  final String author;
  final String description;
  final String coverUrl;
  final List<String> languages;
  final int downloadCount;
  final bool isFavorite;
  final bool isToRead;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.coverUrl,
    required this.languages,
    required this.downloadCount,
    this.isFavorite = false,
    this.isToRead = false,
  });

  Book copyWith({
    bool? isFavorite,
    bool? isToRead,
    String? title,
    String? author,
    String? description,
  }) {
    return Book(
      id: id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      coverUrl: coverUrl,
      languages: languages,
      downloadCount: downloadCount,
      isFavorite: isFavorite ?? this.isFavorite,
      isToRead: isToRead ?? this.isToRead,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "author": author,
      "description": description,
      "coverUrl": coverUrl,
      "languages": languages.join(","),
      "downloadCount": downloadCount,
      "isFavorite": isFavorite,
      "isToRead": isToRead,
    };
  }

  factory Book.fromMap(Map map) {
    final langs = (map["languages"] as String?) ?? "";
    return Book(
      id: map["id"],
      title: map["title"] ?? "",
      author: map["author"] ?? "",
      description: map["description"] ?? "",
      coverUrl: map["coverUrl"] ?? "",
      languages: langs.isEmpty ? [] : langs.split(","),
      downloadCount: map["downloadCount"] ?? 0,
      isFavorite: map["isFavorite"] ?? false,
      isToRead: map["isToRead"] ?? false,
    );
  }

  factory Book.fromApi(Map<String, dynamic> json) {
    final authors = json["authors"] as List? ?? [];
    final authorName = authors.isNotEmpty
        ? (authors[0]["name"] as String? ?? "Nieznany autor")
        : "Nieznany autor";

    final formats = json["formats"] as Map<String, dynamic>? ?? {};
    final coverUrl = formats["image/jpeg"] as String? ?? "";

    final subjects = json["subjects"] as List? ?? [];
    final description = subjects.isNotEmpty
        ? subjects.take(3).join(", ")
        : "Brak opisu";

    final langs = (json["languages"] as List? ?? [])
        .map((l) => l.toString())
        .toList();

    return Book(
      id: json["id"] ?? 0,
      title: json["title"] ?? "Bez tytułu",
      author: authorName,
      description: description,
      coverUrl: coverUrl,
      languages: langs,
      downloadCount: json["download_count"] ?? 0,
    );
  }
}
