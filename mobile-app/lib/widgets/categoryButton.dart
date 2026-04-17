import 'package:flutter/material.dart';

class CategoryButtonItem extends StatelessWidget {
  final double height;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final String title;
  final int value;
  final bool isSelected;
  final VoidCallback onPressed;
  final bool showSelectedIcon;

  const CategoryButtonItem({
    super.key,
    this.height = 36,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
    this.borderRadius = 18,
    required this.title,
    required this.value,
    required this.isSelected,
    required this.onPressed,
    this.showSelectedIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF8D6E63) : Color(0xFFFAF6F0),
            border: Border.all(
              color: isSelected ? Color(0xFF6d4c41) : Color(0xFFDBD0CB),
            ),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          alignment: Alignment.center,
          padding: padding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Color(0xFF654941),
                  fontSize: 14,
                ),
              ),
              if (isSelected && showSelectedIcon) const SizedBox(width: 8),
              if (isSelected && showSelectedIcon)
                Image.asset(width: 15, height: 15, 'assets/images/check.png'),
              // const Icon(Icons.check, size: 16, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
