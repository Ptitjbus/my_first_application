import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rxdart/rxdart.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:intl/intl.dart';

const Color darkGreen = Color(0xFF2E5245);
const Color white = Color(0xFFFDF3E8);
const Color red = Color.fromARGB(255, 237, 105, 88);

class Product {
  Product({required this.name, required this.checked});
  final String name;
  bool checked;
}

class ProductItem extends StatelessWidget {
  ProductItem({
    required this.product,
    required this.onProductChanged,
  }) : super(key: ObjectKey(product));

  final Product product;
  final onProductChanged;

  TextStyle? _getTextStyle(bool checked) {
    if (!checked) return null;

    return const TextStyle(
      color: Colors.black54,
      decoration: TextDecoration.lineThrough,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      onChanged: (bool? value) {
        onProductChanged(product);
      },
      value: product.checked,
      title: Text(product.name, style: _getTextStyle(product.checked)),
    );
  }
}

class ProductList extends StatefulWidget {
  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  final TextEditingController _textFieldController = TextEditingController();
  final List<Product> _products = <Product>[];
  final TextEditingController _searchController = TextEditingController();
  final BehaviorSubject<List<String>> _resultsController = BehaviorSubject();
  List<String> allFoods = [
    'Abricot',
    'Banane',
    'Carotte',
    'Datte',
    'Epinard',
    'Fraise',
    'Grenade',
    'Haricot',
    'Igname',
    'Jicama',
    'Kale',
    'Lentille',
    'Mangue',
    'Noix',
    'Oignon',
    'Poivron',
    'Quinoa',
    'Raisin',
    'Sarrasin',
    'Tomate',
    'Ugli fruit',
    'Vanille',
    'Wasabi',
    'Xigua',
    'Yam',
    'Zucchini'
  ];
  bool _connected = false;
  bool _websocketConnected = false;
  StreamSubscription<ConnectivityResult>? _subscription;
  WebSocketChannel? _channel;
  final selectedFood = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _subscription =
        Connectivity().onConnectivityChanged.listen((resultat) async {
      bool connected = resultat != ConnectivityResult.none;
      setState(() {
        _connected = connected;
      });

      if (connected) {
        await _connectWebSocket();
      } else {
        _disconnectWebSocket();
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _resultsController.close();
    _subscription?.cancel();
    _disconnectWebSocket();
    super.dispose();
  }

  void _onSearchChanged() async {
    _resultsController.add(await searchFoods(_searchController.text));
  }

  Future<List<String>> searchFoods(String query) async {
    await Future.delayed(
        const Duration(seconds: 1)); // simule une latence de réseau

    return allFoods
        .where((food) => food.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<void> _connectWebSocket() async {
    _channel = IOWebSocketChannel.connect('ws://172.20.10.10:8081');

    _channel!.ready.then((_) {
      _channel!.stream.listen((message) {
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
    if (_websocketConnected && _channel != null) {
      _channel!.sink.add(message);
    } else {
      print("WebSocket déconnecté, impossible d'envoyer le message");
    }
  }

  String _convertProductListToStringList(List<Product> list) {
    // send only checked products
    String productList = (list
            .where((e) => e.checked == true)
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

  void _handleProductChange(Product product) {
    setState(() {
      product.checked = !product.checked;
    });
  }

  void _addProductItem(String name) {
    setState(() {
      _products.add(Product(name: name, checked: false));
    });
    _textFieldController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: white,
          title: const Text('Ma liste de course',
              style: TextStyle(color: darkGreen, fontSize: 18)),
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.all(10.0),
            child: InkWell(
              onTap: () {
                if (!_websocketConnected && _connected) {
                  _connectWebSocket();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _websocketConnected ? darkGreen : Colors.grey,
                ),
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize:
                const Size.fromHeight(30.0), // Augmentez la taille préférée
            child: Container(
              padding: const EdgeInsets.only(bottom: 10.0), // Ajoutez la marge
              child: Text(
                '${_products.length} article${_products.length > 1 ? 's' : ''}',
                style: const TextStyle(
                    fontSize: 24.0, // Taille de la police
                    color: darkGreen,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          elevation: 0.0,
        ),
        body: Column(
          children: <Widget>[
            SingleChildScrollView(
              child: Column(
                children: _products.map((Product product) {
                  return ProductItem(
                    product: product,
                    onProductChanged: _handleProductChange,
                  );
                }).toList(),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(16.0),
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: () => _displayDialog(context),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const Expanded(
                        child: Text(
                          'Votre texte ici',
                          style: TextStyle(
                            color: darkGreen,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: red,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          color: const Color.fromRGBO(255, 255, 255, 1),
          child: Container(
            height: 50.0,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(1),
                  offset: const Offset(0, -40),
                  blurRadius: 20.0,
                ),
              ],
            ),
            child: Column(
              children: [
                FractionallySizedBox(
                  widthFactor: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed: () => _sendList(_products),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        textStyle: const TextStyle(fontSize: 16.0),
                      ),
                      child: const Text("Envoyer les courses"),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void _displayDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.85,
          maxChildSize: 0.9,
          builder: (BuildContext context, ScrollController scrollController) {
            return ValueListenableBuilder<String?>(
                valueListenable: selectedFood,
                builder: (context, food, child) {
                  if (food == null) {
                    return Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.0),
                          topRight: Radius.circular(16.0),
                        ),
                      ),
                      child: SafeArea(
                        child: Column(
                          children: [
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Recherche d'article",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextField(
                                controller: _searchController,
                                decoration: const InputDecoration(
                                  labelText: "Rechercher un produit",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            Flexible(
                              child: StreamBuilder<List<String>>(
                                stream: _resultsController.stream,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData &&
                                      snapshot.data != null) {
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: snapshot.data!.length,
                                      itemBuilder: (context, index) {
                                        return Card(
                                          color: white,
                                          child: ListTile(
                                            title: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  snapshot.data![index],
                                                ),
                                                const Icon(
                                                    Icons.arrow_forward_ios),
                                              ],
                                            ),
                                            onTap: () {
                                              setState(() {
                                                selectedFood.value =
                                                    snapshot.data![index];
                                              });
                                            },
                                          ),
                                        );
                                      },
                                    );
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.0),
                          topRight: Radius.circular(16.0),
                        ),
                      ),
                      child: SafeArea(
                        child: Column(
                          children: [
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  selectedFood.value!,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                });
          },
        );
      },
    ).then((_) {
      // This callback is called when the modal bottom sheet is dismissed
      selectedFood.value = null;
    });
  }
}

class ProductApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product list',
      home: ProductList(),
    );
  }
}

void main() => runApp(ProductApp());
