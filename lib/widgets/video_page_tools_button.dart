import 'package:flutter/material.dart';

class OptionButton extends StatelessWidget {
  final String imageSrc;
  final String tooltipMessage;
  final Function onPressed;

  const OptionButton({
    @required this.imageSrc,
    @required this.tooltipMessage,
    @required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        color: Color(0xFFEAEAEA),
        borderRadius: BorderRadius.all(Radius.circular(10)),
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          onTap: onPressed,
          child: Tooltip(
            child: Container(
              height: 50,
              width: 50,
              child: Image.asset(
                imageSrc,
                color: Colors.black,
                scale: 2,
              ),
            ),
            message: tooltipMessage,
          ),
        ),
      ),
    );
  }
}
