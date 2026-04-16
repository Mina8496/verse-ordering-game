import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';

Future<void> exportResultsDirectToDownloads(BuildContext context) async {
  try {
    // 🔹 الحصول على مسار Downloads بدون إذونات
    String downloadsPath = await ExternalPath.getExternalStoragePublicDirectory(
      ExternalPath.DIRECTORY_DOWNLOAD,
    );

    String filePath =
        '$downloadsPath/results_${DateTime.now().millisecondsSinceEpoch}.xlsx';

    // 🔹 جلب البيانات
    final snapshot = await FirebaseFirestore.instance
        .collectionGroup("Results")
        .get();

    if (snapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد نتائج متاحة للتصدير')),
      );
      return;
    }

    // 🔹 إنشاء Excel
    final excel = Excel.createExcel();
    final sheet = excel['Results'];

    sheet.appendRow([
      'User Name',
      'Exam Name',
      'Score',
      'Total Questions',
      'Percentage',
      'Date',
    ]);

    for (var doc in snapshot.docs) {
      final data = doc.data();
      sheet.appendRow([
        data['userFullName'] ?? '',
        data['examName'] ?? '',
        data['score']?.toString() ?? '',
        data['totalQuestions']?.toString() ?? '',
        data['percentage']?.toString() ?? '',
        (data['date'] as Timestamp?)?.toDate().toString() ?? '',
      ]);
    }

    // 🔹 كتابة الملف
    final file = File(filePath);
    final bytes = excel.encode();

    if (bytes == null) throw Exception('فشل إنشاء ملف Excel');

    await file.writeAsBytes(bytes);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم حفظ الملف في مجلد التنزيلات:\n$filePath')),
    );
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء التصدير: $e')));
  }
}
