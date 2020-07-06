import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluvidmobile/modals/folder.dart';
import 'package:fluvidmobile/modals/fragments.dart';
import 'package:fluvidmobile/screens/folder_screen.dart';
import 'package:fluvidmobile/utils/networking.dart';
import 'package:fluvidmobile/utils/update_service.dart';
import 'package:fluvidmobile/widgets/videos_list.dart';
import '../constants.dart';

class ArchiveFragment extends StatefulWidget {
  @override
  _ArchiveFragmentState createState() => _ArchiveFragmentState();
}

class _ArchiveFragmentState extends State<ArchiveFragment> {
  List<Folder> folders;

  getFolderList() async {
    NetworkHelper networkHelper = NetworkHelper(
        url:
            'https://api.fluvid.com/api/v1/folders/archive/?limit=50&page=1');
    var response = await networkHelper.getData(token: currentUserToken);
    if (response['data'] == null) {
      if (this.mounted) {
        setState(() {
          folders = [];
        });
      }
      return;
    }

    folders = [];

    if (response['data']['folders'] != null) {
      var foldersData = response['data']['folders']['data'];
      for (var folder in foldersData) {
        folders.add(Folder(
            folderId: folder['folder_id'],
            folderTitle: folder['title'],
            isFavorite: (folder['favourite'] == 1) ? true : false));
      }
    }
    if (this.mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    getFolderList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0.0),
              child: AutoSizeText(
                'Trash',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AutoSizeText(
                    'Folders',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    color: Color(0xFF9E6FF2),
                    height: 4,
                    width: 40,
                  ),
                ],
              ),
            ),
          ),
          folders == null
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
              : folders.isEmpty
                  ? SliverToBoxAdapter(
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFFD9D9D9)),
                          color: Color(0xFFFFFFFF),
                        ),
                        child: Center(
                          child: Text(
                            'No Folder Found.',
                            style: TextStyle(
                              fontSize: 20,
                              color: Color(0xFFADAEAE),
                            ),
                          ),
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Card(
                            elevation: 3,
                            color: Colors.white,
                            child: ListTile(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                    builder: (BuildContext context) {
                                  return FolderScreen(
                                    folderName: folders[index].folderTitle,
                                    folderId: folders[index].folderId,
                                  );
                                }));
                              },
                              leading: Icon(
                                FontAwesome.folder,
                                color: Color(0xFFF7C01B),
                                size: 30,
                              ),
                              title: AutoSizeText(
                                folders[index].folderTitle,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: InkWell(
                                child: Icon(
                                  Icons.more_vert,
                                  size: 25,
                                  color: Color(0xFF9E6FF2),
                                ),
                                onTap: () async {
                                  var response =
                                      await showModalBottomSheet<String>(
                                    context: context,
                                    builder: (context) {
                                      return Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          ListTile(
                                            title: Text('Delete'),
                                            onTap: () {
                                              Navigator.pop(context, 'delete');
                                            },
                                          ),
                                          ListTile(
                                            title: Text('Restore'),
                                            onTap: () {
                                              Navigator.pop(context, 'restore');
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  switch (response) {
                                    case 'delete':
                                      bool response = await showDialog<bool>(
                                        useRootNavigator: true,
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            content: SingleChildScrollView(
                                              child: ListBody(
                                                children: <Widget>[
                                                  Text(
                                                      'Are you sure to permanently delete this?'),
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
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 16.0),
                                                  child: Text(
                                                    'Delete Forever',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w300),
                                                  ),
                                                ),
                                              )
                                            ],
                                          );
                                        },
                                      );
                                      if (response) {
                                        if (await UpdateService
                                            .deleteFolderPermanently(
                                                folderId:
                                                    folders[index].folderId)) {
                                          setState(() {
                                            folders.removeAt(index);
                                          });

                                          Scaffold.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text('Folder Deleted'),
                                            duration:
                                                Duration(milliseconds: 1500),
                                          ));
                                        } else {
                                          Scaffold.of(context)
                                              .showSnackBar(SnackBar(
                                            content:
                                                Text('Could not delete folder'),
                                            duration:
                                                Duration(milliseconds: 1500),
                                          ));
                                        }
                                      }
                                      break;
                                    case 'restore':
                                      bool response = await showDialog<bool>(
                                        useRootNavigator: true,
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            content: SingleChildScrollView(
                                              child: ListBody(
                                                children: <Widget>[
                                                  Text(
                                                      'Are you sure you want to restore the folder?'),
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
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 16.0),
                                                  child: Text(
                                                    'Restore',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w300),
                                                  ),
                                                ),
                                              )
                                            ],
                                          );
                                        },
                                      );
                                      if (response) {
                                        if (await UpdateService.restoreFolder(
                                            folderId:
                                                folders[index].folderId)) {
                                          setState(() {
                                            folders.removeAt(index);
                                          });
                                          Scaffold.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text('Folder Restored'),
                                            duration:
                                                Duration(milliseconds: 1500),
                                          ));
                                        } else {
                                          Scaffold.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text(
                                                'Could not restore folder'),
                                            duration:
                                                Duration(milliseconds: 1500),
                                          ));
                                        }
                                      }
                                      break;
                                  }
                                },
                              ),
                            ),
                          );
                        },
                        childCount: folders.length,
                      ),
                    ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AutoSizeText(
                    'Videos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    color: Color(0xFF9E6FF2),
                    height: 4,
                    width: 40,
                  ),
                ],
              ),
            ),
          ),
          VideosList(
            videosUrl:
                'https://api.fluvid.com/api/v1/videos/archive/?limit=50&page=1',
            currentScreen: Screens.Archive,
          ),
        ],
      ),
    );
  }
}
