import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:poc_liste_de_courses/syncFailed.dart';
import 'package:poc_liste_de_courses/syncSucces.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'main.dart';

class ShopEndPage extends StatefulWidget {
  final List<Product> selectedProducts;

  const ShopEndPage({super.key, required this.selectedProducts});

  @override
  _ShopEndPageState createState() => _ShopEndPageState();
}

class _ShopEndPageState extends State<ShopEndPage> {
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

  String _convertProductListToStringList(List<Product> list) {
    // send only checked products
    String productList = (list
            // .where((e) => e.checked == true)
            .map((e) => '"${e.name}"')
            .toList())
        .toString();
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd-MM-yyyy').format(now);
    String jsonString = '{"date": "$formattedDate","list":$productList}';
    return jsonString;
  }

  void _sendList(List<Product> list) {
    String stringList = _convertProductListToStringList(list);
    sendMessage(stringList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: darkGreen), // Definir la couleur de la flèche de retour
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Courses terminées',
            style: TextStyle(
                color: red, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            '${widget.selectedProducts.length} articles en attente',
            style: const TextStyle(color: red, fontSize: 18),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: green25,
                shape: BoxShape.circle,
                border: Border.all(
                  color: green25,
                  width: 20,
                ),
              ),
              child: const Icon(
                Icons.check,
                size: 100,
                color: Colors.white,
              ),
            ),
          )
        ],
      )),
      bottomNavigationBar: BottomAppBar(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          color: const Color.fromRGBO(255, 255, 255, 1),
          child: Container(
            height: 90.0,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(1),
                  offset: const Offset(0, -40),
                  blurRadius: 20.0,
                ),
              ],
            ),
            child: _connected
                ? Column(
                    children: [
                      FractionallySizedBox(
                        widthFactor: 1,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: ElevatedButton(
                            onPressed: () async {
                              if (!_loading) {
                                setState(() {
                                  _loading = true;
                                });
                                if (!_websocketConnected) {
                                  await _connectWebSocket();
                                }

                                if (_websocketConnected) {
                                  _sendList(widget.selectedProducts);
                                } else {
                                  setState(() {
                                    _loading = false;
                                  });
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _loading ? red50 : red,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 24.0),
                              textStyle: const TextStyle(fontSize: 16.0),
                            ),
                            child: _loading
                                ? const CircularProgressIndicator(
                                    color: white,
                                  )
                                : const Text("Synchronisation"),
                          ),
                        ),
                      ),
                    ],
                  )
                : const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50.0),
                    child: Text(
                      'N’oublie pas de réouvrir ton application une fois chez toi ! ',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: red, fontSize: 16.0),
                    )),
          )),
    );
  }
}
