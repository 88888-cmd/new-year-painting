import 'package:app/models/file.dart';
import 'package:app/models/response.dart';
import 'package:app/models/user_ai_message.dart';
import 'package:app/services/http.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AIChatController extends GetxController {
  bool isIniting = true; // 是否初始化中

  final ScrollController scrollController = ScrollController();
  List<UserAIMessageModel> messageList = [];
  String session_id = '';

  UploadFileModel? selectedImage;
  final TextEditingController textController = TextEditingController(text: '');
  final FocusNode focusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();

    HttpService.to.post('ai/initChat').then((result) {
      session_id = result.data;

      messageList.insert(
        0,
        UserAIMessageModel.fromJson({
          'id': 0,
          'role': 'system',
          'text': '您好！我是年画系统信息助手。有任何问题，随时问我，马上为您解答！',
          'session_id': session_id,
          'user_id': 0,
          'create_time': '',
        }),
      );

      isIniting = false;

      update();
    });
  }

  void clickSend() {
    String text = textController.text.trim();
    int image_id = selectedImage?.id ?? 0;
    if (selectedImage == null && text.isEmpty) return;
    messageList.insert(
      0,
      UserAIMessageModel.fromJson({
        'id': 0,
        'role': 'human',
        'image_url': selectedImage?.file_url != null
            ? selectedImage!.file_url
            : '',
        'text': text,
        'session_id': session_id,
        'user_id': 0,
        'create_time': '',
      }),
    );
    textController.clear();
    selectedImage = null;
    update();

    scrollToBottom();

    HttpService.to
        .post(
          'ai/chat',
          data: {'session_id': session_id, 'image_id': image_id, 'text': text},
          showLoading: true,
        )
        .then((result) {
          messageList.insert(0, UserAIMessageModel.fromJson(result.data));
          update();

          scrollToBottom();
        });
  }

  void upload(XFile xfile) async {
    HttpService.to
        .upload('file/upload', path: xfile.path, showLoading: true)
        .then((result) {
          selectedImage = UploadFileModel.fromJson(result.data);
          update();
        });
  }

  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.jumpTo(0);
      // scrollController.animateTo(
      //   scrollController.position.maxScrollExtent,
      //   duration: const Duration(milliseconds: 300),
      //   curve: Curves.easeOut,
      // );
    }
  }

  void uploadVoice(String path) async {
    EasyLoading.show(status: 'Loading...');

    try {
      ResponseModel result = await HttpService.to.upload(
        'file/upload',
        path: path,
      );
      UploadFileModel uploadFileModel = UploadFileModel.fromJson(result.data);
      print(uploadFileModel.file_url);

      ResponseModel voiceToTextResult = await HttpService.to.post(
        'ai/voiceToText',
        data: {
          'file_id': uploadFileModel.id
        },
      );
      textController.text = voiceToTextResult.data;

      EasyLoading.dismiss();
    } catch (e) {}
  }

  @override
  void onClose() {
    scrollController.dispose();
    focusNode.dispose();
    textController.dispose();
    super.onClose();
  }
}
