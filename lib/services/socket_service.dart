//Esta clase me va a permitir la comunicaion con mi backend

import 'package:flutter/material.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus {
  Online,
  Offline,
  Connecting,
}

class SocketService with ChangeNotifier {
  //ChangeNotifier nos ayuda a decir a provider cundo va a rerescar la inerfaz de usuario

  ServerStatus _serverStatus = ServerStatus.Connecting;
  IO.Socket _socket;

  ServerStatus get serverStatus => this._serverStatus;
  IO.Socket get socket => this._socket;
  Function get emit => this._socket.emit;

  SocketService() {
    this._initConfig();
  }

  void _initConfig() {
    // Dart client
    // IO.Socket socket = IO.io('http://192.168.1.67:3000/', {
    this._socket = IO.io('http://192.168.1.67:3000/', {
      'transports': ['websocket'],
      'autoConnect': true
    });

    this._socket.onConnect((_) {
      // print('connect');
      this._serverStatus = ServerStatus.Online;
      notifyListeners();
      // socket.emit('msg', 'test');
    });

    // socket.on('event', (data) => print(data));
    this._socket.onDisconnect((_) {
      this._serverStatus = ServerStatus.Offline;
      notifyListeners();
    });

    // socket.on('fromServer', (_) => print(_));

    // socket.on('nuevo-mensaje', (payload) {
    //   // print('nuevo-mensaje: $payload');
    //   print('nuevo-mensaje:');
    //   print('nombre:' +
    //       payload['nombre']); //ya que es un mapa existe la propiedad nombre
    //   print('mensaje:' + payload['mensaje']);
    //   print(payload.containsKey('mensaje2')
    //       ? payload['mensaje2']
    //       : 'no hay'); //el containsKey es para saber si existe esa propiedad
    // });
  }
}
