import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ItemPelicula extends StatelessWidget {
  final String textPeli;
  final String descripcio;
  final String imatge;
  final bool valorCheckBox;
  final ValueChanged<bool?>? canviaValorCheckbox;
  final Function(BuildContext)? esborraPeli;

  const ItemPelicula({
    Key? key,
    required this.textPeli,
    required this.descripcio,
    required this.imatge,
    required this.valorCheckBox,
    required this.canviaValorCheckbox,
    required this.esborraPeli,
  }) : super(key: key);

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
              // Imagen: se intenta cargar la URL y, si falla, se muestra un contenedor con un ícono
              Expanded(
                child: imatge.isNotEmpty
                    ? Image.network(
                        imatge,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.broken_image,
                            size: 40,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.movie,
                          size: 40,
                          color: Colors.grey[600],
                        ),
                      ),
              ),
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
              // Fila inferior con checkbox para marcar como favorito
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Checkbox(
                    value: valorCheckBox,
                    onChanged: canviaValorCheckbox,
                    activeColor: Colors.teal,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
