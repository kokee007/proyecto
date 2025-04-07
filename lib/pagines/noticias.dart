import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:proyecto/api/api_keys.dart';
import 'package:url_launcher/url_launcher.dart';

// Widget para texto con gradiente
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;
  const GradientText({
    Key? key,
    required this.text,
    required this.style,
    required this.gradient,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) =>
          gradient.createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(
        text,
        style: style.copyWith(color: Colors.white),
      ),
    );
  }
}

class Noticias extends StatefulWidget {
  const Noticias({Key? key}) : super(key: key);

  @override
  State<Noticias> createState() => _NoticiasState();
}

class _NoticiasState extends State<Noticias> {
  bool isLoading = true;
  List<dynamic> articles = [];

  final String apiKey = ApiKeys.newsApiKey;
  // Endpoint actualizado: se incluyen "cine europeo", "películas europeas" y "festival de cine"
  // Se ordena por fecha y se establece el idioma a español.
  final String endpoint =
      "https://newsapi.org/v2/everything?q=cine%20europeo%20OR%20pel%C3%ADculas%20europeas%20OR%20%22festival%20de%20cine%22&language=es&sortBy=publishedAt";

  @override
  void initState() {
    super.initState();
    fetchNoticias();
  }

  Future<void> fetchNoticias() async {
    try {
      // Filtramos las noticias de los últimos 2 días
      String fromDate =
          DateTime.now().subtract(const Duration(days: 2)).toIso8601String();
      final url = Uri.parse("$endpoint&from=$fromDate&apiKey=$apiKey");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        setState(() {
          articles = jsonData['articles'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al cargar las noticias: ${response.statusCode}")),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // Función para abrir el enlace en el navegador
  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  // Cabecera con título y subtítulo (dentro del ListView)
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
      child: Column(
        children: [
          GradientText(
            text: "NOTICIAS DE NUESTRO MUNDO!",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black45, blurRadius: 5, offset: Offset(2, 2))],
            ),
            gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.purpleAccent]),
          ),
          const SizedBox(height: 8),
          const Text(
            "ACTUALIAZTE!",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [Shadow(color: Colors.black45, blurRadius: 5, offset: Offset(2, 2))],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Tarjeta para cada noticia con borde degradado y diseño elegante
  Widget _buildArticleCard(dynamic article) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.blueAccent, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen destacada
            article["urlToImage"] != null
                ? ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    child: Image.network(
                      article["urlToImage"],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                    child: const Icon(Icons.image, color: Colors.white, size: 50),
                  ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article["title"] ?? "Sin título",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 3, offset: Offset(1, 1))],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article["description"] ?? "",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          if (article["url"] != null) {
                            _launchUrl(article["url"]);
                          }
                        },
                        child: const Text(
                          "Leer más",
                          style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar modificado para incluir un fondo degradado, título en gradiente y un botón de retroceso personalizado
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black, Colors.grey.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.orangeAccent,
            size: 28,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: GradientText(
          text: "Noticias del Cine Europeo",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black45, blurRadius: 5, offset: Offset(2,2))],
          ),
          gradient: const LinearGradient(colors: [Colors.orange, Colors.red]),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.grey.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: fetchNoticias,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: articles.length + 1, // +1 para incluir el header
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildHeader();
                    }
                    final article = articles[index - 1];
                    return _buildArticleCard(article);
                  },
                ),
              ),
      ),
    );
  }
}
