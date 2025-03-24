import 'package:flutter/material.dart';
import 'package:proyecto/api/tmdb_api.dart';
import 'package:url_launcher/url_launcher.dart';

/// Función para transformar el JSON de TMDB en un Map que incluya la propiedad "id".
Map<String, dynamic> parseMovie(Map<String, dynamic> json) {
  return {
    "id": json["id"], // Se extrae el id tal como lo devuelve TMDB.
    "titol": json["title"],
    "descripcio": json["overview"],
    "imatge": json["poster_path"] != null
        ? "https://image.tmdb.org/t/p/w200${json["poster_path"]}"
        : "",
    "release_date": json["release_date"],
    "vote_average": json["vote_average"],
    "vote_count": json["vote_count"],
    "popularity": json["popularity"],
    "original_language": json["original_language"],
    "runtime": json["runtime"],
    "tagline": json["tagline"],
    "favorito": false, // Valor por defecto.
  };
}

class DetallePelicula extends StatelessWidget {
  final Map movie; // Objeto con los datos de la película.

  const DetallePelicula({Key? key, required this.movie}) : super(key: key);

  // Mapeo de códigos de idioma a nombres completos.
  final Map<String, String> languageMapping = const {
    "en": "English",
    "es": "Español",
    "fr": "Français",
    "de": "Deutsch",
    "it": "Italiano",
    "pt": "Português",
    "ja": "Japanese",
    "ko": "Korean",
    "zh": "Chinese",
    "hi": "Hindi"
  };

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text("$label: ",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.red)),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  // Función para abrir el trailer usando url_launcher.
  void _openTrailer(String trailerKey, BuildContext context) async {
    final trailerUrl = "https://www.youtube.com/watch?v=$trailerKey";
    if (await canLaunch(trailerUrl)) {
      await launch(trailerUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el trailer')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Imprime en consola para verificar que el Map incluya "id".
    debugPrint("Datos de la película: $movie");
    debugPrint("Llaves disponibles: ${movie.keys}");

    // Convertimos el código de idioma en nombre completo.
    String idioma = movie["original_language"] ?? "";
    idioma = languageMapping[idioma] ?? idioma;

    // Comprobamos que el id no sea nulo y sea de tipo int.
    final int? movieId = movie["id"] is int ? movie["id"] as int : null;

    return Scaffold(
      backgroundColor: Colors.grey[850],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            backgroundColor: Colors.grey[900],
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: movie["imatge"] != null &&
                      movie["imatge"].toString().isNotEmpty
                  ? Image.network(
                      movie["imatge"],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Center(
                          child: Icon(Icons.error, size: 80, color: Colors.red)),
                    )
                  : Container(
                      color: Colors.grey[800],
                      child: const Center(
                          child: Icon(Icons.movie, size: 80, color: Colors.red)),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título principal.
                  Text(
                    movie["titol"] ?? "Título no disponible",
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  // Mostramos la propiedad "id" para verificar que esté presente.
                  if (movie["id"] != null)
                    _buildInfoRow("ID", movie["id"].toString()),
                  const SizedBox(height: 16),
                  if ((movie["release_date"] ?? "").toString().isNotEmpty)
                    _buildInfoRow("Fecha de estreno", movie["release_date"]),
                  if (idioma.isNotEmpty)
                    _buildInfoRow("Idioma", idioma),
                  if (movie["runtime"] != null &&
                      movie["runtime"].toString().isNotEmpty)
                    _buildInfoRow("Duración", "${movie["runtime"]} minutos"),
                  if ((movie["tagline"] ?? "").toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "\"${movie["tagline"]}\"",
                        style: const TextStyle(
                            fontStyle: FontStyle.italic, color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 16),
                  // Descripción.
                  Text(
                    movie["descripcio"] ?? "Sin descripción",
                    style: const TextStyle(
                        fontSize: 16, height: 1.5, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  // Estado de favorito.
                  Row(
                    children: [
                      Icon(
                        movie["favorito"] == true
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: movie["favorito"] == true
                            ? Colors.red
                            : Colors.grey,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Favorito: ${movie["favorito"] == true ? "Sí" : "No"}",
                        style: const TextStyle(
                            fontSize: 18, color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Sección del trailer.
                  FutureBuilder<String?>(
                    future: movieId != null
                        ? TmdbApi().fetchTrailerKey(movieId: movieId)
                        : Future.value(null),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasData && snapshot.data != null) {
                        return ElevatedButton(
                          onPressed: () =>
                              _openTrailer(snapshot.data!, context),
                          child: const Text("Ver Trailer"),
                        );
                      } else {
                        return const Text("Trailer no disponible",
                            style: TextStyle(color: Colors.white70));
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
