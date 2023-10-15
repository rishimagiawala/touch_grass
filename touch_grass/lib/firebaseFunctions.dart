import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<bool> addFriend(String email) async {
  FirebaseFirestore.instance
      .collection('users')
      .doc(email)
      .get()
      .then((value) => {
            if (value.exists)
              {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.email)
                    .update({
                  'friends': FieldValue.arrayUnion([email])
                })
              }
          });

  return true;
}

Future<bool> addPost(String imgUrl, DateTime lm) async {
  FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.email)
      .update({
    'posts': FieldValue.arrayUnion([
      {
        'imgUrl': imgUrl,
        'name': FirebaseAuth.instance.currentUser!.displayName,
        'timestamp': lm,
        'location': 'Georgia Tech',
        'numOfLikes': 0
      }
    ])
  });

  return true;
}

Future<List> getFeed() async {
  var posts = [];

  var value = await FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.email)
      .get();

  List friends = value.get('friends');

  for (var friend in friends) {
    {
      var friendPost = await FirebaseFirestore.instance
          .collection('users')
          .doc(friend)
          .get();

      List friendPostList = friendPost.get('posts');

      for (var post in friendPostList) {
        posts.add(post);
      }
    }
  }

  posts
      .sort((a, b) => b['timestamp'].seconds.compareTo(a['timestamp'].seconds));

  return posts;
}
