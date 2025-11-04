import 'package:image_picker/image_picker.dart';
import 'dart:io';

Future<File?> attachTransactionImage() async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(source: ImageSource.gallery);
  if (picked != null) {
    return File(picked.path);
  } else {
    return null;
  }
}
