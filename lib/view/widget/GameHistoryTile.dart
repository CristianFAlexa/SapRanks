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
              borderRadius: BorderRadius.only(topLeft: Radius.circular(2),topRight: Radius.circular(10), bottomLeft: Radius.circular(27), bottomRight: Radius.zero ),
              gradient: (text[1] == "lose")
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color.fromRGBO(52,104,156,1), Color.fromRGBO(25,25,112,1)])
                  : (text[1] == "win")
                      ? LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color.fromRGBO(46,139,87,1), Color.fromRGBO(22,65,41,1)])
                      : LinearGradient(
                          colors: [Colors.transparent, Colors.transparent]),
          ),
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(icon, color: Colors.white,),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      text[0],
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
              (text[1] == "lose")
                  ? Icon(
                      Icons.close,
                      color: Colors.white,
                    )
                  : (text[1] == "win")
                      ? Icon(
                          Icons.check,
                          color: Colors.white,
                        )
                      : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
