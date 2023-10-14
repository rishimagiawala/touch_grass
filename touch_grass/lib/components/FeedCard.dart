import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FeedCard extends StatelessWidget {
  const FeedCard(
      {super.key,
      required this.name,
      required this.picUrl,
      required this.timestamp,
      required this.location,
      required this.postImgUrl});
  final String name;
  final String picUrl;
  final String timestamp;
  final String location;
  final String postImgUrl;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.only(bottom: 3),
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.primaryContainer,
        boxShadow: const [
          BoxShadow(
            //manual color
            color: Color.fromRGBO(158, 215, 91, 1),
            blurRadius: 2.0,
            spreadRadius: 0.0,
            offset: Offset(2.0, 2.0), // shadow direction: bottom right
          )
        ],
      ),
      child: Column(children: [
        ListTile(
          leading: CircleAvatar(
            radius:
                25, // Change this radius for the width of the circular border
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius:
                  23, // This radius is the radius of the picture in the circle avatar itself.
              backgroundImage: NetworkImage(
                picUrl,
              ),
            ),
          ),
          title: Text(name),
          subtitle: Text('$timestamp @ $location'),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image(
              image: NetworkImage(postImgUrl),
            ),
          ),
        )
      ]),
    );
  }
}
