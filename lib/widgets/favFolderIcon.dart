import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';


/// Stateless widget used to create icon of the folder which
/// is in favorites
class FavFolderIcon extends StatelessWidget {
  const FavFolderIcon({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: <Widget>[
        Icon(
          FontAwesome.folder,
          color: Color(0xFFF7C01B),
          size: 30,
        ),
        Padding(
          padding: const EdgeInsets.only(right: 1.5, bottom: 4.0),
          child: Icon(
            Icons.favorite,
            color: Colors.red,
            size: 14,
          ),
        ),
      ],
    );
  }
}
