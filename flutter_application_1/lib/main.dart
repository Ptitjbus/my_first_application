import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:rxdart/rxdart.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:intl/intl.dart';
import 'radio.dart';
import 'keyboard.dart';
import 'secondList.dart';

const Color darkGreen = Color(0xFF2E5245);
const Color darkGreen50 = Color.fromRGBO(46, 82, 69, 0.5);
const Color white = Color(0xFFFDF3E8);
const Color red = Color.fromARGB(255, 237, 105, 88);
const Color red50 = Color.fromRGBO(237, 105, 88, 0.5);
const Color green = Color.fromRGBO(80, 226, 139, 1);

class Product {
  Product({required this.name, this.quantity, this.unit, required this.units});
  final String name;
  String? quantity;
  String? unit;
  final List<String> units;
}

class ProductItem extends StatelessWidget {
  final Product product;
  final Function(Product) onIconPressed;

  ProductItem({
    required this.product,
    required this.onIconPressed,
  }) : super(key: ObjectKey(product));

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 4.0),
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment
                    .start, // to align the text at the start of your column
                children: <Widget>[
                  Text(
                    product.name,
                    style: const TextStyle(color: darkGreen, fontSize: 16.0),
                  ),
                  if (product.quantity != null &&
                      product.unit !=
                          null) // assuming quantity is a nullable property of Product
                    Text(
                      '${product.quantity} ${product.unit}', // Display the quantity of product
                      style: const TextStyle(
                          color: darkGreen50,
                          fontSize: 14.0), // Adjust the style as you need
                    ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => onIconPressed(product),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                child: const Icon(
                  Icons.edit,
                  color: darkGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  final TextEditingController _textFieldController = TextEditingController();
  final List<Product> _products = <Product>[];
  final TextEditingController _searchController = TextEditingController();
  final BehaviorSubject<Map<String, List<String>>> _resultsController =
      BehaviorSubject();
  Map<String, List<String>> allFoods = {
    'Abricot': ['g', 'mg', 'kg', 'pièce(s)'],
    'Banane': ['g', 'mg', 'kg', 'pièce(s)'],
    'Carotte': ['g', 'mg', 'kg', 'pièce(s)'],
    'Epinard': ['g', 'mg', 'kg', 'pièce(s)'],
    'Fraise': ['g', 'mg', 'kg', 'pièce(s)'],
    'Grenade': ['g', 'mg', 'kg', 'pièce(s)'],
    'Haricot': ['g', 'mg', 'kg', 'pièce(s)'],
    'Lentille': ['g', 'mg', 'kg', 'pièce(s)'],
    'Mangue': ['g', 'mg', 'kg', 'pièce(s)'],
    'Noix': ['g', 'mg', 'kg', 'pièce(s)'],
    'Oignon': ['g', 'mg', 'kg', 'pièce(s)'],
    'Poivron': ['g', 'mg', 'kg', 'pièce(s)'],
    'Raisin': ['g', 'mg', 'kg', 'pièce(s)'],
    'Tomate': ['g', 'mg', 'kg', 'pièce(s)'],
    'Vanille': ['g', 'mg', 'kg', 'pièce(s)'],
    'Lait': ['l', 'ml', 'pièce(s)'],
    'Œufs': ['g', 'mg', 'kg', 'pièce(s)'],
    'Beurre': ['g', 'mg', 'kg', 'pièce(s)'],
    'Yaourts nature': ['g', 'mg', 'kg', 'pièce(s)'],
    'Fromage': ['g', 'mg', 'kg', 'pièce(s)'],
    'Poulet': ['g', 'mg', 'kg', 'pièce(s)'],
    'Saumon': ['g', 'mg', 'kg', 'pièce(s)'],
    'Tofu': ['g', 'mg', 'kg', 'pièce(s)'],
    'Pâtes': ['g', 'mg', 'kg', 'pièce(s)'],
    'Riz': ['g', 'mg', 'kg', 'pièce(s)'],
    'Farine': ['g', 'mg', 'kg', 'pièce(s)'],
    'Sucre': ['g', 'mg', 'kg', 'pièce(s)'],
    'Huile d\'olive': ['l', 'ml', 'pièce(s)'],
    'Pain complet': ['g', 'mg', 'kg', 'pièce(s)'],
    'Céréales': ['g', 'mg', 'kg', 'pièce(s)'],
    'Pois chiches en conserve': ['g', 'mg', 'kg', 'pièce(s)'],
    'Tomates pelées en conserve': ['g', 'mg', 'kg', 'pièce(s)'],
    'Petits pois surgelés': ['g', 'mg', 'kg', 'pièce(s)'],
    'Jus d\'orange ': ['l', 'ml', 'pièce(s)'],
    'Papier toilette': ['g', 'mg', 'kg', 'pièce(s)'],
    'Dentifrice': ['l', 'ml', 'pièce(s)'],
    'Savon': ['l', 'ml', 'pièce(s)'],
    'Détergent à lessive': ['l', 'ml', 'pièce(s)'],
  };
  bool _connected = false;
  bool _websocketConnected = false;
  StreamSubscription<ConnectivityResult>? _subscription;
  WebSocketChannel? _channel;
  final selectedFood = ValueNotifier<Map<String, List<String>>?>(null);
  final enteredNumber = ValueNotifier<String>("");
  final selectedUnit = ValueNotifier<String>("");

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

  Future<Map<String, List<String>>> searchFoods(String query) async {
    await Future.delayed(
        const Duration(seconds: 1)); // simule une latence de réseau

    return allFoods.keys
        .where((food) => food.toLowerCase().contains(query.toLowerCase()))
        .fold<Map<String, List<String>>>({}, (map, key) {
      map[key] = allFoods[key]!;
      return map;
    });
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

  void _addProductItem(String name, List<String> units,
      [String? quantity, String? unit]) {
    setState(() {
      _products.add(
          Product(name: name, quantity: quantity, unit: unit, units: units));
    });
    _textFieldController.clear();
  }

  void onKeyTapped(
    String value,
  ) {
    if (value == 'effacer') {
      setState(() {
        enteredNumber.value = enteredNumber.value
            .substring(0, max(0, enteredNumber.value.length - 1));
      });
    } else {
      setState(() {
        enteredNumber.value += value;
      });
    }
  }

  void onUnitSelected(unit) {
    selectedUnit.value = unit;
  }

  void _deleteProductItem(product) {
    setState(() {
      _products.remove(product);
    });
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
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(0, 16.0, 0, 0),
                child: Column(
                  children: _products.map((Product product) {
                    return ProductItem(
                      product: product,
                      onIconPressed: (product) {
                        enteredNumber.value = product.quantity ?? '0';
                        selectedUnit.value = product.unit ?? 'g';
                        __displayEditionDialog(context, product);
                      },
                    );
                  }).toList(),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 4.0),
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
                            'Ajouter un article',
                            style: TextStyle(color: darkGreen, fontSize: 16.0),
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
        ),
        bottomNavigationBar: _products.isNotEmpty
            ? BottomAppBar(
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
                            onPressed: () => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        SecondPage(products: _products)),
                              ),
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: red,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12.0),
                              textStyle: const TextStyle(fontSize: 16.0),
                            ),
                            child: const Text("Passer aux courses"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : null);
  }

  void __displayEditionDialog(BuildContext context, Product product) {
    showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.85,
            maxChildSize: 0.9,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SafeArea(
                    child: StatefulBuilder(builder:
                        (BuildContext context, StateSetter modalSetState) {
                      return Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                IconButton(
                                    onPressed: () => {},
                                    icon: const Icon(Icons.arrow_back_ios_new)),
                                const Center(
                                  child: Text(
                                    'Edition',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                                TextButton(
                                  child: const Text(
                                    'Supprimer',
                                    style: TextStyle(fontSize: 18, color: red),
                                  ),
                                  onPressed: () => {
                                    Navigator.pop(context),
                                    _deleteProductItem(product)
                                  },
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                  fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Spacer(),
                          ValueListenableBuilder<String>(
                              valueListenable: enteredNumber,
                              builder: (context, number, child) {
                                return ValueListenableBuilder(
                                    valueListenable: selectedUnit,
                                    builder: (context, unit, child) {
                                      return Expanded(
                                        flex: 1,
                                        child: Center(
                                          child: Text(
                                            '${enteredNumber.value.length > 0 ? enteredNumber.value : 0} ${selectedUnit.value}',
                                            style: const TextStyle(
                                                fontSize: 24, color: darkGreen),
                                          ),
                                        ),
                                      );
                                    });
                              }),
                          const Divider(
                            color: darkGreen,
                            thickness: 2,
                          ),
                          SizedBox(
                              height: 260,
                              child: KeyboardWidget(
                                onKeyTap: (key) {
                                  onKeyTapped(key);
                                },
                              )),
                          UnitRadioWidget(
                            measurementUnits: product.units,
                            onUnitSelect: (unit) {
                              onUnitSelected(unit);
                            },
                          ),
                          ValueListenableBuilder<String>(
                              valueListenable: enteredNumber,
                              builder: (context, number, child) {
                                return SizedBox(
                                  width: double.infinity,
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      backgroundColor:
                                          enteredNumber.value.isNotEmpty
                                              ? red
                                              : red50,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () => {
                                      if (enteredNumber.value.isNotEmpty)
                                        {
                                          Navigator.pop(context),
                                          setState(() {
                                            product.quantity =
                                                enteredNumber.value;
                                            product.unit = selectedUnit.value;
                                          })
                                        }
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text(
                                        'Modifier',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                          const SizedBox(height: 20),
                        ],
                      );
                    }),
                  ),
                ),
              );
            },
          );
        }).then((_) {
      selectedFood.value = null;
      enteredNumber.value = "";
      selectedUnit.value = "";
    });
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
            return ValueListenableBuilder<Map<String, List<String>>?>(
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
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SafeArea(
                            child: Column(
                              children: [
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(18.0),
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
                                  child:
                                      StreamBuilder<Map<String, List<String>>>(
                                    stream: _resultsController.stream,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData &&
                                          snapshot.data != null) {
                                        return ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: snapshot.data!.length,
                                          itemBuilder: (context, index) {
                                            final entry = snapshot.data!.entries
                                                .elementAt(index);
                                            return Card(
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              color: white,
                                              child: ListTile(
                                                title: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      entry.key,
                                                    ),
                                                    const Icon(Icons
                                                        .arrow_forward_ios),
                                                  ],
                                                ),
                                                onTap: () {
                                                  setState(() {
                                                    selectedFood.value = {
                                                      entry.key: entry.value
                                                    };
                                                  });
                                                  setState(() {
                                                    selectedUnit.value =
                                                        entry.value[0];
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
                        ));
                  } else {
                    return Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.0),
                          topRight: Radius.circular(16.0),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: SafeArea(
                          child: StatefulBuilder(builder: (BuildContext context,
                              StateSetter modalSetState) {
                            return Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      IconButton(
                                          onPressed: () => {},
                                          icon: const Icon(
                                              Icons.arrow_back_ios_new)),
                                      Center(
                                        child: Text(
                                          'Article n°${_products.length + 1}',
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                      ),
                                      TextButton(
                                        child: const Text(
                                          'Passer',
                                          style: TextStyle(
                                              fontSize: 18, color: red),
                                        ),
                                        onPressed: () => {
                                          Navigator.pop(context),
                                          _addProductItem(
                                              selectedFood.value!.keys.first,
                                              selectedFood.value!.values.first)
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(40.0),
                                  child: Text(
                                    selectedFood.value!.keys.first,
                                    style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const Spacer(),
                                ValueListenableBuilder<String>(
                                    valueListenable: enteredNumber,
                                    builder: (context, number, child) {
                                      return ValueListenableBuilder(
                                          valueListenable: selectedUnit,
                                          builder: (context, unit, child) {
                                            return Expanded(
                                              flex: 1,
                                              child: Center(
                                                child: Text(
                                                  '${enteredNumber.value.length > 0 ? enteredNumber.value : 0} ${selectedUnit.value}',
                                                  style: const TextStyle(
                                                      fontSize: 24,
                                                      color: darkGreen),
                                                ),
                                              ),
                                            );
                                          });
                                    }),
                                const Divider(
                                  color: darkGreen,
                                  thickness: 2,
                                ),
                                SizedBox(
                                    height: 260,
                                    child: KeyboardWidget(
                                      onKeyTap: (key) {
                                        onKeyTapped(key);
                                      },
                                    )),
                                UnitRadioWidget(
                                  measurementUnits:
                                      selectedFood.value!.values.first,
                                  onUnitSelect: (unit) {
                                    onUnitSelected(unit);
                                  },
                                ),
                                ValueListenableBuilder<String>(
                                    valueListenable: enteredNumber,
                                    builder: (context, number, child) {
                                      return SizedBox(
                                        width: double.infinity,
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                            backgroundColor:
                                                enteredNumber.value.isNotEmpty
                                                    ? red
                                                    : red50,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          onPressed: () => {
                                            if (enteredNumber.value.isNotEmpty)
                                              {
                                                Navigator.pop(context),
                                                _addProductItem(
                                                    selectedFood
                                                        .value!.keys.first,
                                                    selectedFood
                                                        .value!.values.first,
                                                    enteredNumber.value,
                                                    selectedUnit.value)
                                              }
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Text(
                                              'Ajouter à la liste',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                const SizedBox(height: 20),
                              ],
                            );
                          }),
                        ),
                      ),
                    );
                  }
                });
          },
        );
      },
    ).then((_) {
      selectedFood.value = null;
      enteredNumber.value = "";
      selectedUnit.value = "";
    });
  }
}

class ProductApp extends StatelessWidget {
  const ProductApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Frogy Liste de courses',
      home: ProductList(),
    );
  }
}

void main() => runApp(ProductApp());
