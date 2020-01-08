import 'package:flutter/material.dart';

class GameHistoryTile extends StatelessWidget {
  GameHistoryTile(this.icon, this.text, this.onTap);

  final IconData icon;
  final List<String> text;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
      child: InkWell(
        splashColor: Color.fromRGBO(236, 32, 77, 1),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey))),
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(icon, color: Colors.white),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      text[0],
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
              (text[1] == "lose")
                  ? Icon(Icons.close, color: Colors.white)
                  : (text[1] == "win")
                      ? Icon(Icons.check, color: Colors.white)
                      : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
