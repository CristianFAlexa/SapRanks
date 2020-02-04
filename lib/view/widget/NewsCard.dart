import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'NewsTile.dart';

class NewsCard extends StatelessWidget {
  final String cardText;
  final IconData newsIcon;

  NewsCard(this.cardText, this.newsIcon);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Firestore.instance.collection('notification').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.hasError)
            return CircularProgressIndicator();
          else
            return Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Column(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey))),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            newsIcon,
                            color: Colors.grey[500],
                            size: 20,
                          ),
                          Text(
                            cardText,
                            style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.bold, fontSize: 20),
                          )
                        ],
                      ),
                    ),
                  ),
                  ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context, index) {
                        return NewsTile(snapshot.data.documents[index].data['tag'], snapshot.data.documents[index].data['body'],
                            '${snapshot.data.documents[index].data['date'].toDate()}'.substring(0, 19), snapshot.data.documents[index].data['title']);
                      })
                ],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.0),
              ),
              elevation: 5,
              margin: EdgeInsets.all(10),
            );
        });
  }
}
