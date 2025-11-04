import 'dart:io';

import 'package:expense_tracker/core/constants/supabase.dart';

Future<String?> uploadTransactionImage(File imageFile, String userId) async {
  try {
    final filePath = 'transactions/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';

    await supabase.storage
        .from('transaction_images')
        .upload(filePath, imageFile);

    final publicUrl = supabase.storage
        .from('transaction_images')
        .getPublicUrl(filePath);

    return publicUrl;
  } catch (e) {
    print('Error uploading transaction image: $e');
    return null;
  }
}
