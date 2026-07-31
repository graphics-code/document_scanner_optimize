import 'dart:math';

import 'package:flutter/material.dart';

/// Signature overlay controls matching PDF-Scanner-Convert-Document UI:
/// red border + grey circular delete / rotate / resize handles.
class SignatureStickerWidget extends StatefulWidget {
  final Widget child;
  /// When `true`, hides border and handles (used before screenshot capture).
  final bool isScaleView;
  final VoidCallback onDelete;
  final double? layoutWidth;
  final double? layoutHeight;

  const SignatureStickerWidget({
    super.key,
    required this.child,
    required this.isScaleView,
    required this.onDelete,
    this.layoutWidth,
    this.layoutHeight,
  });

  @override
  State<SignatureStickerWidget> createState() => _SignatureStickerWidgetState();
}

class _SignatureStickerWidgetState extends State<SignatureStickerWidget> {
  double _angle = 0.0;
  double _scale = 1.0;
  /// Drag offset from the centered start position.
  Offset _dragOffset = Offset.zero;
  final GlobalKey _stickerKey = GlobalKey();
  Size _stickerSize = const Size(136, 136);

  Offset? _rotateStartFinger;
  double? _rotateStartAngle;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureSticker());
  }

  void _measureSticker() {
    final box = _stickerKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final size = box.size;
    if (size != _stickerSize) {
      setState(() => _stickerSize = size);
    }
  }

  Widget _layoutChild() {
    final w = widget.layoutWidth;
    final h = widget.layoutHeight;
    if (w != null && h != null) {
      return SizedBox(
        width: w,
        height: h,
        child: FittedBox(
          fit: BoxFit.contain,
          child: widget.child,
        ),
      );
    }
    return widget.child;
  }

  Widget _cornerIcon(IconData icon) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: Colors.grey.shade700,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 3,
            offset: Offset(1, 1),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 13),
    );
  }

  Widget _fixedSizeHandle(IconData icon) {
    return Transform.scale(
      scale: 1.0 / _scale,
      alignment: Alignment.center,
      child: _cornerIcon(icon),
    );
  }

  Widget _buildSticker() {
    return Transform.rotate(
      angle: _angle,
      child: Transform.scale(
        scale: _scale,
        child: Stack(
          key: _stickerKey,
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (d) {
                setState(() => _dragOffset += d.delta);
              },
              child: Container(
                margin: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  border: widget.isScaleView
                      ? null
                      : Border.all(color: Colors.red, width: 1.5),
                ),
                child: _layoutChild(),
              ),
            ),
            if (!widget.isScaleView)
              Positioned(
                top: 3,
                left: 3,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onDelete,
                  child: _fixedSizeHandle(Icons.close),
                ),
              ),
            if (!widget.isScaleView)
              Positioned(
                top: 3,
                right: 3,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: (d) {
                    _rotateStartFinger = d.globalPosition;
                    _rotateStartAngle = _angle;
                  },
                  onPanUpdate: (d) {
                    if (_rotateStartFinger == null) return;
                    final box =
                    _stickerKey.currentContext?.findRenderObject()
                    as RenderBox?;
                    if (box == null || !box.hasSize) return;
                    final center = box.localToGlobal(
                      Offset(box.size.width / 2, box.size.height / 2),
                    );
                    final prev = _rotateStartFinger! - center;
                    final curr = d.globalPosition - center;
                    setState(() {
                      _angle = _rotateStartAngle! +
                          atan2(curr.dy, curr.dx) -
                          atan2(prev.dy, prev.dx);
                    });
                  },
                  onPanEnd: (_) {
                    _rotateStartFinger = null;
                    _rotateStartAngle = null;
                  },
                  child: _fixedSizeHandle(Icons.rotate_right),
                ),
              ),
            if (!widget.isScaleView)
              Positioned(
                bottom: 3,
                right: 3,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (d) {
                    setState(() {
                      _scale = (_scale + d.delta.dy * 0.01).clamp(0.3, 5.0);
                    });
                  },
                  child: _fixedSizeHandle(Icons.open_with),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (context, constraints) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _measureSticker());

          final left =
              (constraints.maxWidth - _stickerSize.width) / 2 + _dragOffset.dx;
          final top =
              (constraints.maxHeight - _stickerSize.height) / 2 + _dragOffset.dy;

          return Stack(
            children: [
              Positioned(
                left: left,
                top: top,
                child: _buildSticker(),
              ),
            ],
          );
        },
      ),
    );
  }
}