import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:band_name/models/band.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    Band(id: '1', name: 'Metallica', votes: 5),
    Band(id: '2', name: 'Queen', votes: 1),
    Band(id: '3', name: 'Héroes del Silencio', votes: 2),
    Band(id: '4', name: 'Bob Jovi', votes: 5),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BandNames',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder: (context, i) => (_bandTile(bands[i])),
        // itemBuilder: (BuildContext context, int index) {
        //   return _bandTile(bands[index]);
        // },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 1,
        onPressed: addNewBand, //() {},
        //para mandar argumentos es:  onPressed: ()=>addNewBand(argumentos) o  onPressed: (){addNewBand(argumentos);},
      ),
    );
  }

  Widget _bandTile(Band band) {
    return Dismissible(
      key: Key(band.id), //identificador unico
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        print('direction: $direction');
        print('id: ${band.id}');
        //TODO: llamar el borrado en el server
      }, //Bloquear la dirección
      background: Container(
          padding: EdgeInsets.only(left: 8.0),
          color: Colors.red,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Delete Band', style: TextStyle(color: Colors.white)),
          )), //El bakground va a recibir un Widget que va a aparecer a tras del elemento que se deslice
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0, 2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text(
          '${band.votes}',
          style: TextStyle(fontSize: 20),
        ),
        onTap: () {
          print(band.name);
        },
      ),
    );
  }

  addNewBand() {
    //    final TextEditingController textEditingController = new TextEditingController();
    final textEditingController = new TextEditingController();
    //Asegurarnos que el Platform sea de dart.io y no de html
    if (Platform.isAndroid) {
      //Android
      return showDialog(
          //Para mostrar el dialogo
          context:
              context, // el contexto en un StatefulWidget esta ya de manera global, por eso se puede mandar asi
          builder: (context) {
            //El bulder es quien va a construir el popup que va a aparecer
            return AlertDialog(
              //Nota: cuando veamos un Builder simpre se va a regresar un Widget
              title: Text('New band name'),
              content: TextField(
                controller: textEditingController,
              ), //El Contenido que va a tener
              actions: <Widget>[
                MaterialButton(
                  child: Text('Add'),
                  elevation: 5,
                  textColor: Colors.blue,
                  onPressed: () => addBandToList(textEditingController.text),
                ),
              ],
            );
          });
    }

    showCupertinoDialog(
        context:
            context, //El contex va a saber toda la estructura del arbol de Widgets
        builder: (_) {
          return CupertinoAlertDialog(
            //Configuracion del dialog
            title: Text('New Bad Name'),
            content: CupertinoTextField(
              controller: textEditingController,
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text('Add'),
                onPressed: () => addBandToList(textEditingController.text),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: Text('Dismiss'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  void addBandToList(String name) {
    print(name);
    if (name.length > 1) {
      // Podemos agregarlo
      this
          .bands
          .add(new Band(id: DateTime.now().toString(), name: name, votes: 0));
      setState(() {});
    }

    Navigator.pop(context);
  }
}
