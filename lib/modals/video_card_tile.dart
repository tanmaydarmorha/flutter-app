import 'package:flutter/material.dart';

class VideoCardTile {
  String videoId;
  String videoTitle;
  String videoThumbnail;
  bool isFavorite;

  VideoCardTile({
    @required this.videoId,
    @required this.videoTitle,
    @required this.videoThumbnail,
    @required this.isFavorite,
  });
}
