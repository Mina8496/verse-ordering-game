import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/exam_selection.dart';
import '../../domain/entities/exam_setting.dart';
import '../../domain/repositories/exam_settings_repository.dart';

class FirestoreExamSettingsRepository implements ExamSettingsRepository {
  FirestoreExamSettingsRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _settings({
    required String churchId,
    required String chapterId,
  }) => _firestore
      .collection('Churches')
      .doc(churchId)
      .collection('Chapters')
      .doc(chapterId)
      .collection('Exames')
      .doc('nFL11C4v8fPRqIgG0ZAe')
      .collection('Settings');

  @override
  Future<ExamSelection?> fetchCurrentSelection() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final document = await _firestore
        .collection('users')
        .doc(uid)
        .collection('SelectedExam')
        .doc('Current')
        .get();
    final data = document.data();
    return document.exists && data != null ? ExamSelection.fromMap(data) : null;
  }

  @override
  Future<List<ExamSetting>> fetchSettings({
    required String churchId,
    required String chapterId,
  }) async {
    final snapshot = await _settings(
      churchId: churchId,
      chapterId: chapterId,
    ).get();

    return snapshot.docs
        .map(
          (document) =>
              ExamSetting.fromMap({...document.data(), 'id': document.id}),
        )
        .toList();
  }

  @override
  Future<List<ExamSetting>> fetchAllSettings({
    required String churchId,
    required String chapterId,
  }) async {
    final snapshot = await _settings(
      churchId: churchId,
      chapterId: chapterId,
    ).get();
    return snapshot.docs
        .map(
          (document) =>
              ExamSetting.fromMap({...document.data(), 'id': document.id}),
        )
        .toList();
  }

  @override
  Future<void> deleteSetting({
    required String churchId,
    required String chapterId,
    required String settingId,
  }) => _settings(
    churchId: churchId,
    chapterId: chapterId,
  ).doc(settingId).delete();
}
