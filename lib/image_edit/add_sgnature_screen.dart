import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'package:doc_scanner/camera_screen/model/image_model.dart';
import 'package:doc_scanner/image_edit/widget/image_edit_button.dart';
import 'package:doc_scanner/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:interactive_box/interactive_box.dart';
import 'package:mime/mime.dart';
import 'package:provider/provider.dart';

import '../camera_screen/provider/camera_provider.dart';
import '../localaization/language_constant.dart';
import '../utils/app_assets.dart';
import '../utils/no_internet_connection.dart';
import 'drawing.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';



class AddSignature extends StatefulWidget {
  final ImageModel imageModel;
  final int imageIndex;

  const AddSignature({
    super.key,
    required this.imageModel,
    required this.imageIndex,
  });

  @override
  State<AddSignature> createState() => _AddSignatureState();
}

class _AddSignatureState extends State<AddSignature> {
  String? signaturePath;
  bool drawSignature = false;
  final GlobalKey _globalKey = GlobalKey();
  bool initialShowActionIcons = true;

  @override
  Widget build(BuildContext context) {
    final cameraProvider = context.watch<CameraProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFF131314),
      appBar: AppBar(
        backgroundColor: const Color(0xff1E1F20),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xffffffff),
            )),
        title: Text(
          translation(context).addSignature,
          style: const TextStyle(
              fontWeight: FontWeight.w500, fontSize: 20, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                initialShowActionIcons = false;
              });

              Future.delayed(const Duration(milliseconds: 500), () async {
                var image = await captureImage();
                if (image != null) {
                  cameraProvider.updateImage(
                      image: ImageModel(
                          imageByte: image,
                          name: widget.imageModel.name,
                          docType: widget.imageModel.docType),
                      index: widget.imageIndex);
                  Navigator.pop(context);
                }
              });
            },
            child: Text(
              translation(context).done,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColor.primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: RepaintBoundary(
          key: _globalKey,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: Image.memory(
                  widget.imageModel.imageByte,
                  fit: BoxFit.cover,
                ),
              ),
              if (signaturePath != null)
                InteractiveBox(
                  initialPosition: const Offset(50, 200),
                  includedScaleDirections: const [
                    ScaleDirection.topRight,
                    ScaleDirection.bottomRight,
                    ScaleDirection.bottomLeft,
                    ScaleDirection.topLeft,
                  ],
                  initialSize: const Size(250, 150),
                  includedActions: const [
                    ControlActionType.move,
                    ControlActionType.scale,
                    ControlActionType.rotate,
                    ControlActionType.delete,
                  ],
                  onActionSelected: (ControlActionType controlActionType,
                      InteractiveBoxInfo interactiveBoxInfo) {
                    if (controlActionType == ControlActionType.delete) {
                      setState(() {
                        signaturePath = null;
                      });
                    }
                  },
                  initialShowActionIcons: initialShowActionIcons,
                  rotateIndicatorSpacing: 10,
                  child: drawSignature == true
                      ? SvgPicture.string(signaturePath!, fit: BoxFit.cover)
                      : Image.memory(
                          Uint8List.fromList(signaturePath!.codeUnits),
                          fit: BoxFit.cover,
                        ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: const Color(0xff1E1F20),
        height: Platform.isIOS ? 85 : 70,
        padding: const EdgeInsets.only(left: 10.0, bottom: 12.0, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ImageEditButton(
              title: translation(context).draw,
              onTap: () async {
                var signature = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DrawingScreen(),
                  ),
                );
                if (signature != null) {
                  setState(() {
                    signaturePath = signature;
                    drawSignature = true;
                  });
                }
              },
              iconPath: AppAssets.sign,
            ),
            ImageEditButton(
              title: translation(context).gallery,
              onTap: () async {
                await importFromGallery();
                drawSignature = false;
              },
              iconPath:
                  AppAssets.gallery, // Replace with your desired gallery icon
            ),
          ],
        ),
      ),
    );
  }

  Future<Uint8List?> captureImage() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      log(boundary.size.toString());
      double pixelRatio = MediaQuery.of(context).devicePixelRatio;
      ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      return byteData!.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }


  Future<Uint8List> removeImageBackground({
    required BuildContext context,
    required File imageFile,
  }) async {
    final progressNotifier = ValueNotifier<double>(0);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Processing Image'),
        content: ValueListenableBuilder<double>(
          valueListenable: progressNotifier,
          builder: (context, progress, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(value: progress),
                const SizedBox(height: 12),
                Text('${(progress * 100).toStringAsFixed(0)}% completed'),
              ],
            );
          },
        ),
      ),
    );

    try {
      final uri = Uri.parse('https://removebackground-036fcb96c69b.herokuapp.com/remove-background');
      final request = http.MultipartRequest('POST', uri);

      final mimeType = lookupMimeType(imageFile.path) ?? 'image/png';
      final fileLength = await imageFile.length();
      final fileStream = imageFile.openRead();

      int bytesSent = 0;
      final streamWithProgress = fileStream.transform<List<int>>(
        StreamTransformer.fromHandlers(
          handleData: (data, sink) {
            bytesSent += data.length;
            progressNotifier.value = bytesSent / fileLength * 0.5;
            sink.add(data);
          },
        ),
      );

      final multipartFile = http.MultipartFile(
        'image',
        streamWithProgress,
        fileLength,
        filename: imageFile.path.split('/').last,
        contentType: MediaType.parse(mimeType),
      );

      request.files.add(multipartFile);

      final streamedResponse = await request.send();

      if (streamedResponse.statusCode == 200) {
        final contentLength = streamedResponse.contentLength ?? 0;
        List<int> bytes = [];
        int downloaded = 0;

        await for (var chunk in streamedResponse.stream) {
          bytes.addAll(chunk);
          downloaded += chunk.length;
          if (contentLength > 0) {
            progressNotifier.value = 0.5 + (downloaded / contentLength) * 0.5;
          }
        }

        Navigator.of(context).pop();
        return Uint8List.fromList(bytes);
      } else {
        // Try to read error message from response body
        final responseBody = await streamedResponse.stream.bytesToString();
        String errorMessage = 'Failed: ${streamedResponse.reasonPhrase}';

        try {
          final jsonError = jsonDecode(responseBody);
          if (jsonError is Map && jsonError['error'] is String) {
            errorMessage = 'Failed: ${jsonError['error']}';
          }
        } catch (_) {
          // Ignore JSON parse errors, fallback to status reason
        }

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
        throw Exception(errorMessage);
      }
    } catch (e, stackTrace) {
      Navigator.of(context).pop();
      debugPrint('Error during background removal: $e');
      debugPrintStack(stackTrace: stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      rethrow;
    }
  }



  Future<void> importFromGallery() async {
    final hasInternet =
    await InternetConnectionChecker().hasConnection;

    if (!hasInternet) {
      NoInternetOverlay.show(context);
      return;
    }





    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await removeImageBackground(context: context, imageFile: File(pickedFile.path));


      await pickedFile.readAsBytes();
      setState(() {
        signaturePath = null;
      });


      setState(() {
        signaturePath =
            String.fromCharCodes(bytes);
      });
    }
  }
}
