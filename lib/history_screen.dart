// lib/history_screen.dart
import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyHistory = [
      'Busca: Av. Paulista, São Paulo',
      'Busca: Rua Sete de Setembro, ES',
      'Busca: Av. Atlântica, RJ',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Buscas'),
        // cor do AppBar herda o tema
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: dummyHistory.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: const Icon(Icons.history),
              title: Text(dummyHistory[index]),
            );
          },
        ),
      ),
    );
  }
}

