import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto/components/barra.dart';
import 'package:proyecto/components/draww.dart';
import 'package:proyecto/pagines/detalle_pelicula.dart';

class FavoritosPage extends StatelessWidget {
  const FavoritosPage({Key? key}) : super(key: key);

  /// Obtiene el UID del usuario actual.
  Future<String?> getUserUid() async {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    final username = ModalRoute.of(context)?.settings.arguments as String?;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: Barra(username: username, title: "Favoritos"),
      drawer: Draww(username: username),
      body: FutureBuilder<String?>(
        future: getUserUid(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final uid = snapshot.data;
          if (uid == null) {
            return const Center(
              child: Text(
                "No se encontró usuario",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("favoritos")
                .where("userId", isEqualTo: uid)
                .orderBy("timestamp", descending: true)
                .snapshots(),
            builder: (context, favSnapshot) {
              if (favSnapshot.hasError) {
                return Center(
                  child: Text("Error: ${favSnapshot.error}",
                      style: const TextStyle(color: Colors.white)),
                );
              }
              if (favSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = favSnapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return const Center(
                  child: Text(
                    "No tienes favoritos",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                );
              }
              // Cada documento debe tener el campo "movie" que contiene la información de la película.
              final favorites =
              docs.map((doc) => doc["movie"] as Map<String, dynamic>).toList();

              return GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.7,
                ),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final movie = favorites[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetallePelicula(movie: movie),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 6,
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: movie["imatge"].toString().isNotEmpty
                                ? Image.network(
                              movie["imatge"],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: Colors.grey[800],
                                    child: const Icon(Icons.broken_image,
                                        size: 40, color: Colors.grey),
                                  ),
                            )
                                : Container(
                              color: Colors.grey[800],
                              child: const Icon(Icons.movie,
                                  size: 40, color: Colors.grey),
                            ),
                          ),
                          Container(
                            color: Colors.black87,
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              movie["titol"] ?? "Sin título",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
