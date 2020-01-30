import 'package:flutter/material.dart';

class ImageCard extends StatelessWidget {
  final String cardText;
  final String assetsImagePath;
  final Function onTapFunction;

  ImageCard(this.cardText, this.assetsImagePath, this.onTapFunction);

  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
      onTap: onTapFunction,
      child: Card(
        color: Colors.red,
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Column(
          children: <Widget>[
            Image.network(
              assetsImagePath,
              fit: BoxFit.fill,
            ),
            Container(
              child: Text(cardText, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0),
        ),
        elevation: 5,
        margin: EdgeInsets.all(10),
      ),
    );
  }
}
