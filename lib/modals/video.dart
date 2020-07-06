import 'package:flutter/cupertino.dart';

class Video {
  String title;
  String videoUrl;
  String description;
  String creatorName;
  String pictureUrl;
  String date;
  String videoId;
  int privacyStatus;
  int passwordProtected;
  List<String> tags;
  int videoStatus;
  int downloadStatus;
  int commentStatus;
  int statisticsStatus;

  Video({
    @required this.videoId,
    @required this.title,
    @required this.videoUrl,
    @required this.description,
    @required this.creatorName,
    @required this.pictureUrl,
    @required this.date,
    @required this.privacyStatus,
    @required this.passwordProtected,
    @required this.tags,
    @required this.videoStatus,
    @required this.commentStatus,
    @required this.downloadStatus,
    @required this.statisticsStatus,
  });
}
