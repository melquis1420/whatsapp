import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp/model/Mensagem.dart';
import 'package:whatsapp/model/Usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Mensagens extends StatefulWidget {
  Usuario contato;

  Mensagens(this.contato);

  @override
  _MensagensState createState() => _MensagensState();
}

class _MensagensState extends State<Mensagens> {
  String _idUsuarioLogado = "";
  String _idUsuarioDestinatario = "";
  List<String> listaMensagens = [
    "oi",
    "oioi",
    "oioioi",
    "oioioioioi",
    "oioioioioioi",
    "oioioioioioioi",
  ];
  TextEditingController _controllerMensagem = TextEditingController();

  _enviarMensagem() {
    String textoMensagem = _controllerMensagem.text;
    if (textoMensagem.isNotEmpty) {
      Mensagem mensagem = Mensagem();
      mensagem.idUsuario = _idUsuarioLogado;
      mensagem.mensagem = textoMensagem;
      mensagem.urlImagem = "";
      mensagem.tipo = "texto";

      _salvarMensagem(_idUsuarioLogado, _idUsuarioDestinatario, mensagem);
    }
  }

  _salvarMensagem(
      String idRemetente, String idDestinatario, Mensagem msg) async {
    Firestore db = Firestore.instance;
    await db
        .collection("mensagens")
        .document(idRemetente)
        .collection(idDestinatario)
        .add(msg.toMap());

    //clear text field
    _controllerMensagem.clear();
  }

  _enviarFoto() {}

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    _idUsuarioLogado = usuarioLogado.uid;

    _idUsuarioDestinatario = widget.contato.idUsuario;
  }

  @override
  void initState() {
    super.initState();
    _recuperarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    var caixaMensagem = Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 8),
              child: TextField(
                controller: _controllerMensagem,
                //name controller
                autofocus: true,
                //set autofocus in name field
                keyboardType: TextInputType.text,
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(32, 8, 32, 8),
                  hintText: "Mensagem",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                  prefixIcon: IconButton(
                    icon: Icon(Icons.camera_alt),
                    onPressed: _enviarFoto,
                    color: Color(0xff075E54),
                  ),
                ),
              ),
            ),
          ),
          FloatingActionButton(
            backgroundColor: Color(0xff075E54),
            child: Icon(
              Icons.send,
              color: Colors.white,
            ),
            mini: true,
            onPressed: _enviarMensagem,
          ),
        ],
      ),
    );

    var listView = Expanded(
      child: ListView.builder(
          itemCount: listaMensagens.length,
          itemBuilder: (context, indice) {
            double larguraContainer = MediaQuery.of(context).size.width * 0.8;
            //define colors and alignms
            Alignment alinhamento = Alignment.centerRight;
            Color cor = Color(0xff21cb65);
            Color corTexto = Colors.white;

            if (indice % 2 == 0) {
              cor = Color(0xff095a05);
              alinhamento = Alignment.centerLeft;
            }

            return Align(
              alignment: alinhamento,
              child: Padding(
                padding: EdgeInsets.all(6),
                child: Container(
                  width: larguraContainer,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cor,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  child: Text(
                    listaMensagens[indice],
                    style: TextStyle(
                      fontSize: 15,
                      color: corTexto,
                    ),
                  ),
                ),
              ),
            );
          }),
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
                maxRadius: 20,
                backgroundColor: Colors.grey,
                backgroundImage: widget.contato.urlImagem != null
                    ? NetworkImage(widget.contato.urlImagem)
                    : null),
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text(widget.contato.nome),
            ),
          ],
        ),
        backgroundColor: Color(0xff075E54),
      ),
      body: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("images/bg.png"), fit: BoxFit.cover),
          ),
          child: SafeArea(
            child: Container(
              padding: EdgeInsets.all(8),
              child: Column(
                children: [
                  listView,
                  caixaMensagem,
                ],
              ),
            ),
          )),
    );
  }
}
