import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

Future<Uint8List?> pickImage() async {
  try {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      requestFullMetadata: false, // مهم عشان Play Store
    );

    if (image != null) {
      return await image.readAsBytes();
    }

    print("No image selected");
    return null;
  } catch (e) {
    print("Error picking image: $e");
    return null;
  }
}
