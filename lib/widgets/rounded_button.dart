import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class SocialMediaButton extends StatelessWidget {
  final Function onPressed;
  final CircleAvatar circleAvatar;
  final String buttonText;

  const SocialMediaButton({
    @required this.onPressed,
    this.circleAvatar,
    this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.all(Radius.circular(100.0)),
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(100.0)),
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Color(0xFF8397D2)),
              borderRadius: BorderRadius.all(Radius.circular(100.0))),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              children: <Widget>[
                circleAvatar,
                SizedBox(width: 12),
                AutoSizeText(
                  buttonText,
                  maxLines: 1,
                  style: TextStyle(fontSize: 14.0, letterSpacing: 0.2),
                  minFontSize: 14,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
