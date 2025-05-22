// lib/pages/llistes.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto/pagines/lista_detalle_page.dart';

class Llistes extends StatelessWidget {
  const Llistes({Key? key}) : super(key: key);

  Future<String?> _getUid() async =>
      FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getUid(),
      builder: (ctx, usnap) {
        if (usnap.connectionState == ConnectionState.waiting)
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        final uid = usnap.data;
        if (uid == null)
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Text('No estás logueado',
                  style: TextStyle(color: Colors.white)),
            ),
          );

        // Recuperamos listas públicas + propias
        final query = FirebaseFirestore.instance
            .collection('listas')
            .where(
              Filter.or(
                Filter('isPublic', isEqualTo: true),
                Filter('userId', isEqualTo: uid),
              ),
            )
            .orderBy('createdAt', descending: true);

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              title: const Text('Listas'),
              backgroundColor: Colors.black87,
              bottom: const TabBar(
                indicatorColor: Colors.deepPurpleAccent,
                tabs: [
                  Tab(text: 'Privadas'),
                  Tab(text: 'Públicas'),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => const CreateListDialog(),
              ),
            ),
            body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: query.snapshots(),
              builder: (ctx, snap) {
                if (snap.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snap.error}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snap.data!.docs;
                // Filtramos en dos listas
                final privadas = docs.where((d) {
                  final data = d.data();
                  return (data['userId'] as String) == uid
                      && (data['isPublic'] as bool? ?? false) == false;
                }).toList();

                final publicas = docs.where((d) {
                  final data = d.data();
                  return (data['isPublic'] as bool? ?? false) == true;
                }).toList();

                return TabBarView(
                  children: [
                    // **Privadas**
                    privadas.isEmpty
                        ? const Center(
                            child: Text(
                              'No tienes listas privadas',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : ListView.builder(
                            itemCount: privadas.length,
                            itemBuilder: (_, i) {
                              final doc = privadas[i];
                              final data = doc.data();
                              final name = data['listName'] as String? ?? 'Sin nombre';
                              final movies = (data['movies'] as List?)
                                      ?.cast<Map<String, dynamic>>() ?? [];
                              return Card(
                                margin: const EdgeInsets.all(8),
                                child: ListTile(
                                  title: Text(name),
                                  subtitle: Text(
                                    '${movies.length} películas · Privada',
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                  trailing: const Icon(Icons.keyboard_arrow_right, color: Colors.white),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ListaDetallePage(
                                          listId:   doc.id,
                                          listName: name,
                                          movies:   movies,
                                          ownerId:  data['userId'] as String,
                                          isPublic: false,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),

                    // **Públicas**
                    publicas.isEmpty
                        ? const Center(
                            child: Text(
                              'No hay listas públicas',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : ListView.builder(
                            itemCount: publicas.length,
                            itemBuilder: (_, i) {
                              final doc = publicas[i];
                              final data = doc.data();
                              final name = data['listName'] as String? ?? 'Sin nombre';
                              final movies = (data['movies'] as List?)
                                      ?.cast<Map<String, dynamic>>() ?? [];
                              return Card(
                                margin: const EdgeInsets.all(8),
                                child: ListTile(
                                  title: Text(name),
                                  subtitle: Text(
                                    '${movies.length} películas · Pública',
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                  trailing: const Icon(Icons.keyboard_arrow_right, color: Colors.white),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ListaDetallePage(
                                          listId:   doc.id,
                                          listName: name,
                                          movies:   movies,
                                          ownerId:  data['userId'] as String,
                                          isPublic: true,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class CreateListDialog extends StatefulWidget {
  const CreateListDialog({Key? key}) : super(key: key);
  @override
  _CreateListDialogState createState() => _CreateListDialogState();
}

class _CreateListDialogState extends State<CreateListDialog> {
  final _nameCtrl = TextEditingController();
  bool _isPublic = false;

  Future<void> _create() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    try {
      await FirebaseFirestore.instance.collection('listas').add({
        'userId':    uid,
        'listName':  name,
        'movies':    <Map<String, dynamic>>[],
        'createdAt': FieldValue.serverTimestamp(),
        'isPublic':  _isPublic,
      });
    } catch (e) {
      debugPrint('Error creando lista: $e');
    }
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black87,
      title: const Text('Crear Lista', style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Nombre de la lista',
              labelStyle: TextStyle(color: Colors.white70),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white54),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Pública', style: TextStyle(color: Colors.white)),
            value: _isPublic,
            activeColor: Colors.deepOrangeAccent,
            onChanged: (val) => setState(() => _isPublic = val),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
          onPressed: _create,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepOrangeAccent,
          ),
          child: const Text('Crear', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
