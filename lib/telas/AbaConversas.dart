import 'package:flutter/material.dart';
import 'package:whatsapp/model/Conversa.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whatsapp/model/Usuario.dart';

class AbaConversas extends StatefulWidget {
  const AbaConversas({Key? key}) : super(key: key);

  @override
  _AbaConversasState createState() => _AbaConversasState();
}

class _AbaConversasState extends State<AbaConversas> {
  List<Conversa> _listaConversas = [];
  final _controller = StreamController<QuerySnapshot>.broadcast();
  Firestore db = Firestore.instance;
  String _idUsuarioLogado = "";
  late QuerySnapshot querySnapshot;

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
    Conversa conversa = Conversa();
    conversa.nome = "Ana Clara";
    conversa.mensagem = "Olá! Tudo bem?";
    conversa.caminhoFoto =
        "https://firebasestorage.googleapis.com/v0/b/whatsapp-1f66d.appspot.com/o/perfil%2Fperfil1.jpg?alt=media&token=7263b7d4-2b5c-4252-a8cc-a612b5b7ef32";

    _listaConversas.add(conversa);
  }

  Stream<QuerySnapshot>? _adicionarListenerConversas() {
    final stream = db
        .collection("conversas")
        .document(_idUsuarioLogado)
        .collection("ultima_conversa")
        .snapshots();

    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    _idUsuarioLogado = usuarioLogado.uid;

    _adicionarListenerConversas();
  }

//Close the stream
  @override
  void dispose() {
    super.dispose();
    _controller.close();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _controller.stream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: [
                  Text("Carregando conversas"),
                  CircularProgressIndicator(),
                ],
              ),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Text("Erro ao carregar os  dados");
            } else
              querySnapshot = snapshot.data!;
            if (querySnapshot.documents.length == 0) {
              return Center(
                child: Text(
                  "Você não tem nenhuma mensagem",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }
            return ListView.builder(
                itemCount: _listaConversas.length,
                itemBuilder: (context, indice) {
                  List<DocumentSnapshot> conversas =
                      querySnapshot!.documents.toList();
                  DocumentSnapshot item = conversas[indice];

                  String urlImagem = item["caminhoFoto"];
                  String tipo = item["tipoMensagem"];
                  String mensagem = item["mensagem"];
                  String nome = item["nome"];
                  String idDestinatario = item["idDestinatario"];

                  Usuario usuario = Usuario();
                  usuario.nome = nome;
                  usuario.urlImagem = urlImagem;
                  usuario.idUsuario = idDestinatario;

                  return ListTile(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        "/mensagens",
                        arguments: usuario,
                      );
                    },
                    contentPadding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    leading: CircleAvatar(
                      maxRadius: 30,
                      backgroundColor: Colors.grey,
                      backgroundImage:
                          urlImagem != null ? NetworkImage(urlImagem) : null,
                    ),
                    title: Text(
                      nome,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      tipo == "texto" ? mensagem : "imagem...",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  );
                });
        }
      },
    );
  }
}
