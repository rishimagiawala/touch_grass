import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:touch_grass/main.dart';

class Friends extends StatefulWidget {
  const Friends({
    super.key,
  });

  @override
  State<Friends> createState() => _FriendsState();
}

class _FriendsState extends State<Friends> {
  final Stream<DocumentSnapshot> _friendStream = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser?.email)
      .snapshots();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _friendStream,
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: Container(
                  height: 100,
                  width: 100,
                  child: const CircularProgressIndicator()));
        }
        var friends = snapshot.data!["friends"];
        return ListView(
          children: [
            for (var friend in friends) FriendListCard(friend: friend)
          ],
        );
      },
    );
  }
}

class FriendListCard extends StatelessWidget {
  FriendListCard({
    super.key,
    required this.friend,
  });

  final String friend;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(friend).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return Text("Document does not exist");
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          String date = readTimestamp(
              data['posts'][data['posts'].length - 1]['timestamp'].seconds);
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
            child: ListTile(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Scaffold(
                          appBar: AppBar(
                            title: Text(
                              "Touch Grass",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                      fontFamily: "Pacifico",
                                      color:
                                          const Color.fromRGBO(62, 106, 0, 1)),
                            ),
                            centerTitle: true,
                          ),
                          body: Profile(
                            email: friend,
                          ),
                        )));
              },
              leading: CircleAvatar(
                radius:
                    25, // Change this radius for the width of the circular border
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius:
                      23, // This radius is the radius of the picture in the circle avatar itself.
                  backgroundImage: NetworkImage(
                    '${data['photoUrl']}',
                  ),
                ),
              ),
              title: Text('${data['displayName']}'),
              subtitle: Text("Last Touched Grass: " + date),
            ),
          );
          //
          // Text(
          //     "Full Name: ${data['displayName']} ${data['displayName']}");
        }

        return Text("loading");
      },
    );
  }
}

String readTimestamp(int timestamp) {
  var now = DateTime.now();
  var format = DateFormat('HH:mm a');
  var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  var diff = now.difference(date);
  var time = '';

  if (diff.inSeconds <= 0 ||
      diff.inSeconds > 0 && diff.inMinutes == 0 ||
      diff.inMinutes > 0 && diff.inHours == 0 ||
      diff.inHours > 0 && diff.inDays == 0) {
    time = format.format(date);
  } else if (diff.inDays > 0 && diff.inDays < 7) {
    if (diff.inDays == 1) {
      time = diff.inDays.toString() + ' DAY AGO';
    } else {
      time = diff.inDays.toString() + ' DAYS AGO';
    }
  } else {
    if (diff.inDays == 7) {
      time = (diff.inDays / 7).floor().toString() + ' WEEK AGO';
    } else {
      time = (diff.inDays / 7).floor().toString() + ' WEEKS AGO';
    }
  }

  return time;
}

// Timestamp tm = new Timestamp(_seconds, _nanoseconds)