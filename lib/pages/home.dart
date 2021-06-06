import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

import 'package:band_name/models/band.dart';
import 'package:band_name/services/socket_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
/*     Band(id: '1', name: 'Metallica', votes: 5),
    Band(id: '2', name: 'Queen', votes: 1),
    Band(id: '3', name: 'Héroes del Silencio', votes: 2),
    Band(id: '4', name: 'Bob Jovi', votes: 5), */
  ];

  @override //initS
  void initState() {
    //el false esta porque no necesito redibujar algo
    final socketService = Provider.of<SocketService>(context, listen: false);

    // socketService.socket.on('active-bands', (payload) {  });
    socketService.socket.on('active-bands', _handleActiveBands);
    super.initState();
  }

  _handleActiveBands(dynamic payload) {
    //1. Mapear el payload
    this.bands = (payload
            as List) //Casteamos el payload a una lista y de ahi ya podremos utilizar el metodo map
        .map((banda) => Band.fromMap(
            banda)) //hasta aqui se crea un iterable, pero no es lista, asi que lo tenemod que volver una lista
        .toList(); // con esto ya lo pasamos a ua lista
    setState(() {});
  }

//Para la limpieza, para dejar de escuchar un evento
  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BandNames',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 10),
            child: (socketService.serverStatus == ServerStatus.Online)
                ? Icon(Icons.check_circle, color: Colors.blue[300])
                : Icon(Icons.offline_bolt, color: Colors.red),
          )
        ],
      ),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.start,
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          (bands.isEmpty)
              ? Center(
                  child: Text('Vacio'),
                )
              : _showGraph(),
          Expanded(
            //el expanded va a decor toma todo el espacio disponible en base a la columna
            child: ListView.builder(
              // shrinkWrap: true,
              itemCount: bands.length,
              itemBuilder: (context, i) => (_bandTile(bands[i])),
              // itemBuilder: (BuildContext context, int index) {
              //   return _bandTile(bands[index]);
              // },
            ),
          ),
        ],
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
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id), //identificador unico
      direction: DismissDirection.startToEnd,
      // onDismissed: (_) { socketService.emit('delete-band', {'id': band.id}); }, //Bloquear la dirección
      onDismissed: (_) => socketService
          .emit('delete-band', {'id': band.id}), //Bloquear la dirección
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
        // onTap: () { socketService.socket.emit('vote-band', {'id': band.id});  },
        onTap: () => socketService.socket.emit('vote-band', {'id': band.id}),
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
        // builder: (context) {
        builder: (_) =>
            //El bulder es quien va a construir el popup que va a aparecer
            //#  return AlertDialog(
            AlertDialog(
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
        ),
      );
    }

    showCupertinoDialog(
      context:
          context, //El contex va a saber toda la estructura del arbol de Widgets
      builder: (_) =>
          // return CupertinoAlertDialog(
          CupertinoAlertDialog(
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
      ),
    );
  }

  void addBandToList(String name) {
    if (name.length > 1) {
      final socketService = Provider.of<SocketService>(context, listen: false);

      // Podemos agregarlo
      // this.bands.add(new Band(id: DateTime.now().toString(), name: name, votes: 0));
      // setState(() {});
      socketService.emit('add-band', {'name': name});
    }

    Navigator.pop(context);
  }

//Mostrar Grafica
  Widget _showGraph() {
    Map<String, double> dataMap = new Map();
    // {
    // 'Flutter': 5,
    // 'React': 3,
    // 'Xamarin': 2,
    // 'Ionic': 2,
    // };
    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });

    final List<Color> colorList = [
      Colors.blue[50],
      Colors.blue[200],
      Colors.pink[50],
      Colors.pink[200],
      Colors.yellow[50],
      Colors.yellow[200],
    ];

    return Container(

        //para que no sepegue con la parte de arriba
        padding: EdgeInsets.only(top: 10),
        width: double.infinity,
        height: 200,
        // child: PieChart(dataMap: dataMap)
        child: PieChart(
          dataMap: dataMap,
          animationDuration: Duration(milliseconds: 800),
          // chartLegendSpacing: 32,
          // chartRadius: MediaQuery.of(context).size.width / 3.2,
          colorList: colorList,
          // initialAngleInDegree: 0,
          chartType: ChartType.ring,
          ringStrokeWidth: 32,
          // centerText: "HYBRID",
          legendOptions: LegendOptions(
            showLegendsInRow: false,
            legendPosition: LegendPosition.right,
            showLegends: true,
            // legendShape: BoxShape.circle,
            legendTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          chartValuesOptions: ChartValuesOptions(
            showChartValueBackground: false,
            showChartValues: true,
            showChartValuesInPercentage: true,
            showChartValuesOutside: false,
            decimalPlaces: 0,
          ),
        ));
  }
}
