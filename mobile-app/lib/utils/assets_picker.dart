import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AssetsPicker {
  static final ImagePicker _imagePicker = ImagePicker();

  static Future<XFile?> image({required BuildContext context}) async {
    if (Platform.isIOS) {
      final result = await [Permission.photos].request();

      if (result[Permission.photos] != PermissionStatus.granted &&
          result[Permission.photos] != PermissionStatus.limited) {
        EasyLoading.showToast('Need to access the photo album.');
        return null;
      }
    }

    return _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 512,
      imageQuality: 75,
      requestFullMetadata: false,
    );
  }

  static Future<List<XFile>> multiImage({
    required BuildContext context,
    // ImageSource source = ImageSource.gallery,
    // double maxWidth = 256,
    // double maxHeight = 256,
    int limit = 9,
  }) async {
    // if (!(await Acces.photos())) {
    //   EasyLoading.showToast('Need to access the photo album.');
    //   return null;
    // }
    if (Platform.isIOS) {
      final result = await [Permission.photos].request();

      if (result[Permission.photos] != PermissionStatus.granted &&
          result[Permission.photos] != PermissionStatus.limited) {
        EasyLoading.showToast('Need to access the photo album.');
        return [];
      }
    }

    return _imagePicker.pickMultiImage(
      // source: source,
      // maxWidth: maxWidth,
      // maxHeight: maxHeight,
      maxHeight: 512,
      limit: limit,
      imageQuality: 75,
      requestFullMetadata: false,
    );
  }

  static Future<XFile?> video({required BuildContext context}) async {
    // if (!(await Access.photos())) {
    //   EasyLoading.showToast('Need to access the photo album.');
    //   return null;
    // }
    if (Platform.isIOS) {
      final result = await [Permission.photos].request();

      if (result[Permission.photos] != PermissionStatus.granted &&
          result[Permission.photos] != PermissionStatus.limited) {
        EasyLoading.showToast('Need to access the photo album.');
        return null;
      }
    }
    return _imagePicker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(seconds: 20),
    );
  }
}
