import 'package:flutter/material.dart';

class DetallePelicula extends StatelessWidget {
  final Map movie; // Objeto con los datos de la película

  const DetallePelicula({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movie["titol"] ?? "Detalle de la Película"),
        backgroundColor: Colors.grey[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Muestra la imagen con altura fija para que no ocupe tanto espacio.
            if (movie["imatge"] != null && movie["imatge"].toString().isNotEmpty)
              Center(
                child: SizedBox(
                  height: 400, // Ajusta este valor para cambiar el tamaño de la imagen
                  child: Image.network(
                    movie["imatge"],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error, size: 80),
                  ),
                ),
              )
            else
              Center(
                child: Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.movie, size: 80, color: Colors.grey),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              movie["titol"] ?? "Título no disponible",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              movie["descripcio"] ?? "Sin descripción",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  movie["favorito"] == true
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: movie["favorito"] == true ? Colors.red : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text("Favorito: ${movie["favorito"] == true ? "Sí" : "No"}"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
