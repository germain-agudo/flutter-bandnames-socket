// 1.- lo de flutter, 2.- los de terceros, 3.- los nuestros
import 'package:band_name/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; //Esta libreria la ponemos desde aqui para que la pueda ocuapr desde cualquier parte

import 'package:band_name/pages/status.dart';
import 'package:band_name/pages/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SocketService(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Material App',
        initialRoute: 'home',
        routes: {
          'home': (_) => HomePage(),
          'status': (_) => StatusPage(),
        },
      ),
    );
  }
}
