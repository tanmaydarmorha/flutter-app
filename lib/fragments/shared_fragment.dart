import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:fluvidmobile/modals/fragments.dart';
import 'package:fluvidmobile/widgets/videos_list.dart';

class SharedFragment extends StatefulWidget {
  @override
  _SharedFragmentState createState() => _SharedFragmentState();
}

class _SharedFragmentState extends State<SharedFragment> {
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
                'Shared With Me',
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
                'https://api.fluvid.com/api/v1/videos/shared?limit=50&page=1',
            currentScreen: Screens.Shared,
          ),
        ],
      ),
    );
  }
}
