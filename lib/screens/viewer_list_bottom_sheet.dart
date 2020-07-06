import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluvidmobile/modals/video.dart';
import 'package:fluvidmobile/utils/update_service.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class ViewerListModalSheet extends StatefulWidget {
  final List<String> viewerList;
  final Video currentVideo;

  const ViewerListModalSheet({this.viewerList, this.currentVideo});

  @override
  _ViewerListModalSheetState createState() => _ViewerListModalSheetState();
}

class _ViewerListModalSheetState extends State<ViewerListModalSheet> {
  bool hud = false;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: hud,
      child: Container(
        color: Color(0xFF737373),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(15.0),
                topRight: const Radius.circular(15.0),
              ),
            ),
            child: (widget.viewerList == null)
                ? Center(
                    child: Text("No one has access to this video currently"),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomScrollView(
                      slivers: <Widget>[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Stack(
                              alignment: Alignment.center,
                              children: <Widget>[
                                Text(
                                  'Viewers with Access',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    CloseButton(),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                color: Color(0xFFCCE5FF),
                                child: ListTile(
                                  dense: true,
                                  title: Text(
                                    widget.viewerList[index],
                                    style: TextStyle(
                                      color: Color(0xFF004085),
                                      fontSize: 14,
                                    ),
                                  ),
                                  trailing: GestureDetector(
                                    onTap: () async {
                                      setState(() {
                                        hud = true;
                                      });

                                      String toDelete =
                                          widget.viewerList[index];
                                      widget.viewerList.removeAt(index);
                                      String body =
                                          '{"privacy_status":2,"password_protected":0,"accessType":1,"emails":${jsonEncode(widget.viewerList)}}';
                                      print(body);
                                      if (await UpdateService
                                          .updatePrivacyOption(
                                        videoId: widget.currentVideo.videoId,
                                        urlBody: body,
                                      )) {
                                        if (widget.viewerList.isEmpty) {
                                          widget.currentVideo.privacyStatus = 1;
                                          widget.currentVideo
                                              .passwordProtected = 0;
                                          Navigator.pop(context);
                                        } else {
                                          if (this.mounted) {
                                            setState(() {
                                              hud = false;
                                            });
                                          }
                                        }
                                      } else {
                                        if (this.mounted) {
                                          setState(() {
                                            widget.viewerList.add(toDelete);
                                            hud = false;
                                          });
                                        }
                                      }
                                    },
                                    child: Tooltip(
                                      child: Icon(
                                        Icons.close,
                                        color: Color(0xFF004085),
                                      ),
                                      message: 'Remove Access',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            childCount: widget.viewerList.length,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
