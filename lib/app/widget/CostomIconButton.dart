import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class CustomIconButton extends StatelessWidget {
  const CustomIconButton({Key? key,
    required this.icon,
    required this.size,
    this.iconColor = Colors.blue,
    required this.onPressed,
    this.bgColor = Colors.blue,
  }) : super(key: key);

  final IconData icon;
  final int size;
  final Color iconColor;
  final VoidCallback onPressed;
  final Color bgColor;


  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed:() {
        // Add touch feedback to buttons
        HapticFeedback.mediumImpact();
        onPressed();
      },
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(bgColor),
        foregroundColor: WidgetStateProperty.all(Colors.white),
        padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
        // shape: MaterialStateProperty.all(RoundedRectangleBorder(
        //     borderRadius:
        //     BorderRadius.circular(ScreenAdapter.height(5)))),
      ),

      child: Row(
        children: [
          const Spacer(),
          Icon(icon,
            color: iconColor,
            size: 50,
          ),
          const Spacer()
        ],
      ),
    );
  }


}