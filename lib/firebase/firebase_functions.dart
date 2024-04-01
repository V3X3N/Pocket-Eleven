import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreFunctions {
  static saveUser(String managerName, email, uid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({'email': email, 'managerName': managerName});
  }
}
