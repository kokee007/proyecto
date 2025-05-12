import 'package:flutter/material.dart';

class ItemPelicula extends StatelessWidget {
  final String textPeli;
  final String descripcio;
  final String imatge;
  final bool valorCheckBox;
  final ValueChanged<bool?>? canviaValorCheckbox;
  final Function(BuildContext)? esborraPeli;
  final bool showHeart; // para mostrar/ocultar el corazón

  const ItemPelicula({
    Key? key,
    required this.textPeli,
    required this.descripcio,
    required this.imatge,
    this.valorCheckBox = false,
    this.canviaValorCheckbox,
    this.esborraPeli,
    this.showHeart = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.65, // Ajusta según tu gusto
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 4,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Imagen arriba
              Expanded(
                child: imatge.isNotEmpty
                    ? Image.network(
                        imatge,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.white,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
              ),
              // Pie con el título y (opcional) el corazón
              Container(
                color: Colors.black87,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        textPeli,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (showHeart)
                      IconButton(
                        icon: Icon(
                          valorCheckBox ? Icons.favorite : Icons.favorite_border,
                          color: valorCheckBox ? Colors.redAccent : Colors.white,
                        ),
                        onPressed: () {
                          if (canviaValorCheckbox != null) {
                            canviaValorCheckbox!(!valorCheckBox);
                          }
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
