import 'dart:convert';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chewie/chewie.dart';
import 'package:dio/dio.dart';
import 'package:ext_storage/ext_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluvidmobile/modals/comment.dart';
import 'package:fluvidmobile/modals/video.dart';
import 'package:fluvidmobile/screens/viewer_list_bottom_sheet.dart';
import 'package:fluvidmobile/utils/networking.dart';
import 'package:fluvidmobile/utils/update_service.dart';
import 'package:fluvidmobile/utils/validation_service.dart';
import 'package:fluvidmobile/widgets/tools_dialog_box.dart';
import 'package:fluvidmobile/widgets/video_page_menu_item.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:share/share.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/cupertino.dart';

import '../constants.dart';

class VideoScreen extends StatefulWidget {
  final Video currentVideo;

  const VideoScreen({this.currentVideo});

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

enum VideoPageMenuOptions {
  copy,
  archive,
  share,
}

class _VideoScreenState extends State<VideoScreen> {
  List<Comment> comments;
  List<String> viewerList;
  VideoPlayerController _videoPlayerController;
  ChewieController _chewieController;
  ProgressDialog pr;
  String snackBarMessage;

  final _commentController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _videoPlayerController =
        VideoPlayerController.network(widget.currentVideo.videoUrl);
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: 16 / 9,
      allowedScreenSleep: false,
      autoInitialize: true,
      autoPlay: true,
      looping: false,
    );

    removeVideo = false;

    widget.currentVideo.date = formatDate(widget.currentVideo.date);

    _commentController.addListener(() {
      setState(() {});
    });

    _titleController.addListener(() {
      setState(() {});
    });

    _tagController.addListener(() {
      setState(() {});
    });

    fetchVideoData();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _commentController.dispose();
    _titleController.dispose();
    _chewieController.dispose();
    _tagController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  formatDate(date) {
    print(date);
    var formattedDate = DateTime.parse(date);
    String month;
    switch (formattedDate.month) {
      case 1:
        month = 'Jan';
        break;
      case 2:
        month = 'Feb';
        break;
      case 3:
        month = 'Mar';
        break;
      case 4:
        month = 'Apr';
        break;
      case 5:
        month = 'May';
        break;
      case 6:
        month = 'Jun';
        break;
      case 7:
        month = 'Jul';
        break;
      case 8:
        month = 'Aug';
        break;
      case 9:
        month = 'Sep';
        break;
      case 10:
        month = 'Oct';
        break;
      case 11:
        month = 'Nov';
        break;
      case 12:
        month = 'Dec';
        break;
      default:
        month = null;
        break;
    }
    return '$month ${formattedDate.day}, ${formattedDate.year}';
  }

  Future<List<Comment>> fetchComments() async {
    NetworkHelper getComments = NetworkHelper(
        url:
            'https://api.fluvid.com/api/v1/videoInfo/comments/${widget.currentVideo.videoId}?limit=50&page=1');
    var response = await getComments.getData(token: currentUserToken);
    if (response['data'] != null) {
      var commentsList = response['data']['comments']['data'];
      List<Comment> comments = [];
      for (var comment in commentsList) {
        comments.add(Comment(
          name:
              '${comment['userProfile']['first_name']} ${comment['userProfile']['last_name']}',
          pictureUrl: comment['userProfile']['profile_pic'],
          message: comment['message'],
        ));
      }
      return comments;
    }
    return [];
  }

  Future<List<String>> fetchViewerList() async {
    NetworkHelper getViewerList = NetworkHelper(
        url:
            'https://api.fluvid.com/api/v1/videos/access/${widget.currentVideo.videoId}');
    var response = await getViewerList.getData(token: currentUserToken);
    if (response['data'] != null) {
      var usersList = response['data']['limitedAccessUsers'];
      List<String> peopleWithAccess = [];
      for (var user in usersList) {
        peopleWithAccess.add(user['email']);
      }
      return peopleWithAccess;
    }
    return null;
  }

  fetchVideoData() async {
    viewerList = await fetchViewerList();

    // get video comments and tags
    comments = await fetchComments();
    if (this.mounted) {
      setState(() {});
    }
  }

  Future<bool> downloadFile({videoDownloadUrl}) async {
    if (await Permission.storage.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
      Dio dio = Dio();
      pr = new ProgressDialog(context,
          isDismissible: false, type: ProgressDialogType.Normal);

      pr.style(
          message: 'Downloading Video',
          textAlign: TextAlign.start,
          borderRadius: 10.0,
          backgroundColor: Colors.white,
          progressWidget: Padding(
            padding: const EdgeInsets.all(16.0),
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          elevation: 10.0,
          insetAnimCurve: Curves.easeInOut,
          progress: 0.0,
          maxProgress: 100.0,
          progressTextStyle: TextStyle(
              color: Colors.black, fontSize: 10.0, fontWeight: FontWeight.w400),
          messageTextStyle: TextStyle(
              color: Colors.black,
              fontSize: 14.0,
              fontWeight: FontWeight.w600));
      await pr.show();

      try {
        var dir = await ExtStorage.getExternalStoragePublicDirectory(
            ExtStorage.DIRECTORY_DOWNLOADS);

        await dio.download(
          videoDownloadUrl,
          "$dir/${widget.currentVideo.title}.mp4",
          options: Options(headers: {HttpHeaders.acceptEncodingHeader: "*"}),
          onReceiveProgress: (received, total) {
            if (total != -1) {
              print((received / total * 100).toStringAsFixed(0) + "%");
            } else {
              print(received);
            }
          },
          deleteOnError: true,
        );
      } catch (e) {
        print(e);
      }
      await pr.hide();
      return true;
    } else {
      openAppSettings();
      return false;
    }
  }

  Future<int> privacyOptionsDialog({currentSelection, isProtected}) async {
    switch (await showDialog<int>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text(
              'Privacy Options',
              style: TextStyle(color: Colors.black),
            ),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 2);
                },
                child: ListTile(
                  leading: Icon(
                    Icons.not_interested,
                    color: Colors.black,
                  ),
                  title: Text(
                    'Limited Access',
                  ),
                  subtitle: Text(
                    'Only people with the link can see this video',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: ((currentSelection == 3 && isProtected) ||
                          currentSelection == 2)
                      ? Icon(AntDesign.checkcircle, color: Colors.green)
                      : SizedBox(),
                  dense: true,
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 3);
                },
                child: ListTile(
                  leading: Icon(
                    Icons.people,
                    color: Colors.black,
                  ),
                  title: Text('Public'),
                  subtitle: Text(
                    'Can appear in Google search. Great for sharing this video with many.',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: (currentSelection == 3 && !isProtected)
                      ? Icon(AntDesign.checkcircle, color: Colors.green)
                      : SizedBox(),
                  dense: true,
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: ListTile(
                  leading: Icon(
                    Icons.lock,
                    color: Colors.black,
                  ),
                  title: Text('Private'),
                  subtitle: Text(
                    'Only you can see this video.',
                    style: TextStyle(fontSize: 12),
                  ),
                  trailing: currentSelection == 1
                      ? Icon(AntDesign.checkcircle, color: Colors.green)
                      : SizedBox(),
                  dense: true,
                ),
              ),
            ],
          );
        })) {
      case 1:
        return 1;
        break;
      case 2:
        return 2;
        break;
      case 3:
        return 3;
        break;
      default:
        return -1;
    }
  }

  Future<String> limitedOptionsDialog() {
    return showDialog<String>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Limited Access',
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Only people with the link can see the video',
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () {
                        Navigator.pop(context, 'setPassword');
                      },
                      child: Text(
                        widget.currentVideo.passwordProtected == 0
                            ? 'Add Password'
                            : 'Edit Password',
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Color(0xFF39447A),
                    ),
                    RaisedButton(
                      onPressed: () {
                        Navigator.pop(context, 'invitePeople');
                      },
                      child: Text(
                        'Invite People',
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Color(0xFF39447A),
                    ),
                  ],
                ),
                (widget.currentVideo.privacyStatus == 2) ||
                        (widget.currentVideo.privacyStatus == 3 &&
                            widget.currentVideo.passwordProtected == 1)
                    ? viewerList != null
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                    showModalBottomSheet(
                                      context: context,
                                      isDismissible: false,
                                      builder: (context) {
                                        return ViewerListModalSheet(
                                          viewerList: viewerList,
                                          currentVideo: widget.currentVideo,
                                        );
                                      },
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 2.0),
                                    child: Text(
                                      'People with Access',
                                      style: TextStyle(
                                        color: Color(0xFF39447A),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : SizedBox()
                    : SizedBox(),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String> showInvitePeopleDialog() {
    String email = '';
    return showDialog<String>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(
              'Custom Access',
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                    'Allow specific people to watch your video. Your video will automatically be set to private using Custom Access',
                    style: TextStyle(fontSize: 12),
                  ),
                  SizedBox(height: 4),
                  TextField(
                    style: TextStyle(
                      fontSize: 12,
                    ),
                    decoration: kPrivacyOptionsTextFieldDecoration.copyWith(
                        labelText: 'Email'),
                    onChanged: (value) {
                      setState(() {
                        email = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Color(0xFF39447A),
                  ),
                ),
              ),
              RaisedButton(
                onPressed: ValidationService.validateEmail(email) == null
                    ? () {
                        Navigator.pop(context, email);
                      }
                    : null,
                child: Text('Invite'),
                color: Color(0xFF39447A),
              ),
            ],
          );
        });
      },
    );
  }

  Future<String> showAddPasswordDialog() {
    String password = '';
    String confirmPassword = '';

    return showDialog<String>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Password Protect',
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextField(
                      style: TextStyle(
                        fontSize: 12,
                      ),
                      decoration: kPrivacyOptionsTextFieldDecoration.copyWith(
                        labelText: 'Password',
                      ),
                      obscureText: true,
                      onChanged: (value) {
                        setState(() {
                          password = value;
                        });
                      },
                    ),
                    SizedBox(height: 5),
                    TextField(
                      obscureText: true,
                      style: TextStyle(
                        fontSize: 12,
                      ),
                      decoration: kPrivacyOptionsTextFieldDecoration.copyWith(
                        labelText: 'Confirm Password',
                      ),
                      onChanged: (value) {
                        setState(() {
                          confirmPassword = value;
                        });
                      },
                    ),
                    widget.currentVideo.passwordProtected == 1
                        ? Padding(
                            padding: const EdgeInsets.only(top: 18.0),
                            child: GestureDetector(
                              onTap: () {
                                // remove password
                                Navigator.pop(context, '-1');
                              },
                              child: Text(
                                'Remove Password',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 10,
                                  decoration: TextDecoration.underline,
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFF39447A),
                    ),
                  ),
                ),
                RaisedButton(
                  onPressed: password.length >= 4
                      ? (password == confirmPassword)
                          ? () {
                              Navigator.pop(context, password);
                            }
                          : null
                      : null,
                  child: Text('Save'),
                  color: Color(0xFF39447A),
                ),
              ],
            );
          },
        );
      },
    );
  }

  List<Widget> getTagsList() {
    if (widget.currentVideo.tags.isEmpty) {
      return [Text('No tags')];
    } else {
      return List<Widget>.generate(
        widget.currentVideo.tags.length,
        (index) => Chip(
          label: Text(widget.currentVideo.tags[index]),
          backgroundColor: Color(0xFFDEEDFF),
          deleteIcon: Icon(Icons.close),
          onDeleted: () async {
            if (await UpdateService.deleteTag(
                videoId: widget.currentVideo.videoId,
                tag: widget.currentVideo.tags[index])) {
              setState(() {
                widget.currentVideo.tags.removeAt(index);
              });
            }
            snackBarMessage = 'Tag Removed';
            _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text(snackBarMessage),
              duration: Duration(milliseconds: 1500),
            ));
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xFFF7F7F7),
      body: SafeArea(
        child: ModalProgressHUD(
          inAsyncCall: videoPageHud,
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 60.0),
                child: CustomScrollView(
                  shrinkWrap: false,
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Chewie(
                                controller: _chewieController,
                              ),
                            ),
                            SizedBox(height: 16)
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: widget.currentVideo.videoStatus == 4
                          ? Padding(
                              padding: const EdgeInsets.only(
                                  left: 8.0, right: 8.0, bottom: 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Color(0xFFFFBFDC)),
                                  color: Color(0xFFFFE3F0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    'This video is trashed. Please restore it to share or make any changes',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Color(0xFFF4529C)),
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0, left: 10.0),
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          children: <Widget>[
                            AutoSizeText(
                              widget.currentVideo.title,
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3E415C),
                              ),
                              minFontSize: 12.0,
                              textAlign: TextAlign.start,
                            ),
                            widget.currentVideo.videoStatus == 4
                                ? SizedBox()
                                : Builder(
                                    builder: (context) => InkWell(
                                      onTap: () async {
                                        String newTitle = await showDialog(
                                          context: context,
                                          builder: (context) {
                                            _titleController.text =
                                                widget.currentVideo.title;
                                            return StatefulBuilder(
                                              builder: (context, setState) {
                                                return Dialog(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          'Edit Title',
                                                          style: TextStyle(
                                                              fontSize: 18.0),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal:
                                                                    8.0),
                                                        child: TextField(
                                                          decoration:
                                                              kCommentTextFieldDecoration
                                                                  .copyWith(),
                                                          maxLength: 70,
                                                          controller:
                                                              _titleController,
                                                        ),
                                                      ),
                                                      ButtonBar(
                                                        children: <Widget>[
                                                          FlatButton(
                                                            child: Text(
                                                              'Cancel',
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xFF39447A)),
                                                            ),
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                          ),
                                                          RaisedButton(
                                                            onPressed: (_titleController
                                                                            .text ==
                                                                        null ||
                                                                    _titleController
                                                                            .text
                                                                            .length <
                                                                        4)
                                                                ? null
                                                                : () {
                                                                    Navigator.pop(
                                                                        context,
                                                                        _titleController
                                                                            .text);
                                                                  },
                                                            color: Color(
                                                                0xFF39447A),
                                                            child:
                                                                Text('Submit'),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        );
                                        if (newTitle != null) {
                                          if (await UpdateService.updateTitle(
                                            videoId:
                                                widget.currentVideo.videoId,
                                            title: widget.currentVideo.title,
                                          )) {
                                            setState(() {
                                              widget.currentVideo.title =
                                                  newTitle;
                                            });
                                            snackBarMessage = 'Title Updated';
                                          } else {
                                            snackBarMessage =
                                                'Could not update title';
                                          }
                                          _scaffoldKey.currentState
                                              .showSnackBar(SnackBar(
                                            content: Text(snackBarMessage),
                                            duration:
                                                Duration(milliseconds: 1500),
                                          ));
                                        }
                                      },
                                      child: Tooltip(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.edit,
                                            size: 25,
                                            color: Color(0xFF3E415C),
                                          ),
                                        ),
                                        message: 'Edit Title',
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: 20.0),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: <Widget>[
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Image.network(
                                    widget.currentVideo.pictureUrl),
                              ),
                            ),
                            SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text(
                                      'by ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14.0,
                                        color: Color(0xFF3E415C),
                                      ),
                                    ),
                                    Text(
                                      widget.currentVideo.creatorName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12.0,
                                        color: Color(0xFF3E415C),
                                      ),
                                    )
                                  ],
                                ),
                                Text(
                                  widget.currentVideo.date,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Color(0x993E415C),
                                    fontSize: 12.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: 5.0),
                    ),
                    SliverToBoxAdapter(
                      child: Divider(
                        thickness: 1.5,
                        indent: 10.0,
                        endIndent: 10.0,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                AutoSizeText(
                                  'Description',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14.0,
                                    letterSpacing: 0.3,
                                    color: Color(0xFF3E415C),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 12.0, top: 2.0),
                                  child: Container(
                                    color: Color(0xFF5C5C86),
                                    height: 2,
                                    width: 40,
                                  ),
                                ),
                              ],
                            ),
                            widget.currentVideo.videoStatus == 4
                                ? SizedBox()
                                : Builder(builder: (context) {
                                    return InkWell(
                                      onTap: () async {
                                        String newDescription =
                                            await showDialog(
                                          context: context,
                                          builder: (context) {
                                            if (widget
                                                    .currentVideo.description !=
                                                null) {
                                              _descriptionController.text =
                                                  widget
                                                      .currentVideo.description;
                                            }
                                            return StatefulBuilder(
                                              builder: (context, setState) {
                                                return Dialog(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          'Edit Description',
                                                          style: TextStyle(
                                                              fontSize: 18.0),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal:
                                                                    8.0),
                                                        child: TextField(
                                                          decoration:
                                                              kCommentTextFieldDecoration,
                                                          keyboardType:
                                                              TextInputType
                                                                  .multiline,
                                                          controller:
                                                              _descriptionController,
                                                          maxLength: 3000,
                                                          maxLines: 3,
                                                        ),
                                                      ),
                                                      ButtonBar(
                                                        children: <Widget>[
                                                          FlatButton(
                                                            child: Text(
                                                              'Cancel',
                                                              style: TextStyle(
                                                                  color: Color(
                                                                      0xFF39447A)),
                                                            ),
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                          ),
                                                          RaisedButton(
                                                            onPressed: () {
                                                              if (_descriptionController
                                                                      .text ==
                                                                  null) {
                                                                _descriptionController
                                                                    .text = '';
                                                              }
                                                              Navigator.pop(
                                                                  context,
                                                                  _descriptionController
                                                                      .text);
                                                            },
                                                            color: Color(
                                                                0xFF39447A),
                                                            child:
                                                                Text('Submit'),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        );
                                        if (newDescription != null) {
                                          print(jsonEncode(newDescription));
                                          if (await UpdateService
                                              .updateDescription(
                                            description:
                                                jsonEncode(newDescription),
                                            videoId:
                                                widget.currentVideo.videoId,
                                            title: widget.currentVideo.title,
                                          )) {
                                            setState(() {
                                              widget.currentVideo.description =
                                                  newDescription;
                                            });
                                            snackBarMessage =
                                                'Description Updated';
                                          } else {
                                            snackBarMessage =
                                                'Could not update description';
                                          }
                                          _scaffoldKey.currentState
                                              .showSnackBar(SnackBar(
                                            content: Text(snackBarMessage),
                                            duration:
                                                Duration(milliseconds: 1500),
                                          ));
                                        } else {
                                          _descriptionController.text =
                                              widget.currentVideo.description;
                                        }
                                      },
                                      child: Tooltip(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.edit,
                                            size: 25,
                                            color: Color(0xFF3E415C),
                                          ),
                                        ),
                                        message: 'Edit Description',
                                      ),
                                    );
                                  }),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: AutoSizeText(
                          (widget.currentVideo.description == null ||
                                  widget.currentVideo.description.isEmpty)
                              ? 'No description available'
                              : widget.currentVideo.description,
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: 20.0),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Wrap(
                          spacing: 5,
                          runSpacing: -4,
                          children: getTagsList(),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: widget.currentVideo.videoStatus == 4
                          ? SizedBox()
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  OutlineButton(
                                    onPressed: () async {
                                      List<String> newTagsList = [];
                                      await showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) {
                                          String tag = '';
                                          bool processing = false;
                                          return StatefulBuilder(
                                            builder: (context, setState) {
                                              return Dialog(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Text(
                                                        'Add Tag',
                                                        style: TextStyle(
                                                            fontSize: 18.0),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 8.0),
                                                      child: TextField(
                                                        decoration:
                                                            kCommentTextFieldDecoration
                                                                .copyWith(
                                                          errorText:
                                                              ValidationService
                                                                  .validateTag(
                                                                      tag),
                                                        ),
                                                        controller:
                                                            _tagController,
                                                        maxLength: 500,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            tag = value;
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                    newTagsList.isEmpty
                                                        ? SizedBox()
                                                        : Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        8.0),
                                                            child: Text(
                                                                'Recently Added Tags'),
                                                          ),
                                                    newTagsList.isEmpty
                                                        ? SizedBox()
                                                        : Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        8.0),
                                                            child: Wrap(
                                                              children: List<
                                                                  Widget>.generate(
                                                                newTagsList
                                                                    .length,
                                                                (index) => Chip(
                                                                  label: Text(
                                                                    newTagsList[
                                                                        index],
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                  onDeleted:
                                                                      () async {
                                                                    setState(
                                                                        () {
                                                                      processing =
                                                                          true;
                                                                    });
                                                                    if (await UpdateService.deleteTag(
                                                                        videoId: widget
                                                                            .currentVideo
                                                                            .videoId,
                                                                        tag: newTagsList[
                                                                            index])) {
                                                                      setState(
                                                                          () {
                                                                        widget
                                                                            .currentVideo
                                                                            .tags
                                                                            .remove(newTagsList[index]);
                                                                        newTagsList
                                                                            .removeAt(index);
                                                                      });
                                                                    }
                                                                    setState(
                                                                        () {
                                                                      processing =
                                                                          false;
                                                                    });
                                                                  },
                                                                  backgroundColor:
                                                                      Color(
                                                                          0xFF39447A),
                                                                  deleteIconColor:
                                                                      Colors
                                                                          .white,
                                                                ),
                                                              ),
                                                              spacing: 6.0,
                                                              runSpacing: 6.0,
                                                            ),
                                                          ),
                                                    ButtonBar(
                                                      children: <Widget>[
                                                        FlatButton(
                                                          child: Text('Close'),
                                                          onPressed: processing
                                                              ? null
                                                              : () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                          textColor:
                                                              Color(0xFF39447A),
                                                        ),
                                                        RaisedButton(
                                                          onPressed: (ValidationService
                                                                          .validateTag(
                                                                              tag) !=
                                                                      null ||
                                                                  processing ||
                                                                  tag.length <
                                                                      3)
                                                              ? null
                                                              : () async {
                                                                  setState(() {
                                                                    processing =
                                                                        true;
                                                                    _tagController
                                                                        .clear();
                                                                  });
                                                                  if (await UpdateService.addTag(
                                                                      videoId: widget
                                                                          .currentVideo
                                                                          .videoId,
                                                                      tag:
                                                                          tag)) {
                                                                    setState(
                                                                        () {
                                                                      newTagsList
                                                                          .add(
                                                                              tag);
                                                                      widget
                                                                          .currentVideo
                                                                          .tags
                                                                          .add(
                                                                              tag);
                                                                    });
                                                                  }
                                                                  setState(() {
                                                                    processing =
                                                                        false;
                                                                    tag = '';
                                                                  });
                                                                },
                                                          color:
                                                              Color(0xFF39447A),
                                                          child: Text('Add'),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      );
                                      _tagController.clear();
                                      setState(() {});
                                    },
                                    child: Text('Add tag'),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: 20.0),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            AutoSizeText(
                              'Comments',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF5C5C86),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Container(
                                color: Color(0xFF5C5C86),
                                height: 2,
                                width: 40,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(
                              child: TextField(
                                controller: _commentController,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                decoration: kCommentTextFieldDecoration,
                              ),
                              height: 100,
                            ),
                            widget.currentVideo.videoStatus == 4
                                ? SizedBox()
                                : OutlineButton(
                                    child: Text('Comment'),
                                    onPressed: (_commentController.text.isEmpty)
                                        ? null
                                        : () async {
                                            setState(() {
                                              videoPageHud = true;
                                            });
                                            String comment =
                                                _commentController.text;
                                            _commentController.clear();
                                            if (await UpdateService.addComment(
                                                videoId:
                                                    widget.currentVideo.videoId,
                                                comment: jsonEncode(comment))) {
                                              comments.insert(
                                                0,
                                                Comment(
                                                  name:
                                                      '${loggedInUser.firstName} ${loggedInUser.lastName}',
                                                  pictureUrl:
                                                      loggedInUser.photoUrl,
                                                  message: comment,
                                                ),
                                              );
                                            } else {
                                              _scaffoldKey.currentState
                                                  .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Could not add comment'),
                                                duration: Duration(
                                                    milliseconds: 1500),
                                              ));
                                            }
                                            setState(() {
                                              videoPageHud = false;
                                            });
                                          },
                                  ),
                          ],
                        ),
                      ),
                    ),
                    comments == null
                        ? SliverToBoxAdapter(
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : comments.isEmpty
                            ? SliverToBoxAdapter(
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 16.0),
                                    child: Text('No comments'),
                                  ),
                                ),
                              )
                            : SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 10, right: 8.0, left: 8.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            height: 50,
                                            width: 50,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade300),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5))),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(3.0),
                                              child: Image.network(
                                                  comments[index].pictureUrl),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: <Widget>[
                                                  AutoSizeText(
                                                    comments[index].name,
                                                    textAlign:
                                                        TextAlign.justify,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 14),
                                                  ),
                                                  AutoSizeText(
                                                    comments[index].message,
                                                    textAlign:
                                                        TextAlign.justify,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 13),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  childCount: comments.length,
                                ),
                              ),
                  ],
                ),
              ),
              Column(
                children: <Widget>[
                  Expanded(child: SizedBox()),
                  Container(
                    height: 60,
                    color: Color(0xFF24365F),
                    child: widget.currentVideo.videoStatus == 1
                        ? Row(
                            children: <Widget>[
                              Expanded(
                                child: Builder(builder: (context) {
                                  return VideoPageMenuItem(
                                    iconSrc: 'images/privacy-icon.png',
                                    onPressed: () async {
                                      int result = await privacyOptionsDialog(
                                          currentSelection:
                                              widget.currentVideo.privacyStatus,
                                          isProtected: widget.currentVideo
                                                      .passwordProtected ==
                                                  1
                                              ? true
                                              : false);
                                      switch (result) {
                                        case 1:
                                          setState(() {
                                            videoPageHud = true;
                                          });
                                          //set private
                                          if (await UpdateService
                                              .updatePrivacyOption(
                                            videoId:
                                                widget.currentVideo.videoId,
                                            urlBody:
                                                '{"privacy_status":1,"password_protected":0}',
                                          )) {
                                            setState(() {
                                              widget.currentVideo
                                                  .privacyStatus = 1;
                                              videoPageHud = false;
                                            });
                                            _scaffoldKey.currentState
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Updated Privacy Settings'),
                                                duration: Duration(
                                                    milliseconds: 1500),
                                              ),
                                            );
                                          } else {
                                            setState(() {
                                              videoPageHud = false;
                                            });
                                            _scaffoldKey.currentState
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Could not Update Privacy Settings'),
                                                duration: Duration(
                                                    milliseconds: 1500),
                                              ),
                                            );
                                          }
                                          break;
                                        case 2:
                                          //set limited
                                          String optionSelected =
                                              await limitedOptionsDialog();
                                          switch (optionSelected) {
                                            case 'invitePeople':
                                              String inputEmail =
                                                  await showInvitePeopleDialog();
                                              if (inputEmail != null) {
                                                setState(() {
                                                  videoPageHud = true;
                                                });
                                                String emails = '';
                                                if (viewerList != null) {
                                                  for (var viewer
                                                      in viewerList) {
                                                    emails += '"$viewer",';
                                                  }
                                                }
                                                emails += '"$inputEmail"';
                                                print(emails);
                                                String body =
                                                    '{"privacy_status":2,"password_protected":0,"accessType":1,"emails":[$emails]}';
                                                if (await UpdateService
                                                    .updatePrivacyOption(
                                                  videoId: widget
                                                      .currentVideo.videoId,
                                                  urlBody: body,
                                                )) {
                                                  setState(() {
                                                    widget.currentVideo
                                                        .privacyStatus = 2;
                                                    if (viewerList == null) {
                                                      viewerList = [];
                                                    }
                                                    viewerList.add(inputEmail);
                                                    videoPageHud = false;
                                                  });
                                                  snackBarMessage =
                                                      'Invite Sent';
                                                } else {
                                                  setState(() {
                                                    videoPageHud = false;
                                                  });
                                                  snackBarMessage =
                                                      'Could Not send invitation';
                                                }
                                                _scaffoldKey.currentState
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content:
                                                        Text(snackBarMessage),
                                                    duration: Duration(
                                                        milliseconds: 1500),
                                                  ),
                                                );
                                              }
                                              break;
                                            case 'setPassword':
                                              String inputPassword =
                                                  await showAddPasswordDialog();

                                              String urlBody;

                                              if (inputPassword == '-1') {
                                                urlBody =
                                                    '{"password_protected":0}';
                                              } else if (inputPassword !=
                                                  null) {
                                                urlBody =
                                                    '{"password":"$inputPassword","password_confirmation":"$inputPassword","password_protected":1}';
                                              }

                                              viewerList =
                                                  await fetchViewerList();

                                              if (urlBody != null) {
                                                setState(() {
                                                  videoPageHud = true;
                                                });
                                                if (await UpdateService
                                                    .setPasswordOption(
                                                  videoId: widget
                                                      .currentVideo.videoId,
                                                  urlBody: urlBody,
                                                )) {
                                                  if (inputPassword == '-1') {
                                                    widget.currentVideo
                                                        .privacyStatus = 1;
                                                    widget.currentVideo
                                                        .passwordProtected = 0;
                                                  } else {
                                                    widget.currentVideo
                                                        .privacyStatus = 3;
                                                    widget.currentVideo
                                                        .passwordProtected = 1;
                                                  }

                                                  setState(() {
                                                    videoPageHud = false;
                                                  });
                                                  snackBarMessage =
                                                      'Updated Privacy Settings';
                                                } else {
                                                  setState(() {
                                                    videoPageHud = false;
                                                  });
                                                  snackBarMessage =
                                                      'Could not update Privacy Settings';
                                                }
                                                _scaffoldKey.currentState
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content:
                                                        Text(snackBarMessage),
                                                    duration: Duration(
                                                        milliseconds: 1500),
                                                  ),
                                                );
                                              }
                                              break;
                                            default:
                                              break;
                                          }
                                          break;
                                        case 3:
                                          setState(() {
                                            videoPageHud = true;
                                          });
                                          //set public
                                          if (await UpdateService
                                              .updatePrivacyOption(
                                            videoId:
                                                widget.currentVideo.videoId,
                                            urlBody:
                                                '{"privacy_status":3,"password_protected":0}',
                                          )) {
                                            setState(() {
                                              widget.currentVideo
                                                  .privacyStatus = 3;
                                              videoPageHud = false;
                                            });
                                            snackBarMessage =
                                                'Updated Privacy Settings';
                                          } else {
                                            setState(() {
                                              videoPageHud = false;
                                            });
                                            snackBarMessage =
                                                'Could not update privacy settings';
                                          }
                                          _scaffoldKey.currentState
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(snackBarMessage),
                                              duration:
                                                  Duration(milliseconds: 1500),
                                            ),
                                          );
                                          break;
                                        default:
                                          break;
                                      }
                                    },
                                    tooltipMessage: 'Privacy Options',
                                  );
                                }),
                              ),
                              Expanded(
                                child: Builder(
                                  builder: (context) => VideoPageMenuItem(
                                    iconSrc: 'images/tool-icon.png',
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => ToolsDialog(
                                          currentVideo: widget.currentVideo,
                                          scaffoldKey: _scaffoldKey,
                                        ),
                                      );
                                    },
                                    tooltipMessage: 'Tools',
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Builder(
                                  builder: (BuildContext context) {
                                    return VideoPageMenuItem(
                                      iconSrc: 'images/download-icon.png',
                                      onPressed: () async {
                                        bool result = await downloadFile(
                                            videoDownloadUrl:
                                                'https://api.fluvid.com/api/v1/videos/download/${widget.currentVideo.videoId}?token=$currentUserToken');
                                        if (result) {
                                          _scaffoldKey.currentState
                                              .showSnackBar(
                                            SnackBar(
                                              content:
                                                  Text('Download Completed'),
                                              duration:
                                                  Duration(milliseconds: 1500),
                                            ),
                                          );
                                        }
                                      },
                                      tooltipMessage: 'Download',
                                    );
                                  },
                                ),
                              ),
                              Expanded(
                                child: VideoPageMenuItem(
                                  iconSrc: 'images/share-icon.png',
                                  onPressed: () {
                                    Share.share(
                                        'https://stg.fluvid.com/videos/detail/${widget.currentVideo.videoId}',
                                        subject: widget.currentVideo.title);
                                  },
                                  tooltipMessage: 'Share',
                                ),
                              ),
                              Expanded(
                                child: Builder(
                                  builder: (context) {
                                    return PopupMenuButton<String>(
                                      color: Colors.white,
                                      onSelected: (selectedOption) async {
                                        switch (selectedOption) {
                                          case 'copyLink':
                                            Clipboard.setData(ClipboardData(
                                                text:
                                                    'https://stg.fluvid.com/videos/detail/${widget.currentVideo.videoId}'));
                                            _scaffoldKey.currentState
                                                .showSnackBar(
                                              SnackBar(
                                                content:
                                                    Text('Copied to Clipboard'),
                                                duration: Duration(seconds: 3),
                                              ),
                                            );
                                            break;
                                          case 'archive':
                                            bool response =
                                                await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                content: SingleChildScrollView(
                                                  child: ListBody(
                                                    children: <Widget>[
                                                      Text(
                                                          'Are you sure you want to trash this?'),
                                                    ],
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  FlatButton(
                                                    child: Text(
                                                      'Cancel',
                                                      style: TextStyle(
                                                          color: Color(
                                                              0xFF39447A)),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.pop(
                                                          context, false);
                                                    },
                                                  ),
                                                  RaisedButton(
                                                    onPressed: () {
                                                      Navigator.pop(
                                                          context, true);
                                                    },
                                                    color: Color(0xFF39447A),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 16.0),
                                                      child: Text(
                                                        'Add to Trash',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w300),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            );
                                            if (response) {
                                              setState(() {
                                                videoPageHud = true;
                                              });
                                              if (await UpdateService
                                                  .addVideoToTrash(
                                                      videoId: widget
                                                          .currentVideo
                                                          .videoId)) {
                                                snackBarMessage =
                                                    'Moved To Trash';
                                                setState(() {
                                                  widget.currentVideo
                                                      .videoStatus = 4;
                                                  removeVideo = !removeVideo;
                                                });
                                              } else {
                                                snackBarMessage =
                                                    'Could not move to trash';
                                              }
                                              setState(() {
                                                videoPageHud = false;
                                              });
                                              _scaffoldKey.currentState
                                                  .showSnackBar(
                                                SnackBar(
                                                  content:
                                                      Text(snackBarMessage),
                                                  duration: Duration(
                                                      microseconds: 2500),
                                                ),
                                              );
                                            }

                                            break;
                                          case 'share':
                                            Share.share(
                                                'https://stg.fluvid.com/videos/detail/${widget.currentVideo.videoId}',
                                                subject:
                                                    widget.currentVideo.title);
                                            break;
                                        }
                                      },
                                      icon: Image.asset('images/more-icon.png'),
                                      itemBuilder: (BuildContext context) =>
                                          <PopupMenuEntry<String>>[
                                        const PopupMenuItem<String>(
                                          value: 'copyLink',
                                          child: ListTile(
                                            dense: true,
                                            leading: Icon(Icons.content_copy),
                                            title: Text('Copy Link'),
                                          ),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: 'archive',
                                          child: ListTile(
                                            dense: true,
                                            leading: Icon(Icons.archive),
                                            title: Text('Trash'),
                                          ),
                                        ),
//                                        const PopupMenuItem<String>(
//                                          value: 'share',
//                                          child: ListTile(
//                                            dense: true,
//                                            leading: Icon(Icons.share),
//                                            title: Text('Share'),
//                                          ),
//                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              VideoPageMenuItem(
                                iconSrc: 'images/restore-icon.png',
                                onPressed: () async {
                                  bool response = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      content: SingleChildScrollView(
                                        child: ListBody(
                                          children: <Widget>[
                                            Text(
                                                'Are you sure you want to restore this?'),
                                          ],
                                        ),
                                      ),
                                      actions: <Widget>[
                                        FlatButton(
                                          child: Text(
                                            'Cancel',
                                            style: TextStyle(
                                                color: Color(0xFF39447A)),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context, false);
                                          },
                                        ),
                                        RaisedButton(
                                          onPressed: () {
                                            Navigator.pop(context, true);
                                          },
                                          color: Color(0xFF39447A),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0),
                                            child: Text(
                                              'Restore',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w300),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                  if (response) {
                                    setState(() {
                                      videoPageHud = true;
                                    });
                                    if (await UpdateService
                                        .removeVideoFromTrash(
                                            videoId:
                                                widget.currentVideo.videoId)) {
                                      snackBarMessage = 'Removed from Trash';
                                      setState(() {
                                        widget.currentVideo.videoStatus = 1;
                                        removeVideo = !removeVideo;
                                      });
                                    } else {
                                      snackBarMessage =
                                          'Could not remove from trash';
                                    }
                                    setState(() {
                                      videoPageHud = false;
                                    });
                                    _scaffoldKey.currentState.showSnackBar(
                                      SnackBar(
                                        content: Text(snackBarMessage),
                                        duration: Duration(microseconds: 2500),
                                      ),
                                    );
                                  }
                                },
                                tooltipMessage: 'Restore',
                              ),
                              VideoPageMenuItem(
                                iconSrc: 'images/bin-icon.png',
                                onPressed: () async {
                                  bool response = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      content: SingleChildScrollView(
                                        child: ListBody(
                                          children: <Widget>[
                                            Text(
                                                'Are you sure you want to permanently delete this?'),
                                          ],
                                        ),
                                      ),
                                      actions: <Widget>[
                                        FlatButton(
                                          child: Text(
                                            'Cancel',
                                            style: TextStyle(
                                                color: Color(0xFF39447A)),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context, false);
                                          },
                                        ),
                                        RaisedButton(
                                          onPressed: () {
                                            Navigator.pop(context, true);
                                          },
                                          color: Color(0xFF39447A),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0),
                                            child: Text(
                                              'Delete Forever',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w300),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                  if (response) {
                                    setState(() {
                                      videoPageHud = true;
                                    });
                                    if (await UpdateService
                                        .deleteVideoPermanently(
                                            videoId:
                                                widget.currentVideo.videoId)) {
                                      setState(() {
                                        videoPageHud = false;
                                        removeVideo = true;
                                      });
                                      Navigator.pop(context);
                                    } else {
                                      setState(() {
                                        videoPageHud = false;
                                      });
                                      _scaffoldKey.currentState
                                          .showSnackBar(SnackBar(
                                        content: Text('It will get deleted.'),
                                      ));
                                    }
                                  }
                                },
                                tooltipMessage: 'Delete',
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
