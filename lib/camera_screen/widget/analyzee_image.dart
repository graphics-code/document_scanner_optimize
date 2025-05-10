import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scan/scan.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class AnalyzeImageButton extends StatelessWidget {
  AnalyzeImageButton({
    required this.controller,
    required this.type,
    this.onBarcodeFound,
    super.key,
  });

  final MobileScannerController controller;
  String type;
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

    // Pick an image from the gallery
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    // Use the scan package to parse the QR code or barcode from the image
    String? result = await Scan.parse(
      image.path,
    );

    if (result != null) {
      // If a valid QR or barcode is detected
      if (onBarcodeFound != null) {
        onBarcodeFound!(result);
      }

      // Show the scanned raw value in a dialog or a Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$type Scan Successful !',
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // If no QR or barcode is found
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No QR/Barcode found'),
          backgroundColor: Colors.red,
        ),
      );
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
      },
    );
  }
}
