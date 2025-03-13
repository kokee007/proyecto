import 'package:hive/hive.dart';

class BaseDeDades {
  // Singleton: todas las instancias apuntan al mismo objeto
  static final BaseDeDades _instance = BaseDeDades._internal();
  factory BaseDeDades() => _instance;
  BaseDeDades._internal();

  List<Map<String, dynamic>> pelicules = [];

  final Box _boxDeLaHive = Hive.box("box_pelicules");

  void carregarDades() {
    final rawData = _boxDeLaHive.get("box_pelicules");
    if (rawData != null) {
      pelicules = (rawData as List)
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }
  }

  void actualitzarDades() {
    _boxDeLaHive.put("box_pelicules", pelicules);
  }

  void crearDadesExemple() {
    pelicules = [
      {
        "titol": "Moby Dick",
        "descripcio":
            "El único superviviente de un barco ballenero perdido cuenta la historia de la obsesión autodestructiva de su capitán por cazar la ballena blanca, Moby Dick.",
        "imatge":
            "https://m.media-amazon.com/images/M/MV5BZWUyOTgyMzktMjhmNi00NThkLTkxMGEtMGU0ZDEzZWQxNjNlXkEyXkFqcGc@._V1_.jpg",
        "favorito": false,
        "genero": "Aventura"
      },
      {
        "titol": "Interestellar",
        "descripcio":
            "Las aventuras de un grupo de exploradores que aprovechan un agujero de gusano recién descubierto para superar las limitaciones de los viajes espaciales humanos y conquistar las enormes distancias que implica un viaje interestelar.",
        "imatge":
            "https://es.web.img3.acsta.net/pictures/14/10/02/11/07/341344.jpg",
        "favorito": false,
        "genero": "Ciencia Ficción"
      }
    ];
  }
}
