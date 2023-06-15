import 'package:flutter/material.dart';
import 'main.dart';

class KeyboardWidget extends StatefulWidget {
  final Function(String) onKeyTap;

  const KeyboardWidget({Key? key, required this.onKeyTap}) : super(key: key);

  @override
  _KeyboardWidgetState createState() => _KeyboardWidgetState();
}

class _KeyboardWidgetState extends State<KeyboardWidget> {
  List<List<String>> keys = [
    ['7', '8', '9'],
    ['4', '5', '6'],
    ['1', '2', '3'],
    ['0', '.', 'effacer']
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 2.0,
      children: keys.expand((row) => row).map((k) {
        return Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () => widget.onKeyTap(k),
              child: Container(
                  alignment: Alignment.center,
                  child: Container(
                    decoration: BoxDecoration(
                      color: white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      k,
                      style: const TextStyle(
                        color: darkGreen,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
            ));
      }).toList(),
    );
  }
}
