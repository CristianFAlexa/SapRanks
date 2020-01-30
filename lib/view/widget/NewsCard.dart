import 'package:flutter/material.dart';

import 'NewsTile.dart';
import 'SimpleTile.dart';

class NewsCard extends StatelessWidget {
  final String cardText;
  final IconData newsIcon;
  final List<NewsTile> tiles;

  NewsCard(this.cardText, this.newsIcon, this.tiles);

  @override
  Widget build(BuildContext context) {
    return Card(
      semanticContainer: true,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Column(
        children: <Widget>[
          SimpleTile.withCustomColors(newsIcon, cardText, () {}, null, Colors.black, Colors.white, Colors.black),
          ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: tiles.length,
              itemBuilder: (context, index) {
                return tiles[index];
              })
        ],
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2.0),
      ),
      elevation: 5,
      margin: EdgeInsets.all(10),
    );
  }
}
