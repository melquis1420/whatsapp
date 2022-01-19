import 'package:flutter/material.dart';
import 'package:whatsapp/model/conversa.dart';

class AbaConversas extends StatefulWidget {
  const AbaConversas({Key? key}) : super(key: key);

  @override
  _AbaConversasState createState() => _AbaConversasState();
}

class _AbaConversasState extends State<AbaConversas> {
  List<Conversa> listaConversas = [
    Conversa("Lara", "Olá, tudo bem?",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-1f66d.appspot.com/o/perfil%2Fperfil1.jpg?alt=media&token=7263b7d4-2b5c-4252-a8cc-a612b5b7ef32"),
    Conversa("Pedro Silva", "Me manda o nome daquela série que falamos!",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-1f66d.appspot.com/o/perfil%2Fperfil2.jpg?alt=media&token=21973bb2-1204-4a27-a431-7f72c4a98d06"),
    Conversa("Bia", "Não esquece do trabalho de amanhã",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-1f66d.appspot.com/o/perfil%2Fperfil3.jpg?alt=media&token=5d040d3e-45f3-4dd7-a0a7-567c91256590"),
    Conversa("Eduardo", "Falou com ela?",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-1f66d.appspot.com/o/perfil%2Fperfil4.jpg?alt=media&token=2e4d5104-0f03-42d9-9894-0d303d722c33"),
    Conversa("Lucas", "Opa. Blz",
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-1f66d.appspot.com/o/perfil%2Fperfil5.jpg?alt=media&token=2b09fcf1-5f41-4573-9023-3f2bbb39f1f8"),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: listaConversas.length,
        itemBuilder: (context, indice) {
          Conversa conversa = listaConversas[indice];

          return ListTile(
            contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            leading: CircleAvatar(
              maxRadius: 30,
              backgroundColor: Colors.grey,
              backgroundImage: NetworkImage(conversa.caminhoFoto),
            ),
            title: Text(
              conversa.nome,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              conversa.mensagem,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          );
        });
  }
}
