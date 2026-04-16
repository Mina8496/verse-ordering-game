import 'package:flutter/material.dart';

void showHowToQuizDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        '📘 طريقة اللعب',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '🎯 الهدف:\nأجب على أكبر عدد من الأسئلة الصحيحة لجمع النجوم.',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 12),
          Text(
            '🕹️ التعليمات:\n- اقرأ السؤال جيدًا.\n- اختر الإجابة الصحيحة.\n- تابع الوقت للحصول على أفضل نتيجة.',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('فهمت ✅'),
        ),
      ],
    ),
  );
}
