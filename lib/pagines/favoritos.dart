import 'package:flutter/material.dart';
import 'package:proyecto/components/item_pelicula.dart';
import 'package:proyecto/data/base_de_dades.dart';
import 'package:proyecto/pagines/detalle_pelicula.dart';

class Favoritos extends StatefulWidget {
  const Favoritos({Key? key}) : super(key: key);

  @override
  State<Favoritos> createState() => _FavoritosState();
}

class _FavoritosState extends State<Favoritos> {
  final BaseDeDades db = BaseDeDades();

  @override
  void initState() {
    super.initState();
    // Recarga los datos de Hive para tener el estado más reciente
    db.carregarDades();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Filtrar las películas marcadas como favoritas
    List<Map<String, dynamic>> favoriteMovies =
        db.pelicules.where((movie) => movie["favorito"] == true).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Favoritos"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey.shade900,
      body: favoriteMovies.isEmpty
          ? const Center(
              child: Text(
                "No hay películas favoritas.",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.7,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: favoriteMovies.length,
              itemBuilder: (context, index) {
                final movie = favoriteMovies[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetallePelicula(movie: movie),
                      ),
                    );
                  },
                  child: ItemPelicula(
                    textPeli: movie["titol"] ?? "",
                    descripcio: movie["descripcio"] ?? "",
                    imatge: movie["imatge"] ?? "",
                    valorCheckBox: movie["favorito"] ?? false,
                    canviaValorCheckbox: (valor) {
                      setState(() {
                        movie["favorito"] = !movie["favorito"];
                      });
                      db.actualitzarDades();
                    },
                    esborraPeli: (_) {},
                  ),
                );
              },
            ),
    );
  }
}
