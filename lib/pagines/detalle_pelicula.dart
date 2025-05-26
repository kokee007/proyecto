// lib/pagines/detalle_pelicula.dart

import 'package:flutter/material.dart';
import 'package:proyecto/api/tmdb_api.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Convierte JSON de TMDB en un Map usable.
Map<String, dynamic> parseMovie(Map<String, dynamic> json) => {
      "id": json["id"],
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
      "favorito": false,
    };

/// Recupera el nombre del usuario logueado.
Future<String> getCurrentUserName() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final doc = await FirebaseFirestore.instance
        .collection("usuaris")
        .doc(user.uid)
        .get();
    return doc.data()?["nom"] ?? "Desconegut";
  }
  return "Desconegut";
}

class DetallePelicula extends StatelessWidget {
  final Map<String, dynamic> movie;
  const DetallePelicula({Key? key, required this.movie}) : super(key: key);

  static const Map<String, String> languageMapping = {
    "en": "English",
    "es": "Español",
    "fr": "Français",
    "de": "Deutsch",
    "it": "Italiano",
    "pt": "Português",
    "ja": "Japanese",
    "ko": "Korean",
    "zh": "Chinese",
    "hi": "Hindi",
  };

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text("$label: ",
              style: theme.textTheme.bodyMedium!
                  .copyWith(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }

  void _openTrailer(String key, BuildContext context) async {
    final url = "https://www.youtube.com/watch?v=$key";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el trailer')),
      );
    }
  }

  /// 1) Muestra lista de tus documentes "listas" para elegir destino
  Future<void> _showListSelectionDialog(BuildContext ctx) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para ver tus listas')),
      );
      return;
    }

    // Recupera tus listas
    final snap = await FirebaseFirestore.instance
        .collection('listas')              // <-- tu colección de listas
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .get();

    final listas = snap.docs;
    if (listas.isEmpty) {
      return showDialog(
        context: ctx,
        builder: (_) => AlertDialog(
          title: const Text('Selecciona una lista'),
          content: const Text('No tienes ninguna lista creada.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
          ],
        ),
      );
    }

    // Construye el diálogo
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Selecciona una lista'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: listas.length,
            itemBuilder: (context, i) {
              final doc = listas[i];
              final data = doc.data() as Map<String, dynamic>;

              // Campo que contiene el nombre de tu lista
              final listName = data['listName'] as String? ?? '<sin nombre>';

              return ListTile(
                title: Text(listName),
                onTap: () {
                  Navigator.pop(ctx);
                  _addToSpecificList(ctx, doc.id, listName);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        ],
      ),
    );
  }

  /// 2) Añade la película al array "movies" de la lista elegida
  Future<void> _addToSpecificList(
      BuildContext ctx, String listId, String listName) async {
    final ref = FirebaseFirestore.instance
        .collection('listas')
        .doc(listId);

    await ref.update({
      'movies': FieldValue.arrayUnion([movie])
    });

    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(content: Text('Película añadida a “$listName”')),
    );
  }

  void _showAddCommentDialog(BuildContext ctx, int movieId) {
    final ctrl = TextEditingController();
    double rating = 5.0;
    final theme = Theme.of(ctx);

    showDialog(
      context: ctx,
      builder: (_) => StatefulBuilder(
        builder: (_, setState) => AlertDialog(
          backgroundColor: theme.dialogBackgroundColor,
          title:
              Text("Agregar comentario", style: theme.textTheme.titleLarge),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Selecciona tu nota:", style: theme.textTheme.bodyMedium),
              Slider(
                activeColor: theme.colorScheme.secondary,
                inactiveColor: theme.dividerColor,
                value: rating,
                min: 1,
                max: 10,
                divisions: 9,
                label: rating.toString(),
                onChanged: (v) => setState(() => rating = v),
              ),
              TextField(
                controller: ctrl,
                style: theme.textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: "Escribe tu reseña aquí.",
                  hintStyle: theme.textTheme.bodySmall,
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: theme.dividerColor)),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("Cancelar", style: theme.textTheme.labelLarge),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary),
              onPressed: () async {
                final comment = ctrl.text.trim();
                if (comment.isNotEmpty) {
                  final author = await getCurrentUserName();
                  await _saveComment(movieId, rating, comment, author);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                      content: Text('Comentario guardado')));
                } else {
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                      content: Text('Debes escribir una reseña')));
                }
              },
              child: Text("Aceptar",
                  style: theme.textTheme.labelLarge!
                      .copyWith(color: theme.colorScheme.onSecondary)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveComment(
      int movieId, double rating, String comment, String author) async {
    final fs = FirebaseFirestore.instance;
    await fs.collection("comentarios").add({
      "movieId": movieId,
      "rating": rating,
      "comment": comment,
      "author": author,
      "timestamp": FieldValue.serverTimestamp(),
    });
    // Opcional: guarda en subcolección de películas
    await fs
        .collection("peliculas")
        .doc(movieId.toString())
        .set(movie.cast<String, dynamic>());
  }

  Widget _buildCommentsList(BuildContext context, int movieId) {
    final theme = Theme.of(context);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("comentarios")
          .where("movieId", isEqualTo: movieId)
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (ctx, snap) {
        if (snap.hasError) {
          return Text("Error: ${snap.error}",
              style: theme.textTheme.bodyMedium!
                  .copyWith(color: theme.colorScheme.error));
        }
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return Text("No hay comentarios aún",
              style: theme.textTheme.bodyMedium!
                  .copyWith(color: theme.hintColor));
        }
        final comments = snap.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          itemBuilder: (__, index) {
            final c = comments[index].data()! as Map<String, dynamic>;
            return Card(
              color: theme.cardColor,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(
                  c["author"] ?? "Usuario",
                  style: theme.textTheme.bodyMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((c["comment"] as String?)?.isNotEmpty == true)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(c["comment"]!,
                            style: theme.textTheme.bodyMedium),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text("Nota: ${c["rating"]}",
                          style: theme.textTheme.bodySmall),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final code = movie["original_language"] ?? "";
    final idioma = languageMapping[code] ?? code;
    final movieId = (movie["id"] is int) ? movie["id"] as int : 0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.iconTheme,
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
                  movie["imatge"] != null &&
                          movie["imatge"].toString().isNotEmpty
                      ? Image.network(movie["imatge"], fit: BoxFit.cover)
                      : Container(color: theme.dividerColor),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.scaffoldBackgroundColor.withOpacity(0.7),
                          Colors.transparent,
                          theme.scaffoldBackgroundColor.withOpacity(0.7),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: theme.cardColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(movie["titol"] ?? "Título no disponible",
                              style: theme.textTheme.headlineSmall!
                                  .copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          _buildInfoRow(context, "Fecha",
                              movie["release_date"] ?? ""),
                          _buildInfoRow(context, "Idioma", idioma),
                          if ((movie["tagline"] ?? "").toString().isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                "\"${movie["tagline"]}\"",
                                style: theme.textTheme.bodySmall!
                                    .copyWith(fontStyle: FontStyle.italic),
                              ),
                            ),
                          const SizedBox(height: 8),
                          Text(movie["descripcio"] ?? "Sin descripción",
                              style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Botón de trailer
                  FutureBuilder<String?>(
                    future: movieId != 0
                        ? TmdbApi().fetchTrailerKey(movieId: movieId)
                        : Future.value(null),
                    builder: (ctx, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      } else if (snap.hasData && snap.data != null) {
                        return ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.secondary,
                            foregroundColor: theme.colorScheme.onSecondary,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                          ),
                          onPressed: () =>
                              _openTrailer(snap.data!, context),
                          icon: Icon(Icons.play_arrow,
                              color: theme.iconTheme.color),
                          label: Text("Ver Trailer",
                              style: theme.textTheme.labelLarge),
                        );
                      } else {
                        return Text("Trailer no disponible",
                            style: theme.textTheme.bodyMedium!
                                .copyWith(color: theme.hintColor));
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Botón: abre diálogo para seleccionar lista
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: theme.colorScheme.onSecondary,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                    ),
                    onPressed: () => _showListSelectionDialog(context),
                    icon: Icon(Icons.playlist_add,
                        color: theme.iconTheme.color),
                    label: Text("Agregar a mi lista",
                        style: theme.textTheme.labelLarge),
                  ),
                  const SizedBox(height: 16),

                  // Botón de comentarios
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: theme.colorScheme.onSecondary,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                    ),
                    onPressed: () =>
                        _showAddCommentDialog(context, movieId),
                    icon: Icon(Icons.add_comment,
                        color: theme.iconTheme.color),
                    label: Text("Agregar comentario",
                        style: theme.textTheme.labelLarge),
                  ),
                  const SizedBox(height: 16),

                  Divider(color: theme.dividerColor),
                  Text("Comentarios:",
                      style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  _buildCommentsList(context, movieId),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
