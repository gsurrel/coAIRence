class Source {
  const Source({
    required this.title,
    required this.url,
    this.author,
    this.publication,
  });

  final String title;
  final String url;
  final String? author;
  final String? publication;
}
