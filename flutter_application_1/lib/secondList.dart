import 'dart:math';
import 'package:flutter/material.dart';
import 'package:poc_liste_de_courses/shopEnd.dart';
import 'keyboard.dart';
import 'main.dart';
import 'radio.dart';

class SecondPage extends StatefulWidget {
  final List<Product> products;

  const SecondPage({super.key, required this.products});

  @override
  _SecondPageState createState() => _SecondPageState();
}

class ProductShoppingItem extends StatefulWidget {
  final Product product;
  final Function(Product) onIconPressed;
  final Function(Product) onCheckedAdd;
  final Function(Product) onCheckedRemove;

  ProductShoppingItem({
    required this.product,
    required this.onIconPressed,
    required this.onCheckedAdd,
    required this.onCheckedRemove,
  }) : super(key: ObjectKey(product));

  @override
  _ProductShoppingItemState createState() => _ProductShoppingItemState();
}

class _ProductShoppingItemState extends State<ProductShoppingItem> {
  bool _isChecked =
      false; // This variable will control if the product is checked

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
            Transform.scale(
              scale: 1.5,
              child: Checkbox(
                checkColor: white,
                activeColor: red,
                value: _isChecked,
                shape: const CircleBorder(),
                onChanged: (bool? value) {
                  setState(() {
                    _isChecked = value!;
                  });

                  if (value!) {
                    print("cochée");
                    setState(() {
                      widget.onCheckedAdd(widget.product);
                    });
                  } else {
                    widget.onCheckedRemove(widget.product);
                  }
                },
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.product.name,
                    style: TextStyle(
                      color: _isChecked
                          ? darkGreen50
                          : darkGreen, // Change color if the product is checked
                      fontSize: 16.0,
                      decoration: _isChecked
                          ? TextDecoration.lineThrough
                          : null, // Strike through text if the product is checked
                    ),
                  ),
                  if (widget.product.quantity != null &&
                      widget.product.unit != null)
                    Text(
                      '${widget.product.quantity} ${widget.product.unit}',
                      style:
                          const TextStyle(color: darkGreen50, fontSize: 14.0),
                    ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => widget.onIconPressed(widget.product),
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

class _SecondPageState extends State<SecondPage> {
  final List<Product> selectedProducts = <Product>[];
  final enteredNumber = ValueNotifier<String>("");
  final selectedUnit = ValueNotifier<String>("");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: darkGreen,
          title: const Text('Ma liste de course',
              style: TextStyle(color: white, fontSize: 18)),
          centerTitle: true,
          bottom: PreferredSize(
              preferredSize:
                  const Size.fromHeight(30.0), // Augmentez la taille préférée
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                        bottom: 10.0, left: 16.0), // Ajoutez la marge
                    child: RichText(
                      textAlign: TextAlign.left,
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text:
                                '${selectedProducts.length} article${selectedProducts.length > 1 ? 's' : ''} ',
                            style: const TextStyle(
                                fontSize: 28.0, // Taille de la police
                                color: white,
                                fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: 'sur ${widget.products.length}',
                            style: const TextStyle(
                                fontSize: 20.0, // Taille de la police
                                color: white,
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                    ),
                  ),
                  LinearProgressIndicator(
                    value: selectedProducts.length / widget.products.length,
                    color: green,
                    backgroundColor: white,
                    minHeight: 8,
                  ),
                ],
              )),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(0, 16.0, 0, 0),
          child: Column(
            children: widget.products.map((Product product) {
              return ProductShoppingItem(
                product: product,
                onCheckedAdd: (product) {
                  setState(() {
                    selectedProducts.add(product);
                  });
                },
                onCheckedRemove: (product) {
                  setState(() {
                    selectedProducts.remove(product);
                  });
                },
                onIconPressed: (product) {
                  enteredNumber.value = product.quantity ?? '0';
                  selectedUnit.value = product.unit ?? 'g';
                  __displayEditionDialog(context, product);
                },
              );
            }).toList(),
          ),
        ),
        bottomNavigationBar: widget.products.isNotEmpty
            ? BottomAppBar(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                color: const Color.fromRGBO(255, 255, 255, 1),
                child: Container(
                  height: 70.0,
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
                                    builder: (context) => ShopEndPage(
                                        selectedProducts: selectedProducts)),
                              ),
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: red,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 24.0),
                              textStyle: const TextStyle(fontSize: 16.0),
                            ),
                            child: const Text("Terminer les courses"),
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
      setState(() {
        enteredNumber.value = "";
        selectedUnit.value = "";
      });
    });
  }

  void _deleteProductItem(product) {
    setState(() {
      widget.products.remove(product);
    });
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
    setState(() {
      selectedUnit.value = unit;
    });
  }
}
