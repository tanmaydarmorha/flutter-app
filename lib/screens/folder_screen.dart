import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluvidmobile/modals/folder.dart';
import 'package:fluvidmobile/modals/fragments.dart';
import 'package:fluvidmobile/utils/networking.dart';
import 'package:fluvidmobile/utils/update_service.dart';
import 'package:fluvidmobile/utils/validation_service.dart';
import 'package:fluvidmobile/widgets/videos_list.dart';

import '../constants.dart';

class FolderScreen extends StatefulWidget {
  final String folderName;
  final String folderId;

  const FolderScreen({this.folderName, @required this.folderId});

  @override
  _FolderScreenState createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  List<Folder> folders;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String snackBarMessage = '';

  getFolderList() async {
    NetworkHelper networkHelper = NetworkHelper(
        url:
            'https://api.fluvid.com/api/v1/folders/${widget.folderId}?limit=50&page=1');
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
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          widget.folderName,
          style: TextStyle(fontWeight: FontWeight.w400),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Column(
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
                    folders == null
                        ? SizedBox()
                        : Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Material(
                              color: Color(0xFFF1F1F1),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              child: InkWell(
                                onTap: () async {
                                  String response = await showDialog(
                                    context: context,
                                    builder: (context) {
                                      String newFolderName;
                                      return StatefulBuilder(
                                          builder: (context, setState) {
                                        return SimpleDialog(
                                          title: const Text('Add Folder'),
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16.0),
                                              child: TextField(
                                                decoration:
                                                    kCommentTextFieldDecoration
                                                        .copyWith(
                                                  labelText: 'Folder Name',
                                                  labelStyle: TextStyle(
                                                      color: Color(0xFF39447A)),
                                                  errorText: ValidationService
                                                      .validateFolderName(
                                                          newFolderName),
                                                ),
                                                onChanged: (value) {
                                                  setState(() {
                                                    newFolderName = value;
                                                  });
                                                },
                                                maxLength: 150,
                                              ),
                                            ),
                                            ButtonBar(
                                              children: <Widget>[
                                                FlatButton(
                                                  child: Text(
                                                    'Cancel',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xFF39447A)),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                                RaisedButton(
                                                  onPressed: newFolderName ==
                                                          null
                                                      ? null
                                                      : ValidationService
                                                                  .validateFolderName(
                                                                      newFolderName) !=
                                                              null
                                                          ? null
                                                          : () {
                                                              Navigator.pop(
                                                                  context,
                                                                  newFolderName);
                                                            },
                                                  color: Color(0xFF39447A),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 16.0),
                                                    child: Text(
                                                      'Submit',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w300),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            )
                                          ],
                                        );
                                      });
                                    },
                                  );
                                  if (response != null) {
                                    Folder newFolder =
                                        await UpdateService.addNewFolder(
                                      folderName: response,
                                      parentFolderId: widget.folderId,
                                      favourite: 'false',
                                    );
                                    if (newFolder != null) {
                                      setState(() {
                                        folders.add(newFolder);
                                      });
                                      snackBarMessage = 'New Folder Added';
                                    } else {
                                      snackBarMessage =
                                          'Could not add new folder';
                                    }
                                    _scaffoldKey.currentState
                                        .showSnackBar(SnackBar(
                                      content: Text(snackBarMessage),
                                      duration: Duration(milliseconds: 1500),
                                    ));
                                  }
                                },
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.add,
                                        size: 16,
                                      ),
                                      AutoSizeText(
                                        'New Folder',
                                        style: TextStyle(fontSize: 12),
                                        maxFontSize: 12,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
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
                                              title: Text('Rename'),
                                              onTap: () {
                                                Navigator.pop(
                                                    context, 'rename');
                                              },
                                            ),
                                            ListTile(
                                              title: Text('Trash'),
                                              onTap: () {
                                                Navigator.pop(context, 'trash');
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    switch (response) {
                                      case 'rename':
                                        String response =
                                            await showDialog<String>(
                                          useRootNavigator: true,
                                          barrierDismissible: true,
                                          context: context,
                                          builder: (context) {
                                            String updatedName;
                                            return StatefulBuilder(
                                              builder: (context, setState) {
                                                return Dialog(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
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
                                                                      .symmetric(
                                                                  vertical:
                                                                      8.0),
                                                          child: Text(
                                                            'Update Folder Name',
                                                            style: TextStyle(
                                                              fontSize: 18.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(height: 10.0),
                                                        TextField(
                                                          decoration:
                                                              kCommentTextFieldDecoration
                                                                  .copyWith(
                                                            errorText: ValidationService
                                                                .validateFolderName(
                                                                    updatedName),
                                                          ),
                                                          maxLength: 150,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              updatedName =
                                                                  value;
                                                            });
                                                          },
                                                        ),
                                                        ButtonBar(
                                                          children: <Widget>[
                                                            FlatButton(
                                                              child: Text(
                                                                'Cancel',
                                                                style:
                                                                    TextStyle(
                                                                  color: Color(
                                                                      0xFF39447A),
                                                                ),
                                                              ),
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                            ),
                                                            RaisedButton(
                                                                onPressed: updatedName ==
                                                                        null
                                                                    ? null
                                                                    : ValidationService.validateFolderName(updatedName) !=
                                                                            null
                                                                        ? null
                                                                        : () {
                                                                            Navigator.pop(context,
                                                                                updatedName);
                                                                          },
                                                                child: Text(
                                                                    'Save'),
                                                                color: Color(
                                                                    0xFF39447A)),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        );
                                        if (response != null) {
                                          if (await UpdateService
                                              .updateFolderName(
                                            urlBody: '{"title":"$response"}',
                                            folderId: folders[index].folderId,
                                          )) {
                                            setState(() {
                                              folders[index].folderTitle =
                                                  response;
                                            });
                                            snackBarMessage =
                                                'Folder Name Updated';
                                          } else {
                                            snackBarMessage =
                                                'Could not update folder name';
                                          }
                                          _scaffoldKey.currentState
                                              .showSnackBar(SnackBar(
                                            content: Text(snackBarMessage),
                                            duration:
                                                Duration(milliseconds: 1500),
                                          ));
                                        }
                                        break;
                                      case 'trash':
                                        if (await UpdateService
                                            .addFolderToTrash(
                                                folderId:
                                                    folders[index].folderId)) {
                                          setState(() {
                                            folders.removeAt(index);
                                          });
                                          snackBarMessage = 'Moved to Trash';
                                        } else {
                                          snackBarMessage = 'Could not move to trash';
                                        }
                                        _scaffoldKey.currentState
                                            .showSnackBar(SnackBar(
                                          content:
                                          Text(snackBarMessage),
                                          duration:
                                          Duration(milliseconds: 1500),
                                        ));
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
                  'https://api.fluvid.com/api/v1/videos/folder/${widget.folderId}?limit=50&page=1',
              currentScreen: Screens.Folder,
            ),
          ],
        ),
      ),
    );
  }
}
