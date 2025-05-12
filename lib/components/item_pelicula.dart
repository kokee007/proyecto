// lib/components/item_pelicula.dart
import 'package:flutter/material.dart';

class ItemPelicula extends StatelessWidget {
  final String textPeli;
  final String descripcio;
  final String imatge;
  final bool valorCheckBox;
  final ValueChanged<bool?>? canviaValorCheckbox;
  final Function(BuildContext)? esborraPeli;
  final bool showHeart;

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
    final theme = Theme.of(context);

    return AspectRatio(
      aspectRatio: 0.65,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.25),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: imatge.isNotEmpty
                    ? Image.network(
                        imatge,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: theme.dividerColor,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: theme.iconTheme.color,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: theme.dividerColor,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.image,
                          size: 50,
                          color: theme.iconTheme.color,
                        ),
                      ),
              ),
              Container(
                color: theme.cardColor,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        textPeli,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (showHeart)
                      IconButton(
                        icon: Icon(
                          valorCheckBox
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: valorCheckBox
                              ? theme.colorScheme.secondary
                              : theme.iconTheme.color,
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
