import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final VoidCallback? onSearch;
  final bool enabled;
  final bool readOnly;
  final String hintText;
  final Color backgroundColor;
  final Widget? rightWidget;

  const CustomSearchBar({
    Key? key,
    this.controller,
    this.onChanged,
    this.onSearch,
    this.enabled = true,
    this.readOnly = false,
    this.hintText = '搜索年画...',
    this.backgroundColor = Colors.white,
    this.rightWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8D8CA), width: 1),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(Icons.search, color: const Color(0xFF9DA4B0), size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              enabled: enabled,
              readOnly: readOnly,
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: Color(0xFF9DA4B0),
                  fontSize: 14,
                  height: 1.2,
                ),
                border: InputBorder.none,
              ),
              style: const TextStyle(
                color: Color(0xFF654941),
                fontSize: 14,
                height: 1.2,
              ),
            ),
          ),
          if (rightWidget != null) ...[
            rightWidget!,
            const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }
}
