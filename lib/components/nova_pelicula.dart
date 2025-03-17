import 'package:flutter/material.dart';

class NovaPelicula extends StatefulWidget {
  final TextEditingController tecTextPeli;
  final TextEditingController tecTextDescripcio;
  final TextEditingController tecTextImatge;
  final Function(Map<String, dynamic> novaPeli) accioGuardar;
  final VoidCallback accioCancelar;

  const NovaPelicula({
    Key? key,
    required this.tecTextPeli,
    required this.tecTextDescripcio,
    required this.tecTextImatge,
    required this.accioGuardar,
    required this.accioCancelar,
  }) : super(key: key);

  @override
  _NovaPeliculaState createState() => _NovaPeliculaState();
}

class _NovaPeliculaState extends State<NovaPelicula> {
  // Lista de géneros disponibles
  final List<String> _generos = [
    'Acción',
    'Drama',
    'Comedia',
    'Terror',
    'Thriller',
    'Romance',
    'Ciencia Ficción',
    'Fantasía',
    'Aventura',
    'Documental'
  ];

  // Género seleccionado (por defecto el primero de la lista)
  String? _selectedGenre;

  @override
  void initState() {
    super.initState();
    _selectedGenre = _generos.first;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Agregar Nueva Película"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: widget.tecTextPeli,
              decoration: const InputDecoration(labelText: "Título"),
            ),
            TextField(
              controller: widget.tecTextDescripcio,
              decoration: const InputDecoration(labelText: "Descripción"),
            ),
            TextField(
              controller: widget.tecTextImatge,
              decoration: const InputDecoration(labelText: "URL Imagen"),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Género",
                border: OutlineInputBorder(),
              ),
              value: _selectedGenre,
              items: _generos.map((genero) {
                return DropdownMenuItem<String>(
                  value: genero,
                  child: Text(genero),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGenre = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.accioCancelar,
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () {
            // Se crea el objeto con el género seleccionado incluido
            final novaPeli = {
              "titol": widget.tecTextPeli.text,
              "descripcio": widget.tecTextDescripcio.text,
              "imatge": widget.tecTextImatge.text,
              "favorito": false,
              "genero": _selectedGenre ?? "Sin género",
            };
            widget.accioGuardar(novaPeli);
          },
          child: const Text("Guardar"),
        ),
      ],
    );
  }
}
