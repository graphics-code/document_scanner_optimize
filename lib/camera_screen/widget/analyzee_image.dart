import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Button widget for analyze image function
class AnalyzeImageButton extends StatelessWidget {
  const AnalyzeImageButton({
    required this.controller,
    this.onBarcodeFound,
    super.key,
  });

  final MobileScannerController controller;
  final void Function(String rawValue)? onBarcodeFound;

  Future<void> _onPressed(BuildContext context) async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Analyze image is not supported on web'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    final BarcodeCapture? barcodes = await controller.analyzeImage(image.path);

    if (!context.mounted) return;

    if (barcodes != null && barcodes.barcodes.isNotEmpty) {
      final qrCode = barcodes.barcodes.firstWhere(
        (barcode) => barcode.format == BarcodeFormat.qrCode,
        orElse: () => const Barcode(rawValue: null, type: BarcodeType.unknown),
      );

      final rawValue = qrCode.rawValue;

      if (qrCode.format == BarcodeFormat.qrCode && rawValue != null) {
        if (onBarcodeFound != null) {
          onBarcodeFound!(rawValue);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'QR Code Scanning Successful!',
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Only QRcodes are supported!',
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: controller,
        builder: (context, state, child) {
          if (!state.isInitialized || !state.isRunning) {
            return const SizedBox.shrink();
          }

          return IconButton(
            color: Colors.white,
            icon: const Icon(Icons.image_outlined),
            iconSize: 32,
            onPressed: () => _onPressed(context),
          );
        });
  }
}
