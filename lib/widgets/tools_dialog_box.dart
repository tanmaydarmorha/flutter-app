import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluvidmobile/modals/video.dart';
import 'package:fluvidmobile/utils/update_service.dart';
import 'package:fluvidmobile/widgets/video_page_tools_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';

class ToolsDialog extends StatefulWidget {
  final Video currentVideo;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const ToolsDialog({this.currentVideo, this.scaffoldKey});

  @override
  _ToolsDialogState createState() => _ToolsDialogState();
}

class _ToolsDialogState extends State<ToolsDialog> {
  File imageFile;
  ProgressDialog pr;
  String snackBarMessage;

  Future<bool> thumbnailButton() async {
    String filename = imageFile.path.split('/').last;

    return await UpdateService.updateThumbnail(
      videoId: widget.currentVideo.videoId,
      filename: filename,
      imagePath: imageFile.path,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Wrap(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.transparent),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Text(
                      'Tools',
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Wrap(
                      children: <Widget>[
                        OptionButton(
                          tooltipMessage: 'Crop',
                          imageSrc: 'images/crop-black.png',
                          onPressed: () {
                            Navigator.pop(context);
                            snackBarMessage = 'Coming Soon';
                            widget.scaffoldKey.currentState
                                .showSnackBar(SnackBar(
                              content: Text(snackBarMessage),
                              duration: Duration(milliseconds: 1500),
                            ));
                          },
                        ),
                        OptionButton(
                          tooltipMessage: 'Thumbnail',
                          imageSrc: 'images/thumbnail-black.png',
                          onPressed: () async {
                            Navigator.pop(context);
                            await showDialog<String>(
                              context: context,
                              builder: (context) => StatefulBuilder(
                                builder: (context, setState) => Dialog(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Wrap(
                                      alignment: WrapAlignment.center,
                                      children: <Widget>[
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: <Widget>[
                                            imageFile == null
                                                ? Center(
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 20.0),
                                                      child: Text(
                                                        'No photo Selected',
                                                        style: TextStyle(),
                                                      ),
                                                    ),
                                                  )
                                                : Image.file(imageFile),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8.0),
                                              child: InkWell(
                                                onTap: () async {
                                                  var picture =
                                                      await ImagePicker
                                                          .pickImage(
                                                              source:
                                                                  ImageSource
                                                                      .gallery);
                                                  if (picture != null) {
                                                    setState(() {
                                                      imageFile = picture;
                                                    });
                                                  }
                                                },
                                                child: Text(
                                                  'Select Image',
                                                  style: TextStyle(
                                                    color: Color(0xFF39447A),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Wrap(
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 8.0),
                                                  child: InkWell(
                                                    onTap: () =>
                                                        Navigator.pop(context),
                                                    child: Text(
                                                      'Cancel',
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xFF39447A),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                RaisedButton(
                                                  color: Color(0xFF39447A),
                                                  onPressed: imageFile == null
                                                      ? null
                                                      : () async {
                                                          pr = new ProgressDialog(
                                                              context,
                                                              isDismissible:
                                                                  false,
                                                              type:
                                                                  ProgressDialogType
                                                                      .Normal);

                                                          pr.style(
                                                              message:
                                                                  'Uploading Thumbnail',
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              borderRadius:
                                                                  10.0,
                                                              backgroundColor:
                                                                  Colors.white,
                                                              progressWidget:
                                                                  Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        16.0),
                                                                child: CircularProgressIndicator(
                                                                    strokeWidth:
                                                                        2),
                                                              ),
                                                              elevation: 10.0,
                                                              insetAnimCurve:
                                                                  Curves
                                                                      .easeInOut,
                                                              progress: 0.0,
                                                              maxProgress:
                                                                  100.0,
                                                              progressTextStyle: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      10.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                              messageTextStyle: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      14.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600));
                                                          await pr.show();

                                                          bool response =
                                                              await thumbnailButton();

                                                          await pr.hide();

                                                          if (response) {
                                                            snackBarMessage =
                                                                'Thumbnail Updated';
                                                          } else {
                                                            snackBarMessage =
                                                                'Could not update thumbnail ';
                                                          }
                                                          widget.scaffoldKey
                                                              .currentState
                                                              .showSnackBar(
                                                                  SnackBar(
                                                            content: Text(
                                                                snackBarMessage),
                                                            duration: Duration(
                                                                milliseconds:
                                                                    1500),
                                                          ));

                                                          Navigator.pop(
                                                              context);
                                                        },
                                                  child: Text(
                                                    'Upload',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        OptionButton(
                          tooltipMessage: 'Call to Action Button',
                          imageSrc: 'images/calltoaction.png',
                          onPressed: () {
                            Navigator.pop(context);
                            snackBarMessage = 'Coming Soon';
                            widget.scaffoldKey.currentState
                                .showSnackBar(SnackBar(
                              content: Text(snackBarMessage),
                              duration: Duration(milliseconds: 1500),
                            ));
                          },
                        ),
                        OptionButton(
                          tooltipMessage: 'Settings',
                          imageSrc: 'images/setting-black.png',
                          onPressed: () async {
                            Navigator.pop(context);
                            bool downloadStatus =
                                widget.currentVideo.downloadStatus == 1
                                    ? true
                                    : false;
                            bool viewCommentStatus =
                                widget.currentVideo.commentStatus == 0
                                    ? false
                                    : true;
                            bool editCommentStatus =
                                widget.currentVideo.downloadStatus == 2
                                    ? true
                                    : false;
                            bool statisticsStatus =
                                widget.currentVideo.statisticsStatus == 1
                                    ? true
                                    : false;
                            var response = await showDialog<String>(
                              barrierDismissible: true,
                              context: context,
                              builder: (context) => StatefulBuilder(
                                builder: (context, setState) => Dialog(
                                  child: Container(
                                    decoration:
                                        BoxDecoration(color: Colors.white),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 16.0, left: 16.0),
                                          child: Text(
                                            'Settings',
                                            style: TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                        CheckboxListTile(
                                          activeColor: Color(0xFF39447A),
                                          value: downloadStatus,
                                          onChanged: (value) {
                                            setState(() {
                                              downloadStatus = value;
                                            });
                                          },
                                          title: Text(
                                            'Viewers can download',
                                            style: TextStyle(fontSize: 14.0),
                                          ),
                                        ),
                                        CheckboxListTile(
                                          activeColor: Color(0xFF39447A),
                                          value: statisticsStatus,
                                          onChanged: (value) {
                                            setState(() {
                                              statisticsStatus = value;
                                            });
                                          },
                                          title: Text(
                                            'Viewers can view stats',
                                            style: TextStyle(fontSize: 14.0),
                                          ),
                                        ),
                                        CheckboxListTile(
                                          activeColor: Color(0xFF39447A),
                                          value: viewCommentStatus,
                                          onChanged: (value) {
                                            setState(() {
                                              viewCommentStatus = value;
                                            });
                                          },
                                          title: Text(
                                            'Viewers can view comments',
                                            style: TextStyle(fontSize: 14.0),
                                          ),
                                        ),
                                        viewCommentStatus
                                            ? CheckboxListTile(
                                                activeColor: Color(0xFF39447A),
                                                value: editCommentStatus,
                                                onChanged: (value) {
                                                  setState(() {
                                                    editCommentStatus = value;
                                                  });
                                                },
                                                title: Text(
                                                  'Viewers can add comments',
                                                  style:
                                                      TextStyle(fontSize: 14.0),
                                                ),
                                              )
                                            : SizedBox(),
                                        ButtonBar(
                                          children: <Widget>[
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
                                              onPressed: () {
                                                String urlBody =
                                                    '{"download_status":${downloadStatus ? 1 : 0},"comment_status":${viewCommentStatus ? (editCommentStatus ? 2 : 1) : 0},"statistics_status":${statisticsStatus ? 1 : 0}}';
                                                Navigator.pop(context, urlBody);
                                              },
                                              color: Color(0xFF39447A),
                                              child: Text('Submit'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                            if (response != null) {
                              if (await UpdateService.updateVideoSettings(
                                  videoId: widget.currentVideo.videoId,
                                  settingsBody: response)) {
                                snackBarMessage = 'Settings Updated';
                                widget.currentVideo.downloadStatus =
                                    downloadStatus ? 1 : 0;
                                widget.currentVideo.statisticsStatus =
                                    statisticsStatus ? 1 : 0;
                                widget.currentVideo.commentStatus =
                                    viewCommentStatus
                                        ? (editCommentStatus ? 2 : 1)
                                        : 0;
                              } else {
                                snackBarMessage = 'Could not update Settings';
                              }
                              widget.scaffoldKey.currentState
                                  .showSnackBar(SnackBar(
                                content: Text(snackBarMessage),
                                duration: Duration(milliseconds: 1500),
                              ));
                            }
                          },
                        ),
                        OptionButton(
                          tooltipMessage: 'Trim',
                          imageSrc: 'images/trim-black.png',
                          onPressed: () {
                            Navigator.pop(context);
                            snackBarMessage = 'Coming Soon';
                            widget.scaffoldKey.currentState
                                .showSnackBar(SnackBar(
                              content: Text(snackBarMessage),
                              duration: Duration(milliseconds: 1500),
                            ));
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
