import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ItemPelicula extends StatelessWidget {
  final String textPeli;
  final String descripcio;
  final String imatge;
  final bool valorCheckBox; // Indica si es favorito o no
  final ValueChanged<bool?>? canviaValorCheckbox;
  final Function(BuildContext)? esborraPeli;

  const ItemPelicula({
    super.key,
    required this.textPeli,
    required this.descripcio,
    required this.imatge,
    required this.valorCheckBox,
    required this.canviaValorCheckbox,
    required this.esborraPeli,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Slidable(
        // Acción de borrado con deslizamiento
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              icon: Icons.delete,
              backgroundColor: Colors.purple,
              borderRadius: BorderRadius.circular(10),
              onPressed: esborraPeli,
            ),
          ],
        ),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Imagen de la película
              Expanded(
                child: imatge.isNotEmpty
                    ? Image.network(
                        imatge,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.broken_image,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.movie,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
              ),
              // Título
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  textPeli,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[800],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Descripción
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  descripcio,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              // Fila inferior con icono de corazón para marcar como favorito
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(
                      valorCheckBox ? Icons.favorite : Icons.favorite_border,
                      color: valorCheckBox ? Colors.red : Colors.grey,
                    ),
                    onPressed: () {
                      // Se invierte el estado y se llama al callback
                      canviaValorCheckbox?.call(!valorCheckBox);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
