import 'package:flutter/material.dart';

class SimpleTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final Function onTap;
  final IconData marginIcon;
  final Color textColor;
  final Color tileColor;
  final Color borderColor;

  SimpleTile(this.icon, this.text, this.onTap, this.marginIcon)
      : this.textColor = Colors.white,
        this.tileColor = Colors.red[700],
        this.borderColor = Colors.white;

  SimpleTile.withCustomColors(IconData icon, String text, Function onTap,
      IconData marginIcon, Color textColor, Color tileColor, Color borderColor)
      : this.icon = icon,
        this.text = text,
        this.onTap = onTap,
        this.marginIcon = marginIcon,
        this.textColor = textColor,
        this.tileColor = tileColor,
        this.borderColor = borderColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(3.0, 0, 3.0, 0),
      child: InkWell(
        splashColor: Color.fromRGBO(236, 32, 77, 1),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
              color: tileColor,
              border: Border(bottom: BorderSide(color: borderColor))),
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Icon(
                      icon,
                      color: textColor,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      text,
                      style: TextStyle(fontSize: 16.0, color: textColor),
                    ),
                  ),
                ],
              ),
              Icon(
                marginIcon,
                color: textColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
