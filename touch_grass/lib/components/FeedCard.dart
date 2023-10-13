import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FeedCard extends StatelessWidget {
  const FeedCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.only(bottom: 3),
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Column(children: [
        const ListTile(
          leading: CircleAvatar(
            radius:
                25, // Change this radius for the width of the circular border
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius:
                  23, // This radius is the radius of the picture in the circle avatar itself.
              backgroundImage: NetworkImage(
                'https://th.bing.com/th/id/OIG.KjRSRH87v0JTie8aIPyW?pid=ImgGn',
              ),
            ),
          ),
          title: Text('Donald Glover'),
          subtitle: Text('8:00pm  @ NYC Central Park'),
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: const Image(
              image: NetworkImage(
                  'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg'),
            ),
          ),
        )
      ]),
    );
  }
}
