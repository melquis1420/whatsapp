import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:whatsapp/model/Mensagem.dart';
import 'package:whatsapp/model/Usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'model/Conversa.dart';

class Mensagens extends StatefulWidget {
  Usuario contato;

  Mensagens(this.contato);

  @override
  _MensagensState createState() => _MensagensState();
}

class _MensagensState extends State<Mensagens> {
  File? _imagem;
  bool _subindoImagem = false;
  String _idUsuarioLogado = "";
  String _idUsuarioDestinatario = "";
  Firestore db = Firestore.instance;
  TextEditingController _controllerMensagem = TextEditingController();
  final _controller = StreamController<QuerySnapshot>.broadcast();
  ScrollController _scrollController = ScrollController();

  _enviarMensagem() {
    String textoMensagem = _controllerMensagem.text;
    if (textoMensagem.isNotEmpty) {
      Mensagem mensagem = Mensagem();
      mensagem.idUsuario = _idUsuarioLogado;
      mensagem.mensagem = textoMensagem;
      mensagem.urlImagem = "";
      mensagem.data = Timestamp.now().toString(); //take data to message
      mensagem.tipo = "texto";

      _salvarMensagem(_idUsuarioLogado, _idUsuarioDestinatario, mensagem);

      //save message to other contact
      _salvarMensagem(_idUsuarioDestinatario, _idUsuarioLogado, mensagem);

      //save chat
      _salvarConversa(mensagem);
    }
  }

  _salvarConversa(Mensagem msg) {
    Conversa cRemetente = Conversa();
    cRemetente.idRemetente = _idUsuarioLogado;
    cRemetente.idDestinatario = _idUsuarioDestinatario;
    cRemetente.mensagem = msg.mensagem;
    cRemetente.nome = widget.contato.nome;
    cRemetente.caminhoFoto = widget.contato.urlImagem;
    cRemetente.tipoMensagem = msg.tipo;
    cRemetente.salvar();

    Conversa cDestinatario = Conversa();
    cDestinatario.idRemetente = _idUsuarioDestinatario;
    cDestinatario.idDestinatario = _idUsuarioLogado;
    cDestinatario.mensagem = msg.mensagem;
    cDestinatario.nome = widget.contato.nome;
    cDestinatario.caminhoFoto = widget.contato.urlImagem;
    cDestinatario.tipoMensagem = msg.tipo;
    cDestinatario.salvar();
  }

  _salvarMensagem(
      String idRemetente, String idDestinatario, Mensagem msg) async {
    await db
        .collection("mensagens")
        .document(idRemetente)
        .collection(idDestinatario)
        .add(msg.toMap());

    //clear text field
    _controllerMensagem.clear();
  }

  _enviarFoto() async {
    File? imagemSelecionada;
    imagemSelecionada =
        await ImagePicker.pickImage(source: ImageSource.gallery);

    _subindoImagem = true;
    String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();
    FirebaseStorage storage = FirebaseStorage.instance;
    StorageReference pastaRaiz = storage.ref();
    StorageReference arquivo = pastaRaiz
        .child("mensagens")
        .child(_idUsuarioLogado)
        .child(nomeImagem + ".jpg");

    //Image Upload
    StorageUploadTask task = arquivo.putFile(imagemSelecionada);

    //Upload controll progress

    task.events.listen((StorageTaskEvent storageEvent) {
      if (storageEvent.type == StorageTaskEventType.progress) {
        setState(() {
          _subindoImagem = true;
        });
      } else if (storageEvent.type == StorageTaskEventType.success) {
        setState(() {
          _subindoImagem = false;
        });
      }
    });

    //Image url recover
    task.onComplete.then((StorageTaskSnapshot snapshot) {
      _recuperarUrlImagem(snapshot);
    });
  }

  Future _recuperarUrlImagem(StorageTaskSnapshot snapshot) async {
    String url = await snapshot.ref.getDownloadURL();

    Mensagem mensagem = Mensagem();
    mensagem.idUsuario = _idUsuarioLogado;
    mensagem.mensagem = "";
    mensagem.urlImagem = url;
    mensagem.data = Timestamp.now().toString();
    mensagem.tipo = "imagem";

    _salvarMensagem(_idUsuarioLogado, _idUsuarioDestinatario, mensagem);

    //save message to other contact
    _salvarMensagem(_idUsuarioDestinatario, _idUsuarioLogado, mensagem);
  }

  _recuperarDadosUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUser usuarioLogado = await auth.currentUser();
    _idUsuarioLogado = usuarioLogado.uid;

    _idUsuarioDestinatario = widget.contato.idUsuario;
    _adicionarListenerMensagens();
  }

  Stream<QuerySnapshot>? _adicionarListenerMensagens() {
    final stream = db
        .collection("mensagens")
        .document(_idUsuarioLogado)
        .collection(_idUsuarioDestinatario)
        .orderBy("data", descending: false)
        .snapshots();

    stream.listen((dados) {
      _controller.add(dados);
      Timer(Duration(seconds: 1),(){
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    });
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
                  prefixIcon: _subindoImagem
                      ? CircularProgressIndicator()
                      : IconButton(
                          icon: Icon(Icons.camera_alt),
                          onPressed: _enviarFoto,
                          color: Color(0xff075E54),
                        ),
                ),
              ),
            ),
          ),
          Platform.isIOS
              ? CupertinoButton(
                  child: Text("Enviar"),
                  onPressed: _enviarMensagem,
                )
              : FloatingActionButton(
                  backgroundColor: Color(0xff075E54),
                  child: Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                  mini: true,
                  onPressed: _enviarMensagem,
                )
        ],
      ),
    );

    var stream = StreamBuilder(
      stream: _controller.stream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
            return Center(
              child: Column(
                children: [
                  Text("Carregando mensagens"),
                  CircularProgressIndicator(),
                ],
              ),
            );
            break;
          case ConnectionState.active:
          case ConnectionState.done:
            QuerySnapshot? querySnapshot = snapshot.data as QuerySnapshot?;
            if (snapshot.hasError) {
              return Text("Erro ao carregar os  dados");
            } else {
              return Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                    itemCount: querySnapshot!.documents.length,
                    itemBuilder: (context, indice) {
                      double larguraContainer =
                          MediaQuery.of(context).size.width * 0.8;
                      //messages recover
                      List<DocumentSnapshot> mensagens =
                          querySnapshot.documents.toList();
                      DocumentSnapshot item = mensagens[indice];
                      //define colors and alignms
                      Alignment alinhamento = Alignment.centerRight;
                      Color cor = Color(0xff21cb65);
                      Color corTexto = Colors.white;

                      if (_idUsuarioLogado != item["idUsuario"]) {
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16)),
                            ),
                            child: item["tipo"] == "texto"
                                ? Text(
                                    item["mensagem"],
                                    style: TextStyle(
                                        fontSize: 15, color: corTexto),
                                  )
                                : Image.network(item["urlImagem"]),
                          ),
                        ),
                      );
                    }),
              );
            }
            break;
        }
      },
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
                  stream,
                  caixaMensagem,
                ],
              ),
            ),
          )),
    );
  }
}
