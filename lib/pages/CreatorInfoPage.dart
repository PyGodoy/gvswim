import 'package:flutter/material.dart';

class CreatorInfoPage extends StatelessWidget {
  const CreatorInfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Informações do Criador'),
        backgroundColor: Colors.blue, // Cor de fundo da app bar
      ),
      backgroundColor: Colors.white, // Cor de fundo da tela
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'App desenvolvido por:',
              style: TextStyle(fontSize: 20, color: Colors.black), // Cor do texto
            ),
            SizedBox(height: 10),
            Text(
              'Mikaell de Godoy Vitorio',
              style: TextStyle(fontSize: 18, color: Colors.black), // Cor do texto
            ),
            SizedBox(height: 10),
            Text(
              'Contato: godoyvitorio99@gmail.com',
              style: TextStyle(fontSize: 16, color: Colors.black), // Cor do texto
            ),
          ],
        ),
      ),
    );
  }
}
