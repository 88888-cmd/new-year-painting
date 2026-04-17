import 'package:flutter/material.dart';

Widget PrimaryButton({
  required void Function()? onPressed,
  double width = 140,
  double height = 44,
  Color gbColor = const Color(0xFF8d6e63),
  String title = "button",
  Color fontColor = Colors.white,
  double fontSize = 15,
  double borderWidth = 1,
  Color borderColor = const Color(0xFF8d6e63),
  IconData? icon, // 图标-内置
  String? iconAsset, // 图标-本地assets图片
  double iconSize = 18, // 图标大小
  double iconSpacing = 8, // 图标与文本间距
}) {
  return SizedBox(
    width: width,
    height: height,
    child: TextButton(
      style: ButtonStyle(
        side: WidgetStateProperty.resolveWith((states) {
          return BorderSide(color: borderColor, width: borderWidth);
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          return Colors.transparent;
        }),
        textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 16)),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return gbColor.withOpacity(0.8);
          }
          return gbColor;
        }),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
      onPressed: onPressed,
      child:
          icon == null && iconAsset == null
              ? Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: fontColor,
                  fontSize: fontSize,
                  height: 1,
                ),
              )
              : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (icon != null)
                    Icon(icon, color: fontColor, size: iconSize)
                  else if (iconAsset != null)
                    Image.asset(iconAsset, width: iconSize, height: iconSize),

                  SizedBox(width: iconSpacing),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: fontColor,
                      fontSize: fontSize,
                      height: 1,
                    ),
                  ),
                ],
              ),
    ),
  );
}
