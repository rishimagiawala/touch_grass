import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
