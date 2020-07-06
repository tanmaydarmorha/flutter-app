import 'package:flutter/material.dart';

class VideoPageMenuItem extends StatelessWidget {
  final String tooltipMessage;
  final String iconSrc;
  final Function onPressed;

  const VideoPageMenuItem(
      {@required this.iconSrc, @required this.onPressed, this.tooltipMessage});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      child: GestureDetector(
        onTap: onPressed,
        child: Image.asset(
          iconSrc,
          scale: 1.3,
          color: Colors.white,
        ),
      ),
      message: tooltipMessage,
    );
  }
}
