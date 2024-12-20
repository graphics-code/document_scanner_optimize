import 'package:audioplayers/audioplayers.dart';
import 'package:doc_scanner/camera_screen/provider/camera_provider.dart';
import 'package:doc_scanner/camera_screen/widget/scanner_button_widget.dart';
import 'package:doc_scanner/camera_screen/widget/scanner_error_widget.dart';
import 'package:doc_scanner/core/local_storage.dart';
import 'package:doc_scanner/utils/app_constant.dart';
import 'package:doc_scanner/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';

class BarCodeCameraScreen extends StatefulWidget {
  const BarCodeCameraScreen({super.key});

  @override
  _BarCodeCameraScreenState createState() => _BarCodeCameraScreenState();
}

class _BarCodeCameraScreenState extends State<BarCodeCameraScreen> {
  final MobileScannerController controller = MobileScannerController(
    formats: const [
      BarcodeFormat.codebar,
      BarcodeFormat.aztec,
      BarcodeFormat.codabar,
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.code93,
      BarcodeFormat.dataMatrix,
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.itf,
      BarcodeFormat.pdf417,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
    ],
  );
  bool activeDialog = false;
  final player = AudioPlayer();
  void _openBrowserWithSearch(String query) async {
    // Encode the query to make it URL-safe
    final encodedQuery = Uri.encodeComponent(query);
    // Form the Google search URL
    final url = 'https://www.google.com/search?q=$encodedQuery';

    // Check if the URL can be launched
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cameraProvider = context.watch<CameraProvider>();
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.sizeOf(context).center(const Offset(0, -5)),
      width: 350,
      height: 230,
    );

    return Scaffold(
      backgroundColor: Colors.black,
      // appBar: AppBar(
      //   backgroundColor: const Color(0xff1E1F20),
      //   centerTitle: true,
      //   leading: IconButton(
      //       onPressed: () {
      //         Navigator.pop(context);
      //       },
      //       icon: const Icon(
      //         Icons.arrow_back,
      //         color: Color(0xffffffff),
      //       )),
      //   title: const Text(
      //     'Bar Code Scanner',
      //     style: TextStyle(
      //         fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
      //   ),
      // ),
      body: Stack(
        children: [
          Center(
            child: MobileScanner(
              controller: controller,
              scanWindow: scanWindow,
              onDetect: (capture) async {
                final List<Barcode> barcodes = capture.barcodes;
                if (!activeDialog && barcodes.isNotEmpty) {
                  final barcode =
                      barcodes.first; // Get the first detected barcode
                  LocalStorage().getBool(AppConstant.BEEP_KEY) == true
                      ? player.play(AssetSource('audio/beep_sound.mp3'))
                      : null; // Place the beep file in assets

                  // Trigger vibration
                  LocalStorage().getBool(AppConstant.VIBRATION_KEY) == true
                      ? Vibration.vibrate(duration: 200)
                      : null; // Vibrate for 200 milliseconds

                  if (barcode.rawValue != null) {
                    setState(() {
                      activeDialog = true;
                    });
                    controller.stop(); // Pause the camera
                    // _showQrAndBarCodeDialogue(context, barcode.rawValue!);
                    showQrAndBarCodeDialogue(
                      context: context,
                      title: 'Bar Code Detected',
                      content: barcode.rawValue.toString(),
                      browserView: () {
                        _openBrowserWithSearch(
                          barcode.rawValue.toString(),
                        );
                      },
                      onCopy: () async {
                        Clipboard.setData(ClipboardData(
                          text: barcode.rawValue.toString(),
                        ));
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Copied to Clipboard')));
                        Navigator.pop(context);
                        await _resumeCamera();
                      },
                      onSave: () async {
                        // Add your saving logic here
                        cameraProvider.saveBarCodeText(
                            barcode.rawValue.toString(), context);
                        Navigator.pop(context);
                        await _resumeCamera();
                      },
                      cancle: () async {
                        Navigator.pop(context);
                        await _resumeCamera();
                      },
                    );
                  }
                }
              },
              errorBuilder: (context, error, child) {
                return ScannerErrorWidget(error: error);
              },
            ),
          ),
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, value, child) {
              if (!value.isInitialized ||
                  !value.isRunning ||
                  value.error != null) {
                return const SizedBox();
              }

              return CustomPaint(
                painter: ScannerOverlay(scanWindow: scanWindow),
              );
            },
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Color(0xffffffff),
                      )),
                  ToggleFlashlightButton(controller: controller),
                  // AnalyzeImageFromGalleryButton(controller: controller),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _resumeCamera() async {
    setState(() {
      activeDialog = false;
    });
    await controller.start(); // Resume the camera
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await controller.dispose();
  }
}

class ScannerOverlay extends CustomPainter {
  const ScannerOverlay({
    required this.scanWindow,
    this.borderRadius = 12.0,
  });

  final Rect scanWindow;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    // we need to pass the size to the custom paint widget
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          scanWindow,
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
          bottomLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
      );

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOver;

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final borderRect = RRect.fromRectAndCorners(
      scanWindow,
      topLeft: Radius.circular(borderRadius),
      topRight: Radius.circular(borderRadius),
      bottomLeft: Radius.circular(borderRadius),
      bottomRight: Radius.circular(borderRadius),
    );

    // First, draw the background,
    // with a cutout area that is a bit larger than the scan window.
    // Finally, draw the scan window itself.
    canvas.drawPath(backgroundWithCutout, backgroundPaint);
    canvas.drawRRect(borderRect, borderPaint);
  }

  @override
  bool shouldRepaint(ScannerOverlay oldDelegate) {
    return scanWindow != oldDelegate.scanWindow ||
        borderRadius != oldDelegate.borderRadius;
  }
}
