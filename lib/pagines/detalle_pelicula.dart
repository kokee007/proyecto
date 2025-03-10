import 'package:flutter/material.dart';

class DetallePelicula extends StatelessWidget {
  final Map movie; // Objeto con los datos de la película

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
    // Agrega más según necesites.
  };

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              )),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Convertimos el código de idioma en nombre completo si existe en el mapeo.
    String idioma = movie["original_language"] ?? "";
    idioma = languageMapping[idioma] ?? idioma;

    return Scaffold(
      backgroundColor: Colors.grey[850],
      // CustomScrollView con SliverAppBar para un efecto moderno
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            backgroundColor: Colors.grey[900],
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: movie["imatge"] != null && movie["imatge"].toString().isNotEmpty
                  ? Image.network(
                      movie["imatge"],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Icon(Icons.error, size: 80, color: Colors.red)),
                    )
                  : Container(
                      color: Colors.grey[800],
                      child: const Center(child: Icon(Icons.movie, size: 80, color: Colors.red)),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título principal
                  Text(
                    movie["titol"] ?? "Título no disponible",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if ((movie["release_date"] ?? "").toString().isNotEmpty)
                    _buildInfoRow("Fecha de estreno", movie["release_date"]),
                  if (movie["vote_average"] != null && movie["vote_average"].toString().isNotEmpty)
                    _buildInfoRow("Valoración", movie["vote_average"].toString()),
                  if (movie["vote_count"] != null && movie["vote_count"].toString().isNotEmpty)
                    _buildInfoRow("Votos", movie["vote_count"].toString()),
                  if (movie["popularity"] != null && movie["popularity"].toString().isNotEmpty)
                    _buildInfoRow("Popularidad", movie["popularity"].toString()),
                  // Usamos el idioma completo
                  if (idioma.isNotEmpty)
                    _buildInfoRow("Idioma", idioma),
                  if (movie["runtime"] != null && movie["runtime"].toString().isNotEmpty)
                    _buildInfoRow("Duración", "${movie["runtime"]} minutos"),
                  if ((movie["tagline"] ?? "").toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "\"${movie["tagline"]}\"",
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  // Descripción
                  Text(
                    movie["descripcio"] ?? "Sin descripción",
                    style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  // Estado de favorito
                  Row(
                    children: [
                      Icon(
                        movie["favorito"] == true ? Icons.favorite : Icons.favorite_border,
                        color: movie["favorito"] == true ? Colors.red : Colors.grey,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Favorito: ${movie["favorito"] == true ? "Sí" : "No"}",
                        style: const TextStyle(fontSize: 18, color: Colors.white70),
                      ),
                    ],
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
