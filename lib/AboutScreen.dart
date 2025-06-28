import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre o App'),
        // A cor do AppBar agora vem do seu tema
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'App Detran - Projeto Flutter',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Este aplicativo foi criado como um exemplo de interface com funcionalidades de login, consulta de mapas com OpenStreetMap e páginas adicionais para navegação.\n\nDesenvolvido com Flutter e Dart.\n\nObjetivo: aprendizado e prototipagem.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
