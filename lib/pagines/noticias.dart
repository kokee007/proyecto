// lib/pagines/noticias.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:proyecto/api/api_keys.dart';
import 'package:url_launcher/url_launcher.dart';

class Noticias extends StatefulWidget {
  const Noticias({Key? key}) : super(key: key);

  @override
  State<Noticias> createState() => _NoticiasState();
}

class _NoticiasState extends State<Noticias> {
  bool isLoading = true;
  List<dynamic> articles = [];
  final String apiKey = ApiKeys.newsApiKey;
  final String endpoint =
      "https://newsapi.org/v2/everything?q=cine%20europeo%20OR%20pel%C3%ADculas%20europeas%20OR%22festival%20de%20cine%22&language=es&sortBy=publishedAt";

  @override
  void initState() {
    super.initState();
    fetchNoticias();
  }

  Future<void> fetchNoticias() async {
    setState(() => isLoading = true);
    try {
      final from = DateTime.now()
          .subtract(const Duration(days: 2))
          .toIso8601String();
      final url = Uri.parse("$endpoint&from=$from&apiKey=$apiKey");
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        final raw = data['articles'] as List<dynamic>;

        // Filtramos para que sólo queden los artículos con imagen válida
        final soloConImagen = raw.where((item) {
          final img = item['urlToImage'] as String?;
          return img != null && img.isNotEmpty;
        }).toList();

        setState(() {
          articles = soloConImagen;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text("Error al cargar noticias: ${res.statusCode}"),
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri,
        mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No pude abrir $url")),
      );
    }
  }

  Widget _header(ThemeData theme) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      child: Column(
        children: [
          Text(
            "NOTICIAS DE NUESTRO MUNDO!",
            style: theme.textTheme.headlineSmall!
                .copyWith(color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 8),
          Text(
            "¡ACTUALÍZATE!",
            style: theme.textTheme.titleMedium!
                .copyWith(color: theme.colorScheme.secondary),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _card(dynamic art, ThemeData theme) {
    final imgUrl = art["urlToImage"] as String?;
    final title = art["title"] as String? ?? "Sin título";
    final desc = art["description"] as String? ?? "";

    return Container(
      margin:
          const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Como ya filtramos, siempre habrá imagen válida.
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(
              imgUrl!,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (ctx, error, stack) {
                return Container(
                  height: 200,
                  color: theme.dividerColor,
                  alignment: Alignment.center,
                  child: Icon(Icons.broken_image,
                      size: 48, color: theme.hintColor),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall!
                      .copyWith(color: theme.hintColor),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () =>
                        art["url"] != null
                            ? _launchUrl(art["url"])
                            : null,
                    child: Text(
                      "Leer más",
                      style: theme.textTheme.bodyMedium!
                          .copyWith(
                              color:
                                  theme.colorScheme.secondary,
                              fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: theme.colorScheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Noticias del Cine Europeo",
            style: theme.textTheme.titleLarge),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                  color: theme.colorScheme.secondary),
            )
          : RefreshIndicator(
              color: theme.colorScheme.secondary,
              onRefresh: fetchNoticias,
              child: ListView.builder(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                itemCount: articles.length + 1,
                itemBuilder: (ctx, i) {
                  if (i == 0) return _header(theme);
                  return _card(articles[i - 1], theme);
                },
              ),
            ),
    );
  }
}
