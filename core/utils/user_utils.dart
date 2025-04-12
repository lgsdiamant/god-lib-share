import 'package:cloud_firestore/cloud_firestore.dart';

Future<String> fetchNickname(String uid) async {
  try {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final data = doc.data();
    return data?['nickname'] ?? '알 수 없음';
  } catch (e) {
    return '알 수 없음';
  }
}
