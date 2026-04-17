import 'dart:async';

import 'package:app/i18n/index.dart';
import 'package:app/models/user_ai_message.dart';
import 'package:app/pages/aiChat/controller.dart';
import 'package:app/utils/assets_picker.dart';
import 'package:app/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> with TickerProviderStateMixin {
  bool isRecording = false;
  bool isLongPress = false;
  Timer? recordingTimer;
  int recordingSeconds = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    recordingTimer?.cancel();
    super.dispose();
  }

  void _startRecording() async {
    bool success = await AudioRecord.startRecord();

    if (success) {
      setState(() {
        isRecording = true;
        recordingSeconds = 0;
      });

      _animationController.repeat(reverse: true);

      recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          recordingSeconds++;
        });

        // 最大录制60秒
        if (recordingSeconds >= 60) {
          _stopRecording();
        }
      });
    } else {
      EasyLoading.showToast(LocaleKeys.recording_failed_please_retry.tr);
      setState(() {
        isLongPress = false;
      });
    }
  }

  void _stopRecording() async {
    String? filePath = await AudioRecord.stopRecord();
    print(filePath);

    setState(() {
      isRecording = false;
      isLongPress = false;
    });

    _animationController.stop();
    _animationController.reset();
    recordingTimer?.cancel();

    if (recordingSeconds < 1) {
      EasyLoading.showToast(LocaleKeys.recording_time_too_short.tr);
      return;
    }

    if (filePath != null) {
      Get.find<AIChatController>().uploadVoice(filePath);
    }
  }

  String _formatRecordingTime() {
    int minutes = recordingSeconds ~/ 60;
    int seconds = recordingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AIChatController>(
      init: AIChatController(),
      builder: (controller) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(LocaleKeys.ai_chat.tr),
        ),
        body: controller.isIniting
            ? Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      controller.focusNode.unfocus();
                    },
                    child: SafeArea(
                      child: Column(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: ListView.builder(
                                controller: controller.scrollController,
                                reverse: true,
                                shrinkWrap: true,
                                itemCount: controller.messageList.length,
                                itemBuilder: (context, index) {
                                  return _buildMessageItem(
                                    controller.messageList[index],
                                  );
                                },
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 2,
                                    blurRadius: 1.5,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (controller.selectedImage != null) ...[
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                Constants.mediaBaseUrl +
                                                controller
                                                    .selectedImage!
                                                    .file_url,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: 5,
                                          right: 5,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                controller.selectedImage = null;
                                              });
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.black54,
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 0.5,
                                                ),
                                              ),
                                              padding: const EdgeInsets.all(2),
                                              child: Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Divider(),
                                  ],
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 3,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        if (controller.selectedImage ==
                                            null) ...[
                                          GestureDetector(
                                            onTap: () {
                                              AssetsPicker.image(
                                                context: context,
                                              ).then((XFile? xfile) async {
                                                if (xfile != null) {
                                                  if ((await xfile.length()) >=
                                                      5 * 1024 * 1024) {
                                                    EasyLoading.showToast(
                                                      '最大文件大小为5MB',
                                                    );
                                                    return;
                                                  }
                                                  controller.upload(xfile);
                                                }
                                              });
                                            },
                                            behavior: HitTestBehavior.opaque,
                                            child: Icon(Icons.image_outlined),
                                          ),
                                          SizedBox(width: 10),
                                        ],
                                        Expanded(
                                          child: TextField(
                                            controller:
                                                controller.textController,
                                            focusNode: controller.focusNode,
                                            maxLength: 500,
                                            decoration: InputDecoration(
                                              isCollapsed: true,
                                              border: InputBorder.none,
                                              hintText: LocaleKeys
                                                  .enter_your_question
                                                  .tr,
                                              counterText: '',
                                            ),
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),

                                        GestureDetector(
                                          // onTapDown: (_) async {
                                          //   PermissionStatus status =
                                          //       await Permission
                                          //           .microphone
                                          //           .status;
                                          //   if (status.isGranted) {
                                          //   } else {
                                          //     final result = await [
                                          //       Permission.microphone,
                                          //     ].request();
                                          //     print(result);

                                          //     if (result[Permission
                                          //             .microphone] !=
                                          //         PermissionStatus.granted) {
                                          //       EasyLoading.showToast(
                                          //         '录音开始失败，无权限',
                                          //       );
                                          //       return;
                                          //     }
                                          //   }
                                          // },
                                          onLongPressStart: (_) async {
                                            print('onLongPressStart');

                                            PermissionStatus status =
                                                await Permission
                                                    .microphone
                                                    .status;
                                            if (!status.isGranted) {
                                              final result = await [
                                                Permission.microphone,
                                              ].request();

                                              if (result[Permission
                                                      .microphone] !=
                                                  PermissionStatus.granted) {
                                                EasyLoading.showToast(
                                                  LocaleKeys
                                                      .recording_failed_no_permission
                                                      .tr,
                                                );
                                                return;
                                              }
                                              return;
                                            }

                                            setState(() {
                                              isLongPress = true;
                                            });
                                            _startRecording();
                                          },
                                          onLongPressEnd: (_) {
                                            print('onLongPressEnd');
                                            if (isLongPress) {
                                              _stopRecording();
                                            }
                                          },
                                          onLongPressCancel: () {
                                            print('onLongPressCancel');
                                            if (isLongPress) {
                                              setState(() {
                                                isLongPress = false;
                                                if (isRecording) {
                                                  _stopRecording();
                                                }
                                              });
                                            }
                                          },
                                          onTap: () {
                                            if (!isLongPress) {
                                              EasyLoading.showToast(LocaleKeys.long_press_to_record.tr);
                                            }
                                          },
                                          behavior: HitTestBehavior.opaque,
                                          child: Icon(
                                            Icons.keyboard_voice_rounded,
                                            color: Color(
                                              0xFF654941,
                                            ).withOpacity(0.7),
                                            size: 24,
                                          ),
                                        ),

                                        SizedBox(width: 15),
                                        GestureDetector(
                                          onTap: () {
                                            controller.clickSend();
                                          },
                                          behavior: HitTestBehavior.opaque,
                                          child: Icon(Icons.send_rounded),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (isRecording)
                    Container(
                      // color: Colors.black.withOpacity(0.3),
                      color: Color(0xFF654941).withOpacity(0.5),
                      child: Center(
                        child: Container(
                          width: 190,
                          height: 190,
                          // padding: EdgeInsets.all(40),
                          // margin: EdgeInsets.symmetric(horizontal: 40),
                          decoration: BoxDecoration(
                            color: Color(0xFFf3e8d9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Color(0xFF654941).withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _scaleAnimation.value,
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Color(
                                          0xFF654941,
                                        ).withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.mic,
                                        size: 40,
                                        color: Color(0xFF654941),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // SizedBox(height: 20),
                              // Text(
                              //   '正在录音...',
                              //   style: TextStyle(
                              //     fontSize: 15,
                              //     fontWeight: FontWeight.bold,
                              //     color: Color(0xFF654941),
                              //   ),
                              // ),
                              SizedBox(height: 20),
                              Text(
                                _formatRecordingTime(),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF654941),
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                LocaleKeys.release_to_end_recording.tr,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF654941).withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildMessageItem(UserAIMessageModel messageModel) {
    bool isUserMessage = messageModel.role == MessageRole.human;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        crossAxisAlignment: isUserMessage
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          if (messageModel.image_url.isNotEmpty) ...[
            CachedNetworkImage(
              imageUrl: messageModel.image_url,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 10),
          ],
          if (messageModel.text.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isUserMessage
                    ? Color.fromARGB(35, 101, 73, 65)
                    : Color.fromARGB(200, 101, 73, 65),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    messageModel.text,
                    style: TextStyle(
                      color: isUserMessage ? Color(0xFF654941) : Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
