import 'package:flutter/material.dart';
import 'package:whatsapp/model/Conversa.dart';


class AbaConversas extends StatefulWidget {
  const AbaConversas({Key? key}) : super(key: key);

  @override
  _AbaConversasState createState() => _AbaConversasState();
}

class _AbaConversasState extends State<AbaConversas> {
  List<Conversa> _listaConversas= [];

  @override
  void initState() {
    super.initState();
    Conversa conversa = Conversa();
    conversa.nome = "Ana Clara";
    conversa.mensagem = "Olá! Tudo bem?";
    conversa.caminhoFoto = "https://firebasestorage.googleapis.com/v0/b/whatsapp-1f66d.appspot.com/o/perfil%2Fperfil1.jpg?alt=media&token=7263b7d4-2b5c-4252-a8cc-a612b5b7ef32";

    _listaConversas.add(conversa);
  }


  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: _listaConversas.length,
        itemBuilder: (context, indice) {
          Conversa conversa = _listaConversas[indice];

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
