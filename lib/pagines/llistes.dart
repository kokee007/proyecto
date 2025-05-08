import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto/api/tmdb_api.dart';
import 'package:proyecto/api/movie.dart';

class Llistes extends StatefulWidget {
  const Llistes({Key? key}) : super(key: key);

  @override
  State<Llistes> createState() => _LlistesState();
}

class _LlistesState extends State<Llistes> {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Mis Listas"),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const CreateListDialog(),
          );
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("listas")
            .where("userId", isEqualTo: user?.uid)
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text("Error: ${snapshot.error}",
                    style: const TextStyle(color: Colors.white)));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
                child: Text("No tienes listas creadas",
                    style: TextStyle(color: Colors.white)));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final listName = data["listName"] ?? "Sin nombre";
              final movies = data["movies"] as List<dynamic>? ?? [];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(listName),
                  subtitle: Text("${movies.length} películas"),
                  trailing: const Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    // Aquí podrías navegar a una pantalla de detalle de la lista
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class CreateListDialog extends StatefulWidget {
  const CreateListDialog({Key? key}) : super(key: key);

  @override
  _CreateListDialogState createState() => _CreateListDialogState();
}

class _CreateListDialogState extends State<CreateListDialog> {
  final TextEditingController _listNameController = TextEditingController();
  final TextEditingController _movieSearchController = TextEditingController();

  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _selectedMovies = [];
  bool _isSearching = false;

  Timer? _debounce;

  /// Busca películas usando la API de TMDb con manejo de excepciones.
  Future<void> _searchMovies(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }
    setState(() {
      _isSearching = true;
    });
    try {
      final tmdbApi = TmdbApi();
      final rawMovies = await tmdbApi.searchMovies(query: query, page: 1);
      List<Map<String, dynamic>> moviesFromApi = rawMovies.map((item) {
        final movie = Movie.fromJson(Map<String, dynamic>.from(item));
        return {
          "id": movie.id,
          "title": movie.title,
          "overview": movie.overview,
          "poster": movie.posterPath.isNotEmpty
              ? 'https://image.tmdb.org/t/p/w200${movie.posterPath}'
              : '',
        };
      }).toList();
      if (mounted) {
        setState(() {
          _searchResults = moviesFromApi;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
      debugPrint("Error en la búsqueda: $e");
    }
  }

  /// Aplica debounce a la búsqueda.
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _searchMovies(query);
    });
  }

  /// Agrega la película a la lista seleccionada.
  void _addMovieToList(Map<String, dynamic> movie) {
    if (!_selectedMovies.contains(movie)) {
      setState(() {
        _selectedMovies.add(movie);
      });
    }
  }

  /// Remueve la película de la lista seleccionada.
  void _removeMovieFromList(Map<String, dynamic> movie) {
    setState(() {
      _selectedMovies.remove(movie);
    });
  }

  /// Crea la lista en Firebase.
  Future<void> _createList() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final listName = _listNameController.text.trim();
    if (listName.isEmpty) return;

    final listsCollection = FirebaseFirestore.instance.collection("listas");
    await listsCollection.add({
      "userId": user.uid,
      "listName": listName,
      "movies": _selectedMovies,
      "createdAt": FieldValue.serverTimestamp(),
    });

    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _listNameController.dispose();
    _movieSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Crear Lista"),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Campo para el nombre de la lista.
              TextField(
                controller: _listNameController,
                decoration: const InputDecoration(
                  labelText: "Nombre de la lista",
                ),
              ),
              const SizedBox(height: 10),
              // Campo de búsqueda para películas.
              TextField(
                controller: _movieSearchController,
                decoration: InputDecoration(
                  labelText: "Buscar película",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      _searchMovies(_movieSearchController.text);
                    },
                  ),
                ),
                onChanged: _onSearchChanged,
              ),
              const SizedBox(height: 10),
              // Muestra el progreso o los resultados de la búsqueda.
              _isSearching
                  ? const CircularProgressIndicator()
                  : _searchResults.isNotEmpty
                      ? SizedBox(
                          height: 200,
                          child: ListView.builder(
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final movie = _searchResults[index];
                              return ListTile(
                                leading: movie["poster"] != ""
                                    ? Image.network(
                                        movie["poster"],
                                        width: 50,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 50,
                                        color: Colors.grey,
                                      ),
                                title: Text(movie["title"]),
                                subtitle: Text(
                                  movie["overview"],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    _addMovieToList(movie);
                                  },
                                ),
                              );
                            },
                          ),
                        )
                      : Container(),
              const SizedBox(height: 10),
              // Muestra las películas seleccionadas.
              _selectedMovies.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Películas seleccionadas:"),
                        SizedBox(
                          height: 150,
                          child: ListView.builder(
                            itemCount: _selectedMovies.length,
                            itemBuilder: (context, index) {
                              final movie = _selectedMovies[index];
                              return ListTile(
                                leading: movie["poster"] != ""
                                    ? Image.network(
                                        movie["poster"],
                                        width: 50,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 50,
                                        color: Colors.grey,
                                      ),
                                title: Text(movie["title"]),
                                trailing: IconButton(
                                  icon: const Icon(Icons.remove_circle),
                                  onPressed: () {
                                    _removeMovieFromList(movie);
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  : Container(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: _createList,
          child: const Text("Crear Lista"),
        ),
      ],
    );
  }
}
