import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomDropdownButton extends StatelessWidget {
  CustomDropdownButton({
    this.text,
    this.valuChoose,
    this.onChanged,
  });
  String? valuChoose;
  final String? text;
  Function(String)? onChanged;

  // String? selectedValue;
  final List<String> listItems = [
    "كنيسة مارجرجس",
    "كنيسة العدراء",
    "كنيسة مارجرجس",
    "كنيسة العدراء",
    "item 5",
    "لالال ببلبل",
  ];
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField2<String>(
      alignment: Alignment.center,
      isExpanded: true,
      decoration: InputDecoration(
        // Add Horizontal padding using menuItemStyleData.padding so it matches
        // the menu padding when button's width is not specified.
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        // Add more decoration..
      ),
      hint: Text(
        text!,
        textAlign: TextAlign.right,
        style: TextStyle(fontSize: 15),
      ),
      items: listItems
          .map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ))
          .toList(),
      validator: (value) {
        if (value == null) {
          return text;
        }
        return null;
      },
      onChanged: (value) {
        valuChoose = value;
      },
      // onSaved: (value) {
      //   selectedValue = value.toString();
      // },
      buttonStyleData: const ButtonStyleData(
        padding: EdgeInsets.only(right: 8),
      ),
      iconStyleData: const IconStyleData(
        icon: Icon(
          Icons.arrow_drop_down,
          color: Colors.black45,
        ),
        iconSize: 24,
      ),
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      menuItemStyleData: const MenuItemStyleData(
        padding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
