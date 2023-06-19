import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:poc_liste_de_courses/syncFailed.dart';
import 'package:web_socket_channel/io.dart';
import 'main.dart';
import 'shopEnd.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class SyncSuccessPage extends StatefulWidget {
  const SyncSuccessPage({super.key});

  @override
  _SyncSuccessPageState createState() => _SyncSuccessPageState();
}

class _SyncSuccessPageState extends State<SyncSuccessPage> {
  bool _connected = false;
  bool _websocketConnected = false;
  StreamSubscription<ConnectivityResult>? _subscription;
  WebSocketChannel? _channel;
  bool _syncError = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _subscription =
        Connectivity().onConnectivityChanged.listen((resultat) async {
      bool connected = resultat != ConnectivityResult.none;
      setState(() {
        _connected = connected;
      });

      if (_connected) {
        _connectWebSocket();
      } else {
        _disconnectWebSocket();
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkConnectivity();

    if (_connected) {
      _connectWebSocket();
    } else {
      _disconnectWebSocket();
    }
  }

  Future<void> _checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    bool connected = connectivityResult != ConnectivityResult.none;
    setState(() {
      _connected = connected;
    });
  }

  Future<void> _connectWebSocket() async {
    _channel = IOWebSocketChannel.connect(serverAdress);

    _channel!.ready.then((_) {
      _channel!.stream.listen((message) {
        if (message == 'syncFailed') {
          setState(() {
            _loading = false;
          });
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SyncFailedPage()),
          );
        }

        if (message == 'syncSucceed') {
          setState(() {
            _loading = false;
          });
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SyncSuccessPage()),
          );
        }

        print(message);
        // messages reçus
      }, onDone: () {
        setState(() {
          _websocketConnected = false;
        });
      }, onError: (error) {
        // Une erreur s'est produite.
        print("Erreur lors de la connexion WebSocket: $error");
        setState(() {
          _websocketConnected = false;
        });
      });

      setState(() {
        _websocketConnected = true;
      });
    }).onError((error, stackTrace) {
      print("WebsocketChannel was unable to establishconnection");
    });
  }

  void _disconnectWebSocket() {
    _channel?.sink.close();
    setState(() {
      _websocketConnected = false;
    });
  }

  void sendMessage(String message) {
    print(message);
    if (_websocketConnected && _channel != null) {
      _channel!.sink.add(message);
    } else {
      print("WebSocket déconnecté, impossible d'envoyer le message");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkGreen,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: darkGreen), // Definir la couleur de la flèche de retour
          onPressed: () async {
            // envois item alerte
            if (!_websocketConnected) {
              await _connectWebSocket();
            }

            if (_websocketConnected) {
              sendMessage('testAlert');
            } else {
              setState(() {
                _loading = false;
              });
            }
          },
        ),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Félicitations !',
            style: TextStyle(
                color: green, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Vos courses ont bien été synchronisées !',
            style: TextStyle(color: green, fontSize: 18),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: green,
                shape: BoxShape.circle,
                border: Border.all(
                  color: greenSuccess,
                  width: 20,
                ),
              ),
              child: const Icon(
                Icons.check,
                size: 100,
                color: white,
              ),
            ),
          )
        ],
      )),
      bottomNavigationBar: Stack(children: [
        CustomPaint(
          size: Size(MediaQuery.of(context).size.width, 180),
          painter: BNBCustomPainter(green),
        ),
        Padding(
          padding: EdgeInsets.only(top: 80),
          child: SizedBox(
            height: 90.0,
            child: Column(
              children: [
                FractionallySizedBox(
                  widthFactor: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ProductList()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkGreen,
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        textStyle: const TextStyle(fontSize: 16.0),
                      ),
                      child: const Text("Revenir à l’écran principal"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ]),
    );
  }
}

class BNBCustomPainter extends CustomPainter {
  final Color backgroundColor;

  BNBCustomPainter(this.backgroundColor);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    Path path = Path()
      ..moveTo(0, 20) // Start the path slightly higher
      ..quadraticBezierTo(size.width / 2, 80, size.width,
          20) // Increase the height of the U shape
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
