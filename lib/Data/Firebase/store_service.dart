// import 'dart:typed_data';
// import 'package:firebase_storage/firebase_storage.dart';

// class StoreService {
//   final FirebaseStorage _storage = FirebaseStorage.instance;

//   Future<String> uploadImageToStorage(String childName, Uint8List file) async {
//     try {
//       Reference ref = _storage.ref().child(childName);
//       UploadTask uploadTask = ref.putData(file);
//       TaskSnapshot snapshot = await uploadTask;
//       return await snapshot.ref.getDownloadURL();
//     } catch (e) {
//       print("Image Upload Error: $e");
//       return '';
//     }
//   }
// }
