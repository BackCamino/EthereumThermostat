import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Function callback;
  final double borderRadius;
  final Color boxColor;
  final Color borderColor;
  final String buttonText;
  final Color textColor;
  final bool isLoading;

  CustomButton(
      {this.callback,
        this.borderColor,
        this.boxColor,
        this.buttonText,
        this.textColor,
        this.borderRadius,
        this.isLoading});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: callback,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
            border: Border.all(color: borderColor, width: 2),
            color: boxColor),
        child: isLoading
            ? SizedBox(
            height: 25,
            width: 25,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2,
            ))
            : Text(
          buttonText,
          style: TextStyle(fontSize: 20, color: textColor),
        ),
      ),
    );
  }
}