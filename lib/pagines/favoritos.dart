import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto/components/barra.dart';
import 'package:proyecto/components/draww.dart';
import 'package:proyecto/pagines/detalle_pelicula.dart';

/// Modelo interno para un corazón animado.
class _Heart {
  final Offset position;
  final double size;
  final double rotation;
  final double twinkleOffset;
  _Heart({
    required this.position,
    required this.size,
    required this.rotation,
    required this.twinkleOffset,
  });
}

/// CustomPainter para dibujar corazones titilantes.
class _HeartFieldPainter extends CustomPainter {
  final List<_Heart> hearts;
  final double animationValue;
  _HeartFieldPainter({required this.hearts, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final painter = TextPainter(textDirection: TextDirection.ltr);
    for (final heart in hearts) {
      final opacity = 0.5 + 0.5 * sin(animationValue + heart.twinkleOffset);
      painter.text = TextSpan(
        text: '❤️',
        style: TextStyle(fontSize: heart.size, color: Colors.redAccent.withOpacity(opacity)),
      );
      painter.layout();

      final dx = heart.position.dx * size.width;
      final dy = heart.position.dy * size.height;
      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(animationValue + heart.rotation);
      painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _HeartFieldPainter old) =>
      old.animationValue != animationValue;
}

/// Widget que muestra el fondo animado de corazones.
class AnimatedHeartBackground extends StatefulWidget {
  const AnimatedHeartBackground({Key? key}) : super(key: key);
  @override
  _AnimatedHeartBackgroundState createState() => _AnimatedHeartBackgroundState();
}

class _AnimatedHeartBackgroundState extends State<AnimatedHeartBackground>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  late final List<_Heart> _hearts;

  @override
  void initState() {
    super.initState();
    final rnd = Random();
    _hearts = List.generate(80, (_) => _Heart(
          position: Offset(rnd.nextDouble(), rnd.nextDouble()),
          size: rnd.nextDouble() * 20 + 15,
          rotation: rnd.nextDouble() * 2 * pi,
          twinkleOffset: rnd.nextDouble() * 2 * pi,
        ));
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 2 * pi).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        return CustomPaint(
          size: Size.infinite,
          painter: _HeartFieldPainter(
            hearts: _hearts,
            animationValue: _animation.value,
          ),
        );
      },
    );
  }
}

/// Pantalla de favoritos con fondo animado y listado de películas.
class FavoritosPage extends StatelessWidget {
  const FavoritosPage({Key? key}) : super(key: key);

  Future<String?> _getUserUid() async => FirebaseAuth.instance.currentUser?.uid;

  /// Elimina la película de favoritos para el usuario actual.
  Future<void> removeFavorite(Map<String, dynamic> movie) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final String docId = '${user.uid}_${movie["id"]}';
    await FirebaseFirestore.instance.collection("favoritos").doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    final username = ModalRoute.of(context)?.settings.arguments as String?;
    return Scaffold(
      appBar: Barra(title: 'Favoritos', username: username),
      drawer: Draww(username: username),
      body: Stack(
        children: [
          const Positioned.fill(child: AnimatedHeartBackground()),
          FutureBuilder<String?>(
            future: _getUserUid(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final uid = snapshot.data;
              if (uid == null) {
                return const Center(
                  child: Text('No se encontró usuario', style: TextStyle(color: Colors.white)),
                );
              }
              // Cada documento contiene el campo "movie" con la información de la película.
              final favorites = docs.map((doc) => doc["movie"] as Map<String, dynamic>).toList();

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
                  return Stack(
                    children: [
                      InkWell(
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
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          color: Colors.grey[800],
                                          child: const Icon(
                                            Icons.broken_image,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        color: Colors.grey[800],
                                        child: const Icon(
                                          Icons.movie,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
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
                      ),
                      // Botón para quitar de favoritos (en la esquina superior derecha).
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                          onPressed: () async {
                            await removeFavorite(movie);
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
