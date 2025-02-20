import 'package:flutter/material.dart';

class NovaPelicula extends StatefulWidget {
  final TextEditingController tecTextPeli;
  final TextEditingController tecTextDescripcio;
  final TextEditingController tecTextImatge;
  final Function(Map<String, dynamic>) accioGuardar;
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
  State<NovaPelicula> createState() => _NovaPeliculaState();
}

class _NovaPeliculaState extends State<NovaPelicula> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Nueva Película"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: widget.tecTextPeli,
              decoration: const InputDecoration(
                labelText: "Título",
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: widget.tecTextDescripcio,
              decoration: const InputDecoration(
                labelText: "Descripción",
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: widget.tecTextImatge,
              decoration: const InputDecoration(
                labelText: "URL de la imagen",
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: isFavorite,
                  onChanged: (valor) {
                    setState(() {
                      isFavorite = valor ?? false;
                    });
                  },
                  activeColor: Colors.teal,
                ),
                const Text("Marcar como favorito"),
              ],
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
            // Verificamos que se ingrese al menos el título
            if (widget.tecTextPeli.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("El título es obligatorio")),
              );
              return;
            }
            Map<String, dynamic> novaPeli = {
              "titol": widget.tecTextPeli.text.trim(),
              "descripcio": widget.tecTextDescripcio.text.trim(),
              "imatge": widget.tecTextImatge.text.trim(),
              "favorito": isFavorite,
            };
            widget.accioGuardar(novaPeli);
          },
          child: const Text("Guardar"),
        ),
      ],
    );
  }
}
