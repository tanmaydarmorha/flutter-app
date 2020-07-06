import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluvidmobile/modals/folder.dart';
import 'package:fluvidmobile/modals/fragments.dart';
import 'package:fluvidmobile/screens/folder_screen.dart';
import 'package:fluvidmobile/utils/networking.dart';
import 'package:fluvidmobile/utils/update_service.dart';
import 'package:fluvidmobile/utils/validation_service.dart';
import 'package:fluvidmobile/widgets/favFolderIcon.dart';
import 'package:fluvidmobile/widgets/videos_list.dart';

import '../constants.dart';

class FavoriteFragment extends StatefulWidget {
  @override
  _FavoriteFragmentState createState() => _FavoriteFragmentState();
}

class _FavoriteFragmentState extends State<FavoriteFragment> {
  List<Folder> folders;

  String snackBarMessage;

  getFolderList() async {
    NetworkHelper networkHelper = NetworkHelper(
        url:
            'https://api.fluvid.com/api/v1/folders/favourite/?limit=50&page=1');
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
                'Favorite',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12),
              ),
            ),
          ),
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
                            borderRadius: BorderRadius.all(Radius.circular(5)),
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
                                            padding: const EdgeInsets.symmetric(
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
                                            ),
                                          ),
                                          ButtonBar(
                                            children: <Widget>[
                                              FlatButton(
                                                child: Text(
                                                  'Cancel',
                                                  style: TextStyle(
                                                      color: Color(0xFF39447A)),
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              RaisedButton(
                                                onPressed: newFolderName == null
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
                                              ),
                                            ],
                                          )
                                        ],
                                      );
                                    });
                                  },
                                );
                                Folder newFolder =
                                    await UpdateService.addNewFolder(
                                  folderName: response,
                                  parentFolderId: '',
                                  favourite: 'true',
                                );
                                if (newFolder != null) {
                                  setState(() {
                                    folders.add(newFolder);
                                  });
                                  Scaffold.of(context).showSnackBar(SnackBar(
                                    content: Text('New Folder Added'),
                                  ));
                                } else {
                                  Scaffold.of(context).showSnackBar(SnackBar(
                                    content: Text('Could not add new folder'),
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return FolderScreen(
                                        folderName: folders[index].folderTitle,
                                        folderId: folders[index].folderId,
                                      );
                                    },
                                  ),
                                );
                              },
                              leading: folders[index].isFavorite
                                  ? FavFolderIcon()
                                  : Icon(
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
                                            title: Text('Rename'),
                                            onTap: () {
                                              Navigator.pop(context, 'rename');
                                            },
                                          ),
                                          ListTile(
                                            title: Text('Trash'),
                                            onTap: () {
                                              Navigator.pop(context, 'trash');
                                            },
                                          ),
                                          ListTile(
                                            title:
                                                Text('Remove from Favorites'),
                                            onTap: () {
                                              Navigator.pop(
                                                  context, 'removeFav');
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  switch (response) {
                                    case 'removeFav':
                                      if (await UpdateService
                                          .addFolderToFavorites(
                                              folderId: folders[index].folderId,
                                              isFavorite: false)) {
                                        setState(() {
                                          folders.removeAt(index);
                                        });
                                        snackBarMessage =
                                            'Removed from Favorites';
                                      } else {
                                        snackBarMessage = 'Could Not remove';
                                      }
                                      Scaffold.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text(snackBarMessage),
                                        duration: Duration(milliseconds: 1500),
                                      ));
                                      break;
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
                                                      const EdgeInsets.all(8.0),
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
                                                                vertical: 8.0),
                                                        child: Text(
                                                          'Update Folder Name',
                                                          style: TextStyle(
                                                            fontSize: 18.0,
                                                            fontWeight:
                                                                FontWeight.w500,
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
                                                            updatedName = value;
                                                          });
                                                        },
                                                      ),
                                                      ButtonBar(
                                                        children: <Widget>[
                                                          FlatButton(
                                                            child: Text(
                                                              'Cancel',
                                                              style: TextStyle(
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
                                                                  : ValidationService.validateFolderName(
                                                                              updatedName) !=
                                                                          null
                                                                      ? null
                                                                      : () {
                                                                          Navigator.pop(
                                                                              context,
                                                                              updatedName);
                                                                        },
                                                              child:
                                                                  Text('Save'),
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

                                          Scaffold.of(context)
                                              .showSnackBar(SnackBar(
                                            content:
                                                Text('Folder Name Updated'),
                                            duration:
                                                Duration(milliseconds: 1500),
                                          ));
                                        } else {
                                          Scaffold.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text(
                                                'Could not update folder name'),
                                            duration:
                                                Duration(milliseconds: 1500),
                                          ));
                                        }
                                      }
                                      break;
                                    case 'trash':
                                      if (await UpdateService.addFolderToTrash(
                                          folderId: folders[index].folderId)) {
                                        setState(() {
                                          folders.removeAt(index);
                                        });
                                        Scaffold.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text('Moved to trash'),
                                          duration:
                                              Duration(milliseconds: 1500),
                                        ));
                                      } else {
                                        Scaffold.of(context)
                                            .showSnackBar(SnackBar(
                                          content:
                                              Text('Could not move to trash'),
                                          duration:
                                              Duration(milliseconds: 1500),
                                        ));
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
                'https://api.fluvid.com/api/v1/videos/favourite/?limit=50&page=1',
            currentScreen: Screens.Favorites,
          ),
        ],
      ),
    );
  }
}
