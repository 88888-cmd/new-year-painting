import 'package:app/widgets/button.dart';
import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final Widget child;
  final Widget? title;
  final void Function()? onCancel;
  final void Function()? onConfirm;

  const CustomDialog({
    Key? key,
    required this.child,
    this.title,
    this.onCancel,
    this.onConfirm,
  }) : super(key: key);

  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    Widget? title,
    Widget? confirm,
    Widget? cancel,
    void Function()? onConfirm,
    void Function()? onCancel,
  }) {
    return showDialog<T>(
      context: context,
      // barrierColor: const Color(0xFF09101D).withOpacity(0.7),
      builder: (context) => CustomDialog(
        child: builder(context),
        title: title,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonGroup = <Widget>[];
    if (onCancel != null) {
      buttonGroup.add(Expanded(
        child: PrimaryButton(
          title: 'Cancel',
          gbColor: Color(0xFF777777),
          borderColor: Color(0xFF777777),
          onPressed: onCancel,
        ),
      ));
    }
    if (onConfirm != null && onCancel != null) {
      buttonGroup.add(SizedBox(width: 12));
    }
    if (onConfirm != null) {
      buttonGroup.add(Expanded(
        child: PrimaryButton(
          title: 'Confirm',
          onPressed: onConfirm,
        ),
      ));
    }
    return Dialog(
      // backgroundColor: Color(0xFFF0ECE6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: DefaultTextStyle.merge(
                textAlign: TextAlign.center,
                style: DialogTheme.of(context).titleTextStyle,
                child: title!,
              ),
            ),
          Flexible(
            flex: 1,
            fit: FlexFit.loose,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.all(16).copyWith(
                top: title != null ? 0 : null,
                bottom: buttonGroup.isNotEmpty ? 0 : null,
              ),
              child: DefaultTextStyle.merge(
                textAlign: TextAlign.center,
                style: DialogTheme.of(context).contentTextStyle?.copyWith(
                      fontSize: title != null ? 18 : null,
                    ),
                child: Container(
                  alignment: Alignment.center,
                  constraints: BoxConstraints(minHeight: 80),
                  child: child,
                ),
              ),
            ),
          ),
          if (buttonGroup.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: buttonGroup),
            ),
        ],
      ),
    );
  }
}
