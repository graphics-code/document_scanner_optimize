import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Slider widget for zoom function
class ZoomScaleSlider extends StatefulWidget {
  const ZoomScaleSlider({required this.controller, super.key});

  final MobileScannerController controller;

  @override
  State<ZoomScaleSlider> createState() => _ZoomScaleSliderState();
}

class _ZoomScaleSliderState extends State<ZoomScaleSlider> {
  static const double minZoom = 0.0; // adjust if needed (e.g., 0.25)
  static const double maxZoom =
      1.0; // adjust based on actual max (or trial/error)

  bool _zoomInitialized = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, state, child) {
        if (!state.isInitialized || !state.isRunning) {
          return const SizedBox.shrink();
        }

        // Initialize zoom only once
        if (!_zoomInitialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.controller.setZoomScale(minZoom);
            setState(() {
              _zoomInitialized = true;
            });
          });
        }

        final zoomValue = state.zoomScale.clamp(minZoom, maxZoom);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  widget.controller.setZoomScale(
                    (zoomValue - 0.1).clamp(minZoom, maxZoom),
                  );
                },
                child: const Icon(
                  Icons.remove_circle_outline,
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: Slider(
                  min: minZoom,
                  max: maxZoom,
                  value: zoomValue,
                  activeColor: Colors.white,
                  inactiveColor: Colors.white.withOpacity(0.5),
                  onChanged: (value) {
                    widget.controller.setZoomScale(value);
                  },
                ),
              ),
              GestureDetector(
                onTap: () {
                  widget.controller.setZoomScale(
                    (zoomValue + 0.1).clamp(minZoom, maxZoom),
                  );
                },
                child: const Icon(
                  Icons.add_circle_outline_outlined,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
