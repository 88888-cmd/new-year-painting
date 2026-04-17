import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class DashedPainter extends CustomPainter {
  final double strokeWidth;
  final List<double> dashPattern;
  final Color color;
  final Radius radius;
  final StrokeCap strokeCap;

  DashedPainter({
    this.strokeWidth = 2,
    this.dashPattern = const <double>[3, 1],
    this.color = Colors.black,
    this.radius = const Radius.circular(0),
    this.strokeCap = StrokeCap.butt,
  });

  @override
  void paint(Canvas canvas, Size originalSize) {
    final Size size = originalSize;

    Paint paint =
        Paint()
          ..strokeWidth = strokeWidth
          ..strokeCap = strokeCap
          ..style = PaintingStyle.stroke
          ..color = color;

    Path path = dashPath(
      getRRectPath(size, radius),
      dashArray: CircularIntervalList(dashPattern),
    );

    canvas.drawPath(path, paint);
  }

  Path getRRectPath(Size size, Radius radius) {
    return Path()..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        radius,
      ),
    );
  }

  Path dashPath(
    Path source, {
    required CircularIntervalList<double> dashArray,
    DashOffset? dashOffset,
  }) {
    dashOffset = dashOffset ?? const DashOffset.absolute(0.0);

    final Path dest = Path();
    for (final ui.PathMetric metric in source.computeMetrics()) {
      double distance = dashOffset._calculate(metric.length);
      bool draw = true;
      while (distance < metric.length) {
        final double len = dashArray.next;
        if (draw) {
          dest.addPath(
            metric.extractPath(distance, distance + len),
            Offset.zero,
          );
        }
        distance += len;
        draw = !draw;
      }
    }

    return dest;
  }

  @override
  bool shouldRepaint(DashedPainter oldDelegate) {
    return oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.color != color ||
        oldDelegate.dashPattern != dashPattern;
  }
}

class CircularIntervalList<T> {
  CircularIntervalList(this._vals);

  final List<T> _vals;
  int _idx = 0;

  T get next {
    if (_idx >= _vals.length) {
      _idx = 0;
    }
    return _vals[_idx++];
  }
}

enum _DashOffsetType { Absolute, Percentage }

class DashOffset {
  /// Create a DashOffset that will be measured as a percentage of the length
  /// of the segment being dashed.
  ///
  /// `percentage` will be clamped between 0.0 and 1.0.
  DashOffset.percentage(double percentage)
    : _rawVal = percentage.clamp(0.0, 1.0),
      _dashOffsetType = _DashOffsetType.Percentage;

  /// Create a DashOffset that will be measured in terms of absolute pixels
  /// along the length of a [Path] segment.
  const DashOffset.absolute(double start)
    : _rawVal = start,
      _dashOffsetType = _DashOffsetType.Absolute;

  final double _rawVal;
  final _DashOffsetType _dashOffsetType;

  double _calculate(double length) {
    return _dashOffsetType == _DashOffsetType.Absolute
        ? _rawVal
        : length * _rawVal;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is DashOffset &&
        other._rawVal == _rawVal &&
        other._dashOffsetType == _dashOffsetType;
  }

  @override
  int get hashCode => Object.hash(_rawVal, _dashOffsetType);
}