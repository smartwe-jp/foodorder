import 'package:flutter/material.dart';
import 'package:foodorder/config/colorsUtil.dart';

// KeyPad widget
// This widget is reusable and its buttons are customizable (color, size)
class NumPad extends StatelessWidget {
  final double buttonSize;
  final Color buttonColor;
  final Color iconColor;
  final TextEditingController controller;
  final Function delete;
  final Function onSubmit;
  final int textLength;

  const NumPad({
    Key key,
    this.buttonSize = 50,
    this.buttonColor = Colors.lime,
    this.iconColor = Colors.pink,
    this.delete,
    this.onSubmit,
    this.controller,
    this.textLength = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 30, right: 30),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            // implement the number keys (from 0 to 9) with the NumberButton widget
            // the NumberButton widget is defined in the bottom of this file
            children: [
              NumberButton(
                number: 1,
                size: buttonSize,
                color: buttonColor,
                controller: controller,
                textLength:textLength,
              ),
              NumberButton(
                number: 2,
                size: buttonSize,
                color: buttonColor,
                controller: controller,
                textLength:textLength,
              ),
              NumberButton(
                number: 3,
                size: buttonSize,
                color: buttonColor,
                controller: controller,
                textLength:textLength,
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              NumberButton(
                number: 4,
                size: buttonSize,
                color: buttonColor,
                controller: controller,
                textLength:textLength,
              ),
              NumberButton(
                number: 5,
                size: buttonSize,
                color: buttonColor,
                controller: controller,
                textLength:textLength,
              ),
              NumberButton(
                number: 6,
                size: buttonSize,
                color: buttonColor,
                controller: controller,
                textLength:textLength,
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              NumberButton(
                number: 7,
                size: buttonSize,
                color: buttonColor,
                controller: controller,
                textLength:textLength,
              ),
              NumberButton(
                number: 8,
                size: buttonSize,
                color: buttonColor,
                controller: controller,
                textLength:textLength,
              ),
              NumberButton(
                number: 9,
                size: buttonSize,
                color: buttonColor,
                controller: controller,
                textLength:textLength,
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // this button is used to delete the last number
              IconButton(
                onPressed: () => delete(),
                icon: Icon(
                  Icons.backspace,
                  color: iconColor,
                ),
                iconSize: buttonSize,
              ),
              NumberButton(
                number: 0,
                size: buttonSize,
                color: buttonColor,
                controller: controller,
                textLength:textLength,
              ),
              // this button is used to submit the entered value
              IconButton(
                onPressed: () => onSubmit(),
                icon: Icon(
                  Icons.done_rounded,
                  color: iconColor,
                ),
                iconSize: buttonSize,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// define NumberButton widget
// its shape is round
class NumberButton extends StatelessWidget {
  final int number;
  final double size;
  final Color color;
  final TextEditingController controller;
  final int textLength;

  const NumberButton({
    Key key,
    this.number,
    this.size,
    this.color,
    this.controller,
    this.textLength,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: color,
          shape: RoundedRectangleBorder(
            //borderRadius: BorderRadius.circular(size / 2),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        onPressed: () {
          if(textLength >0){
            if(controller.text.length >=textLength){
              return;
            }
          }
          controller.text += number.toString();
        },
        child: Center(
          child: Text(
            number.toString(),
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black, fontSize: 30),
          ),
        ),
      ),
    );
  }
}