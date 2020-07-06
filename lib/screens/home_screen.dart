import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluvidmobile/fragments/archive_fragment.dart';
import 'package:fluvidmobile/fragments/favorite_fragment.dart';
import 'package:fluvidmobile/fragments/my_videos_fragment.dart';
import 'package:fluvidmobile/fragments/shared_fragment.dart';
import 'package:fluvidmobile/modals/drawer_item.dart';
import 'package:fluvidmobile/screens/social_login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';

class HomeScreen extends StatefulWidget {
  final drawerItems = [
    DrawerItem(
      title: 'My Videos',
      icon: Icon(
        FontAwesome.video_camera,
      ),
    ),
    DrawerItem(
      title: 'Favorite',
      icon: Icon(
        MaterialIcons.favorite,
      ),
    ),
    DrawerItem(
      title: 'Shared with me',
      icon: Icon(
        Octicons.file_directory,
      ),
    ),
    DrawerItem(
      title: 'Trash',
      icon: Icon(Foundation.archive),
    ),
  ];

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedDrawerIndex = 0;

  getDrawerItemWidget(int selectedDrawerIndex) {
    switch (selectedDrawerIndex) {
      case 0:
        return MyVideosFragment();
      case 1:
        return FavoriteFragment();
      case 2:
        return SharedFragment();
      case 3:
        return ArchiveFragment();
      default:
        return null;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> drawerOptions = [];
    for (int i = 0; i < widget.drawerItems.length; i++) {
      var d = widget.drawerItems[i];

      drawerOptions.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Container(
            decoration: BoxDecoration(
              color: i == _selectedDrawerIndex
                  ? Color(0xFF24365F)
                  : Colors.transparent,
              borderRadius: BorderRadius.all(Radius.circular(300)),
            ),
            child: ListTile(
              leading: d.icon,
              title: AutoSizeText(
                d.title,
                overflow: TextOverflow.ellipsis,
              ),
              selected: i == _selectedDrawerIndex,
              onTap: () {
                setState(() {
                  _selectedDrawerIndex = i;
                });
                Navigator.pop(context);
              },
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Image.asset(
          'images/fluvid-logo-text.png',
          scale: 3,
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountEmail: Text(loggedInUser.email),
              accountName:
                  Text('${loggedInUser.firstName} ${loggedInUser.lastName}'),
              currentAccountPicture: loggedInUser == null
                  ? CircleAvatar(
                      backgroundColor: Color(0xFF24365F),
                      child: Icon(
                        FontAwesome.user_circle,
                        size: 72.0,
                      ),
                    )
                  : CircleAvatar(
                      backgroundImage: NetworkImage(loggedInUser.photoUrl),
                    ),
            ),
            Column(
              children: drawerOptions,
            ),
            Divider(
              indent: 8.0,
              endIndent: 8.0,
            ),
            Expanded(
              child: Container(),
            ),
            ListTile(
              title: Text('Logout'),
              leading: Icon(
                SimpleLineIcons.logout,
                color: Colors.black,
              ),
              onTap: () async {
                var prefs = await SharedPreferences.getInstance();
                prefs.remove('fluvidToken');
                currentUserToken = null;
                Navigator.pop(context);
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SocialLoginScreen()));
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: getDrawerItemWidget(_selectedDrawerIndex),
      ),
    );
  }
}
