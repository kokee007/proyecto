import 'package:flutter/material.dart';
import 'package:proyecto/api/tmdb_api.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Función para transformar el JSON de TMDB en un Map que incluya la propiedad "id".
Map<String, dynamic> parseMovie(Map<String, dynamic> json) {
  return {
    "id": json["id"], // Se extrae el id tal como lo devuelve TMDB.
    "titol": json["title"],
    "descripcio": json["overview"],
    "imatge": json["poster_path"] != null
        ? "https://image.tmdb.org/t/p/w500${json["poster_path"]}"
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

/// Función para obtener el nombre del usuario actual desde la colección "usuaris".
Future<String> getCurrentUserName() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final doc = await FirebaseFirestore.instance.collection("usuaris").doc(user.uid).get();
    return doc.data()?["nom"] ?? "Desconegut";
  }
  return "Desconegut";
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
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text("$label: ",
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white70)),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Función para abrir el trailer.
  void _openTrailer(String trailerKey, BuildContext context) async {
    final trailerUrl = "https://www.youtube.com/watch?v=$trailerKey";
    if (await canLaunch(trailerUrl)) {
      await launch(trailerUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el trailer')));
    }
  }

  // Diálogo para agregar comentario (se obtiene el nombre del usuario actual).
  void _showAddCommentDialog(BuildContext context, int movieId) {
    final TextEditingController _commentController = TextEditingController();
    double rating = 5.0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.black87,
            title: const Text("Agregar comentario", style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Selecciona tu nota:", style: TextStyle(color: Colors.white70)),
                Slider(
                  activeColor: Colors.deepOrangeAccent,
                  inactiveColor: Colors.grey,
                  value: rating,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: rating.toString(),
                  onChanged: (value) {
                    setState(() {
                      rating = value;
                    });
                  },
                ),
                TextField(
                  controller: _commentController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Escribe tu reseña aquí...",
                    hintStyle: TextStyle(color: Colors.white38),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  String comment = _commentController.text.trim();
                  if (comment.isNotEmpty) {
                    String author = await getCurrentUserName();
                    await _saveComment(movieId, rating, comment, author);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Comentario guardado")));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Debes escribir una reseña")));
                  }
                },
                child: const Text("Enviar"),
              ),
            ],
          );
        });
      },
    );
  }

  Future<void> _saveComment(
      int movieId, double rating, String comment, String author) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    await firestore.collection("comentarios").add({
      "movieId": movieId,
      "rating": rating,
      "comment": comment,
      "author": author,
      "timestamp": FieldValue.serverTimestamp(),
    });

    await firestore
        .collection("peliculas")
        .doc(movieId.toString())
        .set(movie.cast<String, dynamic>());
  }

  // Construye la lista de comentarios.
  Widget _buildCommentsList(int movieId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("comentarios")
          .where("movieId", isEqualTo: movieId)
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}",
              style: const TextStyle(color: Colors.white70));
        }
        if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
          return const Text("No hay comentarios aún",
              style: TextStyle(color: Colors.white70));
        }
        if (snapshot.hasData) {
          final comments = snapshot.data!.docs;
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final commentData = comments[index].data() as Map<String, dynamic>;
              return Card(
                color: Colors.black87,
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  title: Text(
                    commentData["author"] ?? "Desconegut",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        commentData["comment"] ?? "",
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Nota: ${commentData["rating"]?.toString() ?? "N/A"}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
        return const Text("No hay comentarios aún",
            style: TextStyle(color: Colors.white70));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Datos de la película: $movie");
    debugPrint("Llaves disponibles: ${movie.keys}");
    debugPrint("movie['id']: ${movie['id']}");

    String idioma = movie["original_language"] ?? "";
    idioma = languageMapping[idioma] ?? idioma;
    final int movieId = movie["id"] is int ? movie["id"] as int : 0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const SizedBox.shrink(),
        backgroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.deepOrangeAccent),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: true,
            expandedHeight: 300,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  movie["imatge"] != null && movie["imatge"].toString().isNotEmpty
                      ? Image.network(
                          movie["imatge"],
                          fit: BoxFit.cover,
                        )
                      : Container(color: Colors.grey[800]),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                          Colors.black.withOpacity(0.7)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie["titol"] ?? "Título no disponible",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow("ID", movieId.toString()),
                          _buildInfoRow("Fecha", movie["release_date"] ?? ""),
                          _buildInfoRow("Idioma", idioma),
                          _buildInfoRow("Duración", "${movie["runtime"]} minutos"),
                          if ((movie["tagline"] ?? "").toString().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                "\"${movie["tagline"]}\"",
                                style: const TextStyle(
                                    fontStyle: FontStyle.italic, color: Colors.redAccent),
                              ),
                            ),
                          const SizedBox(height: 8),
                          Text(
                            movie["descripcio"] ?? "Sin descripción",
                            style: const TextStyle(fontSize: 16, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<String?>(
                    future: movieId != 0
                        ? TmdbApi().fetchTrailerKey(movieId: movieId)
                        : Future.value(null),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasData && snapshot.data != null) {
                        return ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrangeAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          ),
                          onPressed: () => _openTrailer(snapshot.data!, context),
                          icon: const Icon(Icons.play_arrow, color: Colors.white),
                          label: const Text("Ver Trailer", style: TextStyle(color: Colors.white)),
                        );
                      } else {
                        return const Text("Trailer no disponible",
                            style: TextStyle(color: Colors.white70));
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrangeAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                    onPressed: () => _showAddCommentDialog(context, movieId),
                    icon: const Icon(Icons.add_comment, color: Colors.white),
                    label: const Text("Agregar comentario", style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white70),
                  const Text(
                    "Comentarios:",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildCommentsList(movieId),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
