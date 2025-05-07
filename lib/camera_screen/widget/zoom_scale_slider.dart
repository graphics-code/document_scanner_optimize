import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Slider widget for zoom function
class ZoomScaleSlider extends StatelessWidget {
  /// Slider widget for zoom function
  const ZoomScaleSlider({required this.controller, super.key});

  /// Controller which is used to call the zoom function
  final MobileScannerController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, state, child) {
        if (!state.isInitialized || !state.isRunning) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  controller.setZoomScale(state.zoomScale - 0.1);
                },
                child: const Icon(
                  Icons.remove_circle_outline,
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: Slider(
                  activeColor: Colors.white,
                  inactiveColor: Colors.white.withOpacity(0.5),
                  value: state.zoomScale,
                  onChanged: controller.setZoomScale,
                ),
              ),
              GestureDetector(
                onTap: () {
                  controller.setZoomScale(state.zoomScale + 0.1);
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
