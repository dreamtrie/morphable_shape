import 'dart:math';

import 'package:flutter/material.dart';

import '../MorphableShapeBorder.dart';

class BubbleShape extends Shape {
  final ShapeCorner corner;

  final Length borderRadius;
  final Length arrowHeight;
  final Length arrowWidth;

  final Length arrowCenterPosition;
  final Length arrowHeadPosition;

  const BubbleShape({
    this.corner = ShapeCorner.bottomRight,
    this.borderRadius = const Length(12),
    this.arrowHeight = const Length(12),
    this.arrowWidth = const Length(12),
    this.arrowCenterPosition = const Length(0.5, unit: LengthUnit.percent),
    this.arrowHeadPosition = const Length(0.5, unit: LengthUnit.percent),
  });

  BubbleShape copyWith({
    ShapeCorner? corner,

    Length? borderRadius,
    Length? arrowHeight,
    Length? arrowWidth,

    Length? arrowCenterPosition,
    Length? arrowHeadPosition,
  }) {
    return BubbleShape(
      corner: corner??this.corner,
      borderRadius: borderRadius??this.borderRadius,
      arrowHeight: arrowHeight??this.arrowHeight,
      arrowWidth: arrowWidth??this.arrowWidth,
      arrowCenterPosition: arrowCenterPosition??this.arrowCenterPosition,
      arrowHeadPosition: arrowHeadPosition?? this.arrowHeadPosition,
    );
  }

  BubbleShape.fromJson(Map<String, dynamic> map)
      : corner = ShapeCorner.bottomRight,
        borderRadius = map["borderRadius"],
        arrowHeight = map["arrowHeight"],
        arrowWidth = map["arrowWidth"],
        arrowCenterPosition = map["arrowPosition"],
        arrowHeadPosition = map["arrowPosition"];

  Map<String, dynamic> toJson() {
    Map<String, dynamic> rst = {"name": this.runtimeType};
    rst["borderRadius"] = borderRadius;
    rst["arrowHeight"] = arrowHeight;
    rst["arrowWidth"] = arrowWidth;
    rst["arrowPositionPercent"] = arrowCenterPosition;
    return rst;
  }

  DynamicPath generateDynamicPath(Rect rect) {
    final size = rect.size;

    double borderRadius;
    double arrowHeight;
    double arrowWidth;
    double arrowCenterPosition;
    double arrowHeadPosition;
    borderRadius =
        this.borderRadius.toPX(constraintSize: min(size.height, size.width));
    if (corner.isHorizontal) {
      arrowHeight = this.arrowHeight.toPX(constraintSize: size.height);
      arrowWidth = this.arrowWidth.toPX(constraintSize: size.width);
      arrowCenterPosition =
          this.arrowCenterPosition.toPX(constraintSize: size.width);
      arrowHeadPosition =
          this.arrowHeadPosition.toPX(constraintSize: size.width);
    } else {
      arrowHeight = this.arrowHeight.toPX(constraintSize: size.width);
      arrowWidth = this.arrowWidth.toPX(constraintSize: size.height);
      arrowCenterPosition =
          this.arrowCenterPosition.toPX(constraintSize: size.height);
      arrowHeadPosition =
          this.arrowHeadPosition.toPX(constraintSize: size.height);
    }

    List<DynamicNode> nodes = [];

    if (this.corner.isHorizontalRight) {
      arrowCenterPosition = size.width - arrowCenterPosition;
      arrowHeadPosition = size.width - arrowHeadPosition;
    }
    if (this.corner.isVerticalBottom) {
      arrowCenterPosition = size.height - arrowCenterPosition;
      arrowHeadPosition = size.height - arrowHeadPosition;
    }

    final double spacingLeft = this.corner.isLeft ? arrowHeight : 0;
    final double spacingTop = this.corner.isTop ? arrowHeight : 0;
    final double spacingRight = this.corner.isRight ? arrowHeight : 0;
    final double spacingBottom = this.corner.isBottom ? arrowHeight : 0;

    final double left = spacingLeft + rect.left;
    final double top = spacingTop + rect.top;
    final double right = rect.right - spacingRight;
    final double bottom = rect.bottom - spacingBottom;

    double radiusBound = 0;

    if (this.corner.isHorizontal) {
      arrowCenterPosition = arrowCenterPosition.clamp(0, size.width);
      arrowHeadPosition = arrowHeadPosition.clamp(0, size.width);
      arrowWidth =
          arrowWidth.clamp(0, 2 * min(arrowCenterPosition, size.width - arrowCenterPosition));
      radiusBound = min(
          min(right - arrowCenterPosition - arrowWidth / 2,
              arrowCenterPosition - arrowWidth / 2 - left),
          (bottom - top) / 2);
      borderRadius =
          borderRadius.clamp(0.0, radiusBound >= 0 ? radiusBound : 0);
    } else {
      arrowCenterPosition = arrowCenterPosition.clamp(0, size.height);
      arrowHeadPosition = arrowHeadPosition.clamp(0, size.height);
      arrowWidth =
          arrowWidth.clamp(0, 2 * min(arrowCenterPosition, size.height - arrowCenterPosition));
      radiusBound = min(
          min(bottom - arrowCenterPosition - arrowWidth / 2,
              arrowCenterPosition - arrowWidth / 2 - top),
          (right - left) / 2);
      borderRadius = borderRadius.clamp(
            0.0,
            radiusBound >= 0 ? radiusBound : 0,
          );
    }

    if (this.corner.isTop) {
      nodes.add(DynamicNode(position: Offset(arrowCenterPosition - arrowWidth / 2, top)));
      nodes.add(DynamicNode(position: Offset(arrowHeadPosition, rect.top)));
      nodes.add(DynamicNode(position: Offset(arrowCenterPosition + arrowWidth / 2, top)));
    }
    if (borderRadius > 0) {
      nodes.add(
          DynamicNode(position: Offset(right - borderRadius, top)));
      nodes.arcTo(
          Rect.fromLTRB(
              right - 2*borderRadius, top, right, top + 2*borderRadius),
          3 * pi / 2,
          pi / 2);
    } else {
      nodes.add(DynamicNode(position: Offset(right, top)));
    }
    //RIGHT, TOP

    if (this.corner.isRight) {
      nodes.add(DynamicNode(position: Offset(right, arrowCenterPosition - arrowWidth / 2)));
      nodes.add(DynamicNode(position: Offset(rect.right, arrowHeadPosition)));
      nodes.add(DynamicNode(position: Offset(right, arrowCenterPosition + arrowWidth / 2)));
    }
    if (borderRadius> 0) {
      nodes.add(DynamicNode(
          position: Offset(right, bottom - borderRadius)));
      nodes.arcTo(
          Rect.fromLTRB(right - borderRadius*2,
              bottom - borderRadius*2, right, bottom),
          0,
          pi / 2);
    } else {
      nodes.add(DynamicNode(position: Offset(right, bottom)));
    }

    if (this.corner.isBottom) {
      nodes
          .add(DynamicNode(position: Offset(arrowCenterPosition + arrowWidth / 2, bottom)));
      nodes.add(DynamicNode(position: Offset(arrowHeadPosition, rect.bottom)));
      nodes
          .add(DynamicNode(position: Offset(arrowCenterPosition - arrowWidth / 2, bottom)));
    }
    if (borderRadius > 0) {
      nodes.add(
          DynamicNode(position: Offset(left + borderRadius, bottom)));
      nodes.arcTo(
          Rect.fromLTRB(left, bottom - borderRadius*2,
              left + borderRadius*2, bottom),
          pi / 2,
          pi / 2);
    } else {
      nodes.add(DynamicNode(position: Offset(left, bottom)));
    }
    //LEFT, BOTTOM

    if (this.corner.isLeft) {
      nodes.add(DynamicNode(position: Offset(left, arrowCenterPosition + arrowWidth / 2)));
      nodes.add(DynamicNode(position: Offset(rect.left, arrowHeadPosition)));
      nodes.add(DynamicNode(position: Offset(left, arrowCenterPosition - arrowWidth / 2)));
    }
    if (borderRadius > 0) {
      nodes.add(DynamicNode(position: Offset(left, top + borderRadius)));
      nodes.arcTo(
          Rect.fromLTRB(
              left, top, left + borderRadius*2, top + borderRadius*2),
          pi,
          pi / 2);
    } else {
      nodes.add(DynamicNode(position: Offset(left, top)));
    }

    return DynamicPath(nodes: nodes, size: size);
  }
}
