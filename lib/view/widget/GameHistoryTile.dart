import 'package:bored/model/Constants.dart';
import 'package:flutter/material.dart';

class GameHistoryTile extends StatelessWidget {
  GameHistoryTile(this.icon, this.text, this.onTap);

  final IconData icon;
  final List<String> text;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
      child: InkWell(
        splashColor: Constants.primaryColor,
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey, offset: Offset(0,5), blurRadius: 5)]
              ),
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(icon, color: Colors.grey),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      text[0],
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                  ),
                ],
              ),
              (text[1] == "lose")
                  ? Icon(Icons.close, color: Colors.grey)
                  : (text[1] == "win")
                      ? Icon(Icons.check, color: Colors.grey)
                      : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
