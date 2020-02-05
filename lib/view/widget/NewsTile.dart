import 'package:auto_size_text/auto_size_text.dart';
import 'package:bored/model/Constants.dart';
import 'package:flutter/material.dart';

class NewsTile extends StatelessWidget {
  final String topic;
  final String description;
  final String date;
  final String title;

  NewsTile(this.topic, this.description, this.date, this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
      child: Container(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: ButtonTheme(
                minWidth: 10,
                height: 15,
                child: RaisedButton(
                  onPressed: () {},
                  color: Constants.primaryColor,
                  child: Container(
                    child: new Text(
                      topic,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10),
                    )),
                ),
              ),
            ),
            AutoSizeText(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              //textAlign: TextAlign.start,
            ),
            AutoSizeText(
              description,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              //textAlign: TextAlign.left,
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey),
                  bottom: BorderSide(color: Colors.grey))),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.access_time,
                      color: Colors.grey,
                      size: 12,
                    ),
                    Text(
                      date,
                      style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
