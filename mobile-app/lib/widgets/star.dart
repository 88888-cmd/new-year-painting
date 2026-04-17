import 'package:flutter/material.dart';

class StarRating extends StatefulWidget {
  final int rating;
  final Function(int) onRatingChanged;
  final bool isClickable;
  final double starSize;

  const StarRating({
    required this.rating,
    required this.onRatingChanged,
    this.isClickable = true,
    this.starSize = 33
  });

  @override
  _StarRatingState createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  int _currentRating = 0;

  @override
  void initState() {
    _currentRating = widget.rating;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (widget.isClickable) {
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _currentRating = index + 1;
                  widget.onRatingChanged(_currentRating);
                });
              },
              child: Icon(
                index < _currentRating
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: Color(0xFFffb74d),
                size: widget.starSize
              ),
            ),
          );
        } else {
          return Icon(
            index < _currentRating
                ? Icons.star_rounded
                : Icons.star_border_rounded,
            color: Color(0xFFffb74d),
            size: widget.starSize
          );
        }
      }),
    );
  }
}