import 'package:flutter/material.dart';
import 'main.dart';

enum MeasurementUnit { g, mg, kg, piece }

class UnitRadioWidget extends StatefulWidget {
  final Function(MeasurementUnit) onUnitSelect;

  const UnitRadioWidget({Key? key, required this.onUnitSelect})
      : super(key: key);

  @override
  State<UnitRadioWidget> createState() => _UnitRadioWidgetState();
}

class _UnitRadioWidgetState extends State<UnitRadioWidget> {
  MeasurementUnit _selectedUnit = MeasurementUnit.g;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: MeasurementUnit.values.map((unit) {
        return Expanded(
          child: ChoiceChip(
            label: Text(unit.toString().split('.').last),
            selected: _selectedUnit == unit,
            onSelected: (bool selected) {
              widget.onUnitSelect(unit);
              setState(() {
                _selectedUnit = (selected ? unit : null)!;
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
