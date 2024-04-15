import 'package:flutter/material.dart';
import 'package:foodorder/app/modules/menuPage/views/components/GridItemView.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';

class CatagoryButton extends StatelessWidget {
  final ImageProvider icon;
  final String title;
  final Function? onTap;

  CatagoryButton(
      {Key? key, required this.icon, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          onTap: () => onTap?.call(),
          child:  Container(
                  padding: EdgeInsets.only(
                    // top: ScreenAdapter.height(20),
                    bottom: ScreenAdapter.height(20),
                    // left: ScreenAdapter.width(20),
                    // right: ScreenAdapter.width(20),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(),
                      ),
                      Expanded(
                        flex: 3,
                        child: 
                        Row(
                          children: [
                            Expanded(child: Container(),flex: 2,),
                            Expanded(child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                RectangleImageView(image: icon, radius: 0),
                                Text(
                                  title,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 34,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),flex: 3,),
                            
                            Expanded(child: Container(),flex: 2,),
                          ],
                        ),
                        
                      )
                    ],
                  )
                )
    );
  }
}
