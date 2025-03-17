import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TmdbApi {
  final String _apiKey = '28df8c300c7a610fb1dc321a398831a3';
  final String _baseUrl = 'https://api.themoviedb.org/3';

  Future<List<dynamic>> fetchPopularMovies({int page = 1}) async {
    final url = Uri.parse('$_baseUrl/movie/popular?api_key=$_apiKey&page=$page');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      throw Exception('Error al cargar las películas populares');
    }
  }

  Future<List<dynamic>> fetchGenres() async {
    final url = Uri.parse('$_baseUrl/genre/movie/list?api_key=$_apiKey&language=es-ES');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['genres'];
    } else {
      throw Exception('Error al cargar géneros');
    }
  }

  Future<List<dynamic>> searchMovies({required String query, int page = 1}) async {
    final url = Uri.parse('$_baseUrl/search/movie?api_key=$_apiKey&query=$query&page=$page');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      throw Exception('Error al buscar películas');
    }
  }

  Future<List<dynamic>> fetchUpcomingMovies({int page = 1}) async {
    final url = Uri.parse('$_baseUrl/movie/upcoming?api_key=$_apiKey&page=$page&language=es-ES');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      throw Exception('Error al cargar próximos estrenos');
    }
  }

  // Método para obtener la clave del trailer de una película
  Future<String?> fetchTrailerKey({required int movieId}) async {
    final url = Uri.parse('$_baseUrl/movie/$movieId/videos?api_key=$_apiKey&language=en-US');
    final response = await http.get(url);
    debugPrint("Respuesta de videos para movieId $movieId: ${response.body}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List videos = data['results'];
      // Se busca el primer video que sea Trailer o Teaser y que esté en YouTube.
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
