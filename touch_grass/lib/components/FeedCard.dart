import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FeedCard extends StatefulWidget {
  const FeedCard(
      {super.key,
      required this.name,
      required this.picUrl,
      required this.timestamp,
      required this.location,
      required this.postImgUrl,
      required this.grassPoints,
      required this.photoUrl});
  final String name;
  final String picUrl;
  final String timestamp;
  final String location;
  final String postImgUrl;
  final String grassPoints;
  final String photoUrl;
  // final String photoUrl;
  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  bool liked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                widget.photoUrl,
              ),
            ),
          ),
          title: Text(widget.name),
          subtitle: Text('${widget.timestamp} @ ${widget.location}'),
          trailing: Text('+ ${widget.grassPoints} Grass Points'),
        ),
        Image(
          fit: BoxFit.fitWidth,
          image: NetworkImage(widget.postImgUrl),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(
              onPressed: () {
                setState(() {
                  liked = !liked;
                });
              },
              icon: !liked
                  ? const Icon(
                      Icons.favorite_outline,
                      color: Colors.green,
                      size: 40,
                    )
                  : const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 40,
                    )),
        ])
      ]),
    );
  }
}
