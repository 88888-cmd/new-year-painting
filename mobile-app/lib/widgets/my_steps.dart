import 'package:flutter/material.dart';

enum StepsMode { dot, number }

class MySteps extends StatelessWidget {
  final StepsMode mode;
  final List<StepItem> list;
  final int current;
  final Color activeColor;
  final Color unActiveColor;

  const MySteps({
    super.key,
    this.mode = StepsMode.dot,
    this.list = const [],
    this.current = 0,
    this.activeColor = const Color(0xFF5D4037),
    this.unActiveColor = const Color.fromARGB(255, 146, 131, 126),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: list.asMap().entries.map((entry) {
        int index = entry.key;
        StepItem item = entry.value;
        return Expanded(child: _buildStepItem(index, item));
      }).toList(),
    );
  }

  Widget _buildStepItem(int index, StepItem item) {
    bool isActive = index <= current;
    Color textColor = isActive ? activeColor : unActiveColor;

    Widget iconWidget;
    if (mode == StepsMode.number) {
      iconWidget = Container(
        width: 17,
        height: 17,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? activeColor : Colors.transparent,
          border: Border.all(
            color: isActive ? activeColor : unActiveColor,
            width: 2,
          ),
        ),
        child: Center(
          child: isActive
              ? Icon(Icons.check, size: 14, color: Colors.white)
              : Text(
                  '${index + 1}',
                  style: TextStyle(color: textColor, fontSize: 12),
                ),
        ),
      );
    } else {
      iconWidget = Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? activeColor : unActiveColor,
        ),
      );
    }

    Widget textWidget = Container(
      constraints: const BoxConstraints(maxWidth: 100),
      child: Text(
        item.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: textColor, fontSize: 11),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: mode == StepsMode.number ? 17 : 10,
          child: Row(
            children: [
              Expanded(
                child: index > 0
                    ? Container(
                        height: 1,
                        color: unActiveColor,
                        margin: const EdgeInsets.only(right: 8),
                      )
                    : const SizedBox(),
              ),
              iconWidget,
              Expanded(
                child: index < list.length - 1
                    ? Container(
                        height: 1,
                        color: unActiveColor,
                        margin: const EdgeInsets.only(left: 8),
                      )
                    : const SizedBox(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 7),
        textWidget,
      ],
    );
  }
}

class StepItem {
  final String name;

  const StepItem({required this.name});
}
