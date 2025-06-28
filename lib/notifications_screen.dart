// lib/notifications_screen.dart
import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      'Seu destino foi encontrado com sucesso.',
      'Nova atualização disponível.',
      'Você está próximo do seu local favorito: Trabalho.',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        // AppBar herda cor do tema
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) => ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(notifications[index]),
          ),
        ),
      ),
    );
  }
}
