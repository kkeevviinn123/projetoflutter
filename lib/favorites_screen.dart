import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritePlaces = [
      'Casa: Rua das Flores, 123',
      'Trabalho: Av. Central, 456',
      'Escola: Rua da Paz, 789'
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
        // cor do AppBar agora vem do tema
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: favoritePlaces.length,
          itemBuilder: (context, index) => ListTile(
            leading: const Icon(Icons.star, color: Colors.amber),
            title: Text(favoritePlaces[index]),
          ),
        ),
      ),
    );
  }
}
