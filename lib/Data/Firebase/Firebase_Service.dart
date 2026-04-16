import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> checkIsQuestionAnswered(String questionId, String userId) async {
    try {
      // Query Firestore to check if the user has answered the question
      QuerySnapshot querySnapshot = await _firestore
          .collection('questions')
          .doc(questionId)
          .collection('answers')
          .where(FieldPath.documentId, isEqualTo: userId) // Filter by userId
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Check if the document has the 'answered' field and its value
        bool answered = querySnapshot.docs.first.get('answered') ?? false;
        return answered;
      }
      return false; // Return false if no document is found
    } catch (e) {
      print('Error checking if question is answered: $e');
      return false;
    }
  }
}
