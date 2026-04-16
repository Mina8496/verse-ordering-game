import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<bool> isUserApprovedOrAdmin(BuildContext context) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return false;

  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get();
  if (!userDoc.exists) return false;

  final userData = userDoc.data() as Map<String, dynamic>;

  // ✅ أولاً: لو المستخدم متعطِّل
  if (userData['disabled'] == true) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("🚫 تم تعطيلك"),
        content: const Text("غير مسموح لك بالدخول"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("موافق"),
          ),
        ],
      ),
    );
    return false;
  }

  // ✅ ثانياً: لو Admin أو SuperAdmin أو DataAdmin
  final role = userData['role'];
  final isAdmin =
      role == 'DataAdmin' || role == 'Admin' || role == 'SuperAdmin';
  if (isAdmin) return true;

  // ✅ ثالثاً: التحقق من الموافقة Approved
  final isApproved = await FirebaseFirestore.instance
      .collection("Churches")
      .doc(userData['ChurchID'])
      .collection("Chapters")
      .doc(userData['ChapterID'])
      .collection("Approved")
      .doc(uid)
      .get();

  if (!isApproved.exists) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تنبيه"),
        content: const Text(
          "اكمل بياناتك للاستمرار",
        ), //"لم يتم قبولك بعد من الخادم المشرف"
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("موافق"),
          ),
        ],
      ),
    );
    return false;
  }

  return true;
}
