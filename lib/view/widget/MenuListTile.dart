import 'package:flutter/material.dart';

class MenuListTile extends StatelessWidget {

  MenuListTile(this.icon, this.text, this.onTap);

  final IconData icon;
  final String text;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0,0,8.0,0),
      child: InkWell(
        splashColor: Color.fromRGBO(236, 32, 77, 1),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Colors.blueGrey.shade100)
              )
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
                      text,
                      style: TextStyle(fontSize: 20.0, color: Colors.white),
                    ),
                  ),
                ],
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white,),
            ],
          ),
        ),
      ),
    );
  }
}
