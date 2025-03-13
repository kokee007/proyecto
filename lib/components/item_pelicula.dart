import 'package:flutter/material.dart';

class ItemPelicula extends StatelessWidget {
  final String textPeli;
  final String descripcio;
  final String imatge;
  final bool valorCheckBox;
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
    return Card(
      color: Colors.grey.shade900,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: imatge.isNotEmpty
                ? Image.network(
                    imatge,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.black,
                      child: const Icon(
                        Icons.broken_image,
                        size: 40,
                        color: Colors.white70,
                      ),
                    ),
                  )
                : Container(
                    color: Colors.black,
                    child: const Icon(
                      Icons.movie,
                      size: 40,
                      color: Colors.white70,
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              textPeli,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
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
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(
                  valorCheckBox ? Icons.favorite : Icons.favorite_border,
                  color: valorCheckBox ? Colors.redAccent : Colors.white70,
                ),
                onPressed: () {
                  canviaValorCheckbox?.call(!valorCheckBox);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
