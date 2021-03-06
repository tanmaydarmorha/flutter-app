import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluvidmobile/modals/fragments.dart';
import 'package:fluvidmobile/modals/video.dart';
import 'package:fluvidmobile/modals/video_card_tile.dart';
import 'package:fluvidmobile/screens/video_screen.dart';
import 'package:fluvidmobile/utils/networking.dart';
import 'package:fluvidmobile/utils/update_service.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';

class VideosList extends StatefulWidget {
  /// takes url as input for api call
  final String videosUrl;

  /// takes Screen enum as input for checking which screen is calling for videos
  final Screens currentScreen;

  const VideosList({
    @required this.videosUrl,
    @required this.currentScreen,
  });

  @override
  _VideosListState createState() => _VideosListState();
}

class _VideosListState extends State<VideosList> {
  /// List of videos
  List<VideoCardTile> videos;

  /// Video details of the tapped video
  Video currentVideo;

  /// progress dialog while the video details are fetched from API call
  ProgressDialog pr;

  @override
  void initState() {
    super.initState();
    if (widget.videosUrl == null) {
      videos = [];
    } else {
      fetchData();
    }
  }

  /// Function takes JSON as input and set data for the videos list
  List<VideoCardTile> getVideosList(videoData) {
    List<VideoCardTile> videos = [];
    for (var video in videoData) {
      videos.add(VideoCardTile(
        videoTitle: video['title'],
        videoId: video['videoid'],
        videoThumbnail: video['thumbnail'],
        isFavorite: (video['favourite'] == 1) ? true : false,
      ));
    }
    return videos;
  }

  /// Function does the network call and fetches data for the videos list
  fetchData() async {
    NetworkHelper networkHelper = NetworkHelper(url: widget.videosUrl);
    var response = await networkHelper.getData(token: currentUserToken);

    if (response['data'] == null) {
      videos = [];
    } else {
      switch (widget.currentScreen) {
        case Screens.MyVideos:
          videos = getVideosList(response['data']['data']);
          break;
        case Screens.Favorites:
          videos = getVideosList(response['data']['videos']['data']);
          break;
        case Screens.Shared:
          videos = getVideosList(response['data']['videos']['data']);
          break;
        case Screens.Archive:
          videos = getVideosList(response['data']['videos']['data']);
          break;
        case Screens.Folder:
          videos = getVideosList(response['data']['videos']['data']);
          break;
        default:
          videos = [];
          break;
      }
    }

    if (this.mounted) {
      setState(() {});
    }
  }

  /// Function does the network call and
  Future<Video> getVideoData({videoId}) async {
    NetworkHelper networkHelper =
        NetworkHelper(url: 'https://api.fluvid.com/api/v1/videos/$videoId');
    var response = await networkHelper.getData(token: currentUserToken);
    if (response['message'] == 'Access Denied' ||
        response['data']['data'] == null) {
      return null;
    }

    var videoData = response['data']['data']['videoInfo'];
    List<String> tags = [];
    if (videoData['tags'] != null) {
      var jsonTags = videoData['tags'];
      for (var tag in jsonTags) {
        tags.add(tag.toString());
      }
    }

    return Video(
      videoId: videoData['videoid'],
      title: videoData['title'],
      videoUrl: videoData['video_url'],
      description: videoData['description'],
      creatorName:
          '${videoData['creater']['first_name']} ${videoData['creater']['last_name']}',
      pictureUrl: videoData['creater']['profile_pic'],
      date: videoData['creater']['created'],
      privacyStatus: videoData['privacy_status'],
      passwordProtected: videoData['password_protected'],
      tags: tags,
      videoStatus: videoData['status'],
      statisticsStatus: videoData['statistics_status'],
      commentStatus: videoData['comment_status'],
      downloadStatus: videoData['download_status'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return videos == null
        ? SliverToBoxAdapter(
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFD9D9D9)),
                color: Color(0xFFFFFFFF),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            ),
          )
        : videos.isEmpty
            ? SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFD9D9D9)),
                    color: Color(0xFFFFFFFF),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          FontAwesome5Solid.video_slash,
                          size: 70,
                          color: Color(0xFFADAEAE),
                        ),
                        Text(
                          'No Video Found.',
                          style: TextStyle(
                            fontSize: 20,
                            color: Color(0xFFADAEAE),
                          ),
                        ),
                        SizedBox(height: 10),
                        AutoSizeText(
                          'Record or Stream your first video by installing Fluvid Chrome Extension',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        MaterialButton(
                          onPressed: () async {
                            const url =
                                'https://chrome.google.com/webstore/detail/fluvid-screen-video-recor/hfadalcgppcbffdnichplalnmhjbabbm';
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                          disabledColor: Colors.grey,
                          color: Color(0xFFFFD341),
                          textColor: Colors.black,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                AntDesign.chrome,
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Add To Chrome',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF000000),
                                ),
                              ),
                            ],
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Fluvid mobile application is intended for users who would like to manage their Fluvid recording and video settings on the go.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.justify,
                        )
                      ],
                    ),
                  ),
                ),
              )
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Card(
                      child: InkWell(
                        onTap: () async {
                          pr = new ProgressDialog(context,
                              isDismissible: false,
                              type: ProgressDialogType.Normal);

                          pr.style(
                              message: 'Loading',
                              textAlign: TextAlign.start,
                              borderRadius: 10.0,
                              backgroundColor: Colors.white,
                              progressWidget: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                              elevation: 10.0,
                              insetAnimCurve: Curves.easeInOut,
                              progress: 0.0,
                              maxProgress: 100.0,
                              progressTextStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.w400),
                              messageTextStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600));
                          await pr.show();

                          currentVideo = await getVideoData(
                              videoId: videos[index].videoId);

                          await pr.hide();

                          if (currentVideo == null) {
                            Scaffold.of(context).showSnackBar(SnackBar(
                                content: Text('Cannot view Video'),
                                duration: Duration(milliseconds: 1500)));
                          } else {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) => VideoScreen(
                                  currentVideo: currentVideo,
                                ),
                              ),
                            );
                          }

                          if (removeVideo) {
                            setState(() {
                              videos.removeAt(index);
                            });
                          } else {
                            setState(() {
                              fetchData();
                            });
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  Container(
                                    height: 200,
                                    child: Image.network(
                                      videos[index].videoThumbnail,
                                    ),
                                  ),
                                  Stack(
                                    alignment: Alignment.topRight,
                                    children: <Widget>[
                                      Container(
                                        height: 200,
                                        color: Color(0x66000000),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Builder(builder: (context) {
                                          return Column(
                                            children: <Widget>[
                                              CircleAvatar(
                                                radius: 15,
                                                backgroundColor:
                                                    Color(0x99000000),
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    String response = await UpdateService
                                                        .updateFavoriteVideo(
                                                            videoId:
                                                                videos[index]
                                                                    .videoId,
                                                            isFavorite: !videos[
                                                                    index]
                                                                .isFavorite); //send what needs to be updated

                                                    if (response != null) {
                                                      setState(() {
                                                        videos[index]
                                                                .isFavorite =
                                                            !videos[index]
                                                                .isFavorite;
                                                      });
                                                      print(response);
                                                      Scaffold.of(context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(videos[
                                                                      index]
                                                                  .isFavorite
                                                              ? 'Added to Favorites'
                                                              : 'Removed from Favorites'),
                                                          duration: Duration(
                                                              seconds: 1),
                                                        ),
                                                      );
                                                      if (response == 'false' &&
                                                          widget.currentScreen ==
                                                              Screens
                                                                  .Favorites) {
                                                        setState(() {
                                                          videos
                                                              .removeAt(index);
                                                        });
                                                      }
                                                    }
                                                  },
                                                  child: Icon(
                                                    videos[index].isFavorite
                                                        ? Icons.favorite
                                                        : Icons.favorite_border,
                                                    color: videos[index]
                                                            .isFavorite
                                                        ? Colors.red
                                                        : Colors.grey.shade500,
                                                    size: 22,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 4,
                                              ),
                                              CircleAvatar(
                                                radius: 15,
                                                backgroundColor:
                                                    Color(0x99000000),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Clipboard.setData(ClipboardData(
                                                        text:
                                                            'https://fluvid.com/videos/detail/${videos[index].videoId}'));
                                                    Scaffold.of(context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                            'Copied to Clipboard'),
                                                        duration: Duration(
                                                            seconds: 1),
                                                      ),
                                                    );
                                                  },
                                                  child: Image.asset(
                                                    'images/copy-icon.png',
                                                    color: Colors.grey,
                                                    scale: 3,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.play_arrow,
                                    size: 70,
                                    color: Color(0x99FFFFFF),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.0),
                              AutoSizeText(
                                videos[index].videoTitle,
                                maxLines: 2,
                                maxFontSize: 14,
                                minFontSize: 12,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Color(0xFF39447A),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: videos.length,
                ),
              );
  }
}
