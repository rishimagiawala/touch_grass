import 'dart:ffi';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  String awsUrl =
      '45ubn2ipoy2owbf7ykfio2yafe0thbkb.lambda-url.us-east-2.on.aws';

  final queryParameters = {
    'url': imgUrl,
    'param2': 'two',
  };
  final uri = Uri.https(awsUrl, '', queryParameters);
  final response = await http.get(uri, headers: {
    HttpHeaders.contentTypeHeader: 'application/json',
  });

  final cvScore = json.decode(response.body);
  print(cvScore['matching_count']);

  await FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.email)
      .update({
    'posts': FieldValue.arrayUnion([
      {
        'photoUrl': FirebaseAuth.instance.currentUser!.photoURL,
        'imgUrl': imgUrl,
        'name': FirebaseAuth.instance.currentUser!.displayName,
        'timestamp': lm,
        'location': 'Georgia Tech',
        'numOfLikes': 0,
        'grass_points': cvScore['matching_count']
      }
    ])
  });

  await FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.email)
      .update({
    'grassPoints': FieldValue.increment(cvScore['matching_count']),
    'posts': FieldValue.arrayUnion([
      {
        'photoUrl': FirebaseAuth.instance.currentUser!.photoURL,
        'imgUrl': imgUrl,
        'name': FirebaseAuth.instance.currentUser!.displayName,
        'timestamp': lm,
        'location': 'Georgia Tech',
        'numOfLikes': 0,
        'grass_points': cvScore['matching_count']
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

Future<List> getProfileFeed(String? email) async {
  var posts = [];

  var value = await FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.email)
      .get();

  List friends = [0];

  for (var friend in friends) {
    {
      var friendPost =
          await FirebaseFirestore.instance.collection('users').doc(email).get();

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
