import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  final Color color;
  final String buttonText;
  final Function onPressed;

  const SubmitButton({
    @required this.color,
    @required this.buttonText,
    @required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      disabledColor: Colors.grey,
      color: color,
      textColor: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: AutoSizeText(
          buttonText,
          textAlign: TextAlign.center,
          maxLines: 1,
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
          minFontSize: 14,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    );

    //    return Material(
//      color: color,
//      borderRadius: BorderRadius.all(Radius.circular(100.0)),
//      child: InkWell(
//        borderRadius: BorderRadius.all(Radius.circular(100.0)),
//        onTap: onPressed,
//        child: Padding(
//          padding: const EdgeInsets.all(14.0),
//          child: AutoSizeText(
//            buttonText,
//            textAlign: TextAlign.center,
//            maxLines: 1,
//            style: TextStyle(
//              fontSize: 14.0,
//              fontWeight: FontWeight.bold,
//            ),
//            minFontSize: 14,
//            overflow: TextOverflow.ellipsis,
//          ),
//        ),
//      ),
//    );
  }
}
