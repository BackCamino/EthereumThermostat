
import 'package:ethereumthermostat/utils/theme.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final Icon prefixIcon;
  final TextInputType keyboardType;
  final bool isPassword;
  final FocusNode focus;
  final TextEditingController controller;
  final bool validate;

  CustomTextField({this.hintText, this.prefixIcon, this.keyboardType, this.isPassword, this.controller, this.focus, this.validate});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 320,
        padding: EdgeInsets.all(10.0),
        child: TextFormField(
          autocorrect: true,
          focusNode: focus,
          obscureText: isPassword,
          keyboardType: keyboardType,
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon,
            hintStyle: TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.white70,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
              borderSide: BorderSide(color: validate ? ThermostatAppTheme.grey : Colors.red, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              borderSide: BorderSide(color: validate ? ThermostatAppTheme.nearlyBlue : Colors.red, width: 2),
            ),
          ),
        )
    );
  }
}