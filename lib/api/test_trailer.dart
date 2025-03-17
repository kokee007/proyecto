import 'dart:convert';
import 'package:http/http.dart' as http;

/// Clase TmdbApi con el método fetchTrailerKey.
class TmdbApi {
  final String _apiKey = '28df8c300c7a610fb1dc321a398831a3';
  final String _baseUrl = 'https://api.themoviedb.org/3';

  Future<String?> fetchTrailerKey({required int movieId}) async {
    final url = Uri.parse('$_baseUrl/movie/$movieId/videos?api_key=$_apiKey&language=en-US');
    final response = await http.get(url);
    print("Respuesta cruda para movieId $movieId:");
    print(response.body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List videos = data['results'];
      // Busca el primer video que sea Trailer o Teaser y que esté en YouTube.
      final trailer = videos.firstWhere(
        (video) =>
            (video['type'] == 'Trailer' || video['type'] == 'Teaser') &&
            video['site'] == 'YouTube',
        orElse: () => null,
      );
      if (trailer != null) {
        return trailer['key'];
      }
    }
    return null;
  }
}

Future<void> main() async {
  final api = TmdbApi();

  // Supongamos que movieId viene de algún lugar, pero podría ser nulo.
  int? movieId;
  
  // Si movieId es nulo, asignamos el valor por defecto 550.
  final int validMovieId = movieId ?? 550;

  final trailerKey = await api.fetchTrailerKey(movieId: validMovieId);
  print("Trailer key para movieId $validMovieId: $trailerKey");
}
