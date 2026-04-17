import 'dart:async';

import 'package:app/i18n/index.dart';
import 'package:app/pages/searchPainting/controller.dart';
import 'package:app/widgets/searchBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class SearchPaintingPage extends StatefulWidget {
  const SearchPaintingPage({super.key});

  @override
  State<SearchPaintingPage> createState() => _SearchPaintingPageState();
}

class _SearchPaintingPageState extends State<SearchPaintingPage>
    with TickerProviderStateMixin {
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
      Get.find<SearchPaintingController>().uploadVoice(filePath);
    }
  }

  String _formatRecordingTime() {
    int minutes = recordingSeconds ~/ 60;
    int seconds = recordingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SearchPaintingController>(
      init: SearchPaintingController(),
      builder: (controller) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text('搜索年画'),
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CustomSearchBar(
                readOnly: false,
                controller: controller.textController,
                rightWidget: GestureDetector(
                  onLongPressStart: (_) async {
                    print('onLongPressStart');

                    PermissionStatus status =
                        await Permission.microphone.status;
                    if (!status.isGranted) {
                      final result = await [Permission.microphone].request();

                      if (result[Permission.microphone] !=
                          PermissionStatus.granted) {
                        EasyLoading.showToast(
                          LocaleKeys.recording_failed_no_permission.tr,
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
                    color: Color(0xFF654941).withOpacity(0.7),
                    size: 24,
                  ),
                ),
              ),
            ),

            if (isRecording)
              Container(
                // color: Colors.black.withOpacity(0.3),
                // color: Color(0xFF654941).withOpacity(0.2),
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 0.5,
                          blurRadius: 5,
                          offset: Offset(0, 1),
                        ),
                      ],
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
                                  color: Color(0xFF654941).withOpacity(0.1),
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
}
