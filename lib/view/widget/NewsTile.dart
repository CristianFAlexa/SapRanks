import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class NewsTile extends StatelessWidget {
  final String topic;
  final String description;
  final String date;
  final String title;
  final Function onTap;

  NewsTile(this.topic, this.description, this.date, this.title, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
      child: InkWell(
        splashColor: Color.fromRGBO(236, 32, 77, 1),
        onTap: onTap,
        child: Container(
          child: Row(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ButtonTheme(
                      minWidth: 10,
                      height: 15,
                      child: RaisedButton(
                        onPressed: () {},
                        color: Colors.grey[900],
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
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.access_time,
                          color: Colors.grey,
                          size: 12,
                        ),
                        Text(
                          date,
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        SizedBox(
                          width: 180,
                        ),
                        // READ MORE
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                          child: InkWell(
                            splashColor: Color.fromRGBO(236, 32, 77, 1),
                            onTap: () {},
                            child: Container(
                              height: 50,
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "READ MORE",
                                          style: TextStyle(
                                              fontSize: 12, color: Colors.grey),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_right,
                                    color: Colors.grey,
                                    size: 12,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
