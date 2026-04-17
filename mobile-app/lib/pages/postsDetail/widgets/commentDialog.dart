import 'package:app/i18n/index.dart';
import 'package:app/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommentDialog extends StatefulWidget {
  final void Function(String) onSend;

  const CommentDialog({super.key, required this.onSend});

  static Future<T?> show<T>({
    required BuildContext context,
    required void Function(String) onSend,
  }) {
    return showDialog<T>(
      context: context,
      barrierColor: const Color(0xFF09101D).withOpacity(0.7),
      builder: (context) => CommentDialog(onSend: onSend),
    );
  }

  @override
  State<CommentDialog> createState() => _CommentDialogState();
}

class _CommentDialogState extends State<CommentDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        onTap: () {},
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.only(
                  top: 10,
                  left: 16,
                  right: 16,
                  bottom:
                      (MediaQuery.of(context).viewInsets.bottom > 0
                          ? MediaQuery.of(context).viewInsets.bottom
                          : 0) +
                      10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextField(
                      controller: _controller,
                      autofocus: true,
                      maxLines: 3,
                      style: const TextStyle(
                        color: Color(0xFF654941),
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        hintText: LocaleKeys.posts_comment_input_hint.tr,
                        hintStyle: const TextStyle(
                          color: Color(0xFF9DA4B0),
                          fontSize: 13,
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(6),
                          ),
                          borderSide: BorderSide(
                            width: 1,
                            color: const Color(0xFFd7ccc8),
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(6),
                          ),
                          borderSide: BorderSide(
                            width: 1,
                            color: const Color(0xFF8d6e63),
                          ),
                        ),
                        isCollapsed: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    PrimaryButton(
                      width: 70,
                      height: 30,
                      title: LocaleKeys.confirm.tr,
                      fontSize: 13,
                      onPressed: () {
                        if (_controller.text.trim().isNotEmpty) {
                          widget.onSend(_controller.text.trim());
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
