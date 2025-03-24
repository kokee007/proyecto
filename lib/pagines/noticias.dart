import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Noticias extends StatefulWidget {
  const Noticias({Key? key}) : super(key: key);

  @override
  State<Noticias> createState() => _NoticiasState();
}

class _NoticiasState extends State<Noticias> {
  bool isLoading = true;
  List<dynamic> articles = [];

  // Reemplaza "TU_API_KEY" con tu API Key real de NewsAPI.org
  final String apiKey = "TU_API_KEY";
  // Endpoint para noticias sobre cine europeo y películas europeas en español
  final String endpoint =
      "https://newsapi.org/v2/everything?q=cine%20europeo%20OR%20películas%20europeas&language=es";

  @override
  void initState() {
    super.initState();
    fetchNoticias();
  }

  Future<void> fetchNoticias() async {
    try {
      final url = Uri.parse("$endpoint&apiKey=$apiKey");
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
        print("Error fetching news: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Noticias del Cine Europeo"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey.shade900,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return Card(
                  color: Colors.grey.shade800,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8),
                    leading: article["urlToImage"] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              article["urlToImage"],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey,
                          ),
                    title: Text(
                      article["title"] ?? "Sin título",
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      article["description"] ?? "",
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    onTap: () {
                      // Aquí podrías abrir el enlace de la noticia o navegar a una página de detalle
                    },
                  ),
                );
              },
            ),
    );
  }
}
