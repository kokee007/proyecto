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

  // Función auxiliar para unificar la decoración de los campos
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.grey.shade800,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white70.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey.shade900,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text(
        "Agregar Nueva Película",
        style: TextStyle(
          color: Colors.redAccent,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Campo Título
            TextField(
              controller: widget.tecTextPeli,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("Título"),
            ),
            const SizedBox(height: 12),
            // Campo Descripción
            TextField(
              controller: widget.tecTextDescripcio,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("Descripción"),
            ),
            const SizedBox(height: 12),
            // Campo URL Imagen
            TextField(
              controller: widget.tecTextImatge,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("URL Imagen"),
            ),
            const SizedBox(height: 16),
            // Dropdown para seleccionar género
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Género",
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey.shade800,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white70.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.redAccent),
                ),
              ),
              dropdownColor: Colors.grey.shade900,
              value: _selectedGenre,
              items: _generos.map((genero) {
                return DropdownMenuItem<String>(
                  value: genero,
                  child: Text(
                    genero,
                    style: const TextStyle(color: Colors.white),
                  ),
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
        // Botón Cancelar
        TextButton(
          onPressed: widget.accioCancelar,
          child: const Text(
            "Cancelar",
            style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Botón Guardar
        ElevatedButton(
          onPressed: () {
            final novaPeli = {
              "titol": widget.tecTextPeli.text,
              "descripcio": widget.tecTextDescripcio.text,
              "imatge": widget.tecTextImatge.text,
              "favorito": false,
              "genero": _selectedGenre ?? "Sin género",
            };
            widget.accioGuardar(novaPeli);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "Guardar",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
