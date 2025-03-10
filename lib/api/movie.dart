class Movie {
  final String title;
  final String overview;
  final String posterPath;
  final List<int> genreIds;

  Movie({
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.genreIds,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['title'] ?? 'Sin título',
      overview: json['overview'] ?? '',
      posterPath: json['poster_path'] ?? '',
      genreIds: List<int>.from(json['genre_ids'] ?? []),
    );
  }
}
