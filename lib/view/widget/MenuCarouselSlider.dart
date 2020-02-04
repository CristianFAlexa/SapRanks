import 'package:bored/service/DatabaseService.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../component/PlayPage.dart';

class MenuCarouselSlider extends StatelessWidget {
  MenuCarouselSlider(this.user);

  final FirebaseUser user;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: gamesCollectionReference.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.hasError)
            return CircularProgressIndicator();
          else
            return CarouselSlider.builder(
                height: 300.0,
                aspectRatio: 16 / 9,
                viewportFraction: 0.85,
                initialPage: 0,
                enableInfiniteScroll: true,
                reverse: false,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 6),
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                pauseAutoPlayOnTouch: Duration(seconds: 10),
                enlargeCenterPage: true,
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      toPlayGame(
                        context,
                        user,
                        snapshot.data.documents[index],
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 1.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            image: NetworkImage(snapshot.data.documents[index].data['picture']),
                          ),
                        ),
                      ),
                    ),
                  );
                });
        });
  }
}
