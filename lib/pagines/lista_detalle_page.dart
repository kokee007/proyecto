import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto/components/item_pelicula.dart';
import 'package:proyecto/pagines/detalle_pelicula.dart';

class ListaDetallePage extends StatefulWidget {
  final String listId;
  final String listName;
  final List<Map<String, dynamic>> movies;
  final String ownerId;
  final bool isPublic;

  const ListaDetallePage({
    Key? key,
    required this.listId,
    required this.listName,
    required this.movies,
    required this.ownerId,
    required this.isPublic,
  }) : super(key: key);

  @override
  _ListaDetallePageState createState() => _ListaDetallePageState();
}

class _ListaDetallePageState extends State<ListaDetallePage> {
  late List<Map<String, dynamic>> _movies;
  String? _currentUid;

  @override
  void initState() {
    super.initState();
    _movies = List.from(widget.movies);
    _currentUid = FirebaseAuth.instance.currentUser?.uid;
  }

  bool get _isOwner => _currentUid != null && _currentUid == widget.ownerId;

  Future<void> _removeMovie(Map<String, dynamic> movie) async {
    if (!_isOwner) return;

    try {
      await FirebaseFirestore.instance
          .collection('listas')
          .doc(widget.listId)
          .update({
        'movies': FieldValue.arrayRemove([movie]),
      });

      setState(() {
        _movies.remove(movie);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Película eliminada de la lista')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.listName),
        backgroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.deepOrangeAccent),
      ),
      body: _movies.isEmpty
          ? const Center(
              child: Text(
                'No hay películas en esta lista',
                style: TextStyle(color: Colors.white),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.65,
              ),
              itemCount: _movies.length,
              itemBuilder: (context, index) {
                final m = _movies[index];
                return Stack(
                  children: [
                    // Navegar a detalle completo
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetallePelicula(movie: m),
                            ),
                          );
                        },
                        child: ItemPelicula(
                          textPeli: m['title'] ?? m['titol'] ?? '',
                          descripcio: m['overview'] ?? m['descripcio'] ?? '',
                          imatge: m['poster'] ?? m['imatge'] ?? '',
                          valorCheckBox: false,
                          canviaValorCheckbox: null,
                          showHeart: false,
                        ),
                      ),
                    ),

                    // Botón rojo “-” solo para el creador
                    if (_isOwner)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => _removeMovie(m),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.remove,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
    );
  }
}
