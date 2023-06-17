import 'package:flutter/material.dart';
import 'main.dart';

class UnitRadioWidget extends StatefulWidget {
  final Function(String) onUnitSelect;
  final List<String> measurementUnits;

  const UnitRadioWidget(
      {Key? key, required this.onUnitSelect, required this.measurementUnits})
      : super(key: key);

  @override
  State<UnitRadioWidget> createState() => _UnitRadioWidgetState();
}

class _UnitRadioWidgetState extends State<UnitRadioWidget> {
  String? _selectedUnit;

  @override
  void initState() {
    super.initState();
    _selectedUnit = widget.measurementUnits[0];
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: widget.measurementUnits.map((unit) {
        return Expanded(
          child: ChoiceChip(
            label: Text(unit),
            selected: _selectedUnit == unit,
            onSelected: (bool selected) {
              widget.onUnitSelect(unit);
              setState(() {
                _selectedUnit = selected ? unit : null;
              });
            },
            selectedColor: red,
            backgroundColor: red.withOpacity(0.7),
          ),
        );
      }).toList(),
    );
  }
}
