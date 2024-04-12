//

import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:foodorder/app/config/font.dart';
import 'package:foodorder/app/modules/menuPage/views/components/GridItemView.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';
import 'package:get/get.dart';

class CarItemView extends StatefulWidget {
  final String title;
  final String subtitle;
  final String price;
  final ImageProvider image;
  final double imageRadius;
  final Function(int) onReduce;
  final Function(int) onIncrease;
  final int quantity;

  CarItemView({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.onReduce,
    required this.onIncrease,
    this.imageRadius = 10.0,
    required this.price,
    required this.quantity,
  });

  @override
  _CarItemViewState createState() => _CarItemViewState();
}

class _CarItemViewState extends State<CarItemView> {
  var _quantity = 0;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    _quantity = widget.quantity;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenAdapter.height(200),
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          RectangleImageView(image: widget.image, radius: widget.imageRadius),
          SizedBox(width: ScreenAdapter.width(20)),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //title
              Text(
                widget.title,
                maxLines: 2,
                style: TextStyle(
                  fontFamily: GFont.getFontFamily(),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              //subtitle
              Text(
                widget.subtitle,
                maxLines: 2,
                style: TextStyle(
                  fontFamily: GFont.getFontFamily(),
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              //price
              Text(
                widget.price,
                style: TextStyle(
                  fontFamily: GFont.getFontFamily(),
                  fontSize: 20,
                  color: Color.fromARGB(255, 70, 69, 69),
                ),
              ),
            ],
          ),
          Spacer(),
          SizedBox(width: ScreenAdapter.width(20)),
          Container(
              alignment: Alignment.bottomCenter,
              //margin: EdgeInsets.only(right: 50),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        if (_quantity > 0) {
                          _quantity--;
                        }
                      });
                      widget.onReduce(1);
                    },
                  ),
                  Text(
                    "$_quantity",
                    style: TextStyle(
                      fontFamily: GFont.getFontFamily(),
                      fontSize: 20,
                      color: Color.fromARGB(255, 70, 69, 69),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        _quantity++;
                      });
                      widget.onIncrease(1);
                    },
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
