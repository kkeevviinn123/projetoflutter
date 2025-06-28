// lib/help_screen.dart
import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajuda'),
        // cor do AppBar agora vem do tema
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: const [
              Text(
                'Dicas de Uso do Aplicativo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('- Use o campo de busca para digitar o seu destino.'),
              Text('- O mapa mostrará sua localização atual e o ponto de destino.'),
              Text('- A aba de histórico mostra os endereços buscados recentemente.'),
              Text('- Salve seus dados no login para acesso futuro.'),
              Text('- Navegue pelas abas inferior para acessar funcionalidades.'),
            ],
          ),
        ),
      ),
    );
  }
}
