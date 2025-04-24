import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto/components/barra.dart';
import 'package:proyecto/components/draww.dart';
import 'package:proyecto/pagines/detalle_pelicula.dart';

// ------------------------------
// Clases para el fondo con corazones
// ------------------------------

/// Modelo para un corazón
class Heart {
  final Offset position; // Posición como valor relativo (0..1)
  final double size;
  final double rotation;
  final double twinkleOffset; // Para oscilar la opacidad

  Heart({
    required this.position,
    required this.size,
    required this.rotation,
    required this.twinkleOffset,
  });
}

/// CustomPainter para pintar corazones titilantes
class HeartFieldPainter extends CustomPainter {
  final List<Heart> hearts;
  final double animationValue;

  HeartFieldPainter({required this.hearts, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    for (final heart in hearts) {
      // Calcula la opacidad en función del ciclo (titileo)
      final double opacity = 0.5 + 0.5 * sin(animationValue + heart.twinkleOffset);
      // Define el estilo del corazón (se usa emoji ♥)
      final textSpan = TextSpan(
        text: '❤️',  // Puedes cambiar el emoji o incluso usar un Icon si prefieres
        style: TextStyle(
          fontSize: heart.size,
          color: Colors.redAccent.withOpacity(opacity),
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      // Calcula la posición absoluta de la imagen
      final Offset pos = Offset(
        heart.position.dx * size.width - textPainter.width / 2,
        heart.position.dy * size.height - textPainter.height / 2,
      );
      // Guarda el estado del canvas y aplica la rotación alrededor del centro del corazón
      canvas.save();
      canvas.translate(pos.dx + textPainter.width / 2, pos.dy + textPainter.height / 2);
      canvas.rotate(heart.rotation);
      canvas.translate(-textPainter.width / 2, -textPainter.height / 2);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant HeartFieldPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

/// Fondo animado que combina gradientes y el campo de corazones titilantes
class AnimatedGradientBackground extends StatefulWidget {
  const AnimatedGradientBackground({Key? key}) : super(key: key);

  @override
  _AnimatedGradientBackgroundState createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState
    extends State<AnimatedGradientBackground> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late List<LinearGradient> gradients;
  late Timer _gradientTimer;

  // Controlador para la animación de los corazones
  late AnimationController _heartController;
  late Animation<double> _heartAnimation;
  final int numberOfHearts = 80;
  late List<Heart> hearts;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    // Gradientes en tonos rojos, rosados y similares
    gradients = [
      LinearGradient(
        colors: [Colors.red, Colors.pink, Colors.redAccent, Colors.pinkAccent],
        stops: const [0.0, 0.33, 0.66, 1.0],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      LinearGradient(
        colors: [Colors.pinkAccent, Colors.redAccent, Colors.red, Colors.pink],
        stops: const [0.0, 0.33, 0.66, 1.0],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
      LinearGradient(
        colors: [Colors.red.shade900, Colors.red, Colors.pink.shade200, Colors.red.shade400],
        stops: const [0.0, 0.5, 0.75, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      LinearGradient(
        colors: [Colors.pink, Colors.redAccent, Colors.red.shade300, Colors.pinkAccent],
        stops: const [0.0, 0.3, 0.6, 1.0],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
    ];

    // Cambia gradiente cada 5 segundos
    _gradientTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % gradients.length;
      });
    });

    // Genera los corazones en posiciones aleatorias (usamos coordenadas relativas 0..1)
    hearts = List.generate(numberOfHearts, (_) {
      return Heart(
        position: Offset(random.nextDouble(), random.nextDouble()),
        size: random.nextDouble() * 20 + 15, // Tamaño entre 15 y 35
        rotation: random.nextDouble() * 2 * pi,
        twinkleOffset: random.nextDouble() * 2 * pi,
      );
    });

    // Controlador para la animación de los corazones (ciclo de 3 segundos)
    _heartController = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _heartAnimation = Tween<double>(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.easeInOut),
    );
    _heartController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _gradientTimer.cancel();
    _heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _heartAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Fondo de gradiente animado
            AnimatedContainer(
              duration: const Duration(seconds: 3),
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: gradients[_currentIndex],
              ),
            ),
            // Campo de corazones titilantes
            CustomPaint(
              size: MediaQuery.of(context).size,
              painter: HeartFieldPainter(
                hearts: hearts,
                animationValue: _heartAnimation.value,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ------------------------------------------
// Resto de la página de Favoritos (sin cambios en la funcionalidad)
// ------------------------------------------
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
      // No se define backgroundColor para permitir ver el fondo animado.
      appBar: Barra(username: username, title: "Favoritos"),
      drawer: Draww(username: username),
      body: Stack(
        children: [
          // Fondo animado con gradiente y corazones (ocupando toda la pantalla)
          const Positioned.fill(child: AnimatedGradientBackground()),
          // Contenido de favoritos por encima del fondo
          FutureBuilder<String?>(
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
                  // Cada documento contiene el campo "movie"
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
                                                  size: 40,
                                                  color: Colors.grey),
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
        ],
      ),
    );
  }
}
