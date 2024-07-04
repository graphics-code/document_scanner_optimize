import 'dart:typed_data';
import 'package:doc_scanner/image_edit/provider/image_edit_provider.dart';
import 'package:doc_scanner/localaization/language_constant.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:image_editor/image_editor.dart';
import 'package:provider/provider.dart';
import '../camera_screen/model/image_model.dart';
import '../camera_screen/provider/camera_provider.dart';
import '../utils/app_color.dart';

class ImageRotation extends StatefulWidget {
  final ImageModel imageModel;
  final int index;
  final bool? cameFromEdit;

  const ImageRotation(
      {super.key,
      required this.imageModel,
      required this.index,
      this.cameFromEdit});

  @override
  State<ImageRotation> createState() => _ImageRotationState();
}

class _ImageRotationState extends State<ImageRotation> {
  final GlobalKey<ExtendedImageEditorState> editorKey =
      GlobalKey<ExtendedImageEditorState>();

  @override
  Widget build(BuildContext context) {
    final cameraProvider = context.watch<CameraProvider>();
    final imageEditProvider = context.watch<ImageEditProvider>();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.imageModel.name,
          style: const TextStyle(fontSize: 20,fontWeight: FontWeight.w500,color: Colors.black),
        ),
        actions: [
          TextButton(
              onPressed: () async {
                var state = editorKey.currentState;
                if (state == null) {
                  Navigator.pop(context);
                } else {
                  final Uint8List img = state.rawImageData;
                  final EditActionDetails action = state.editAction!;
                  final int rotateAngle = action.rotateAngle.toInt();
                  final ImageEditorOption option = ImageEditorOption();
                  option.addOption(RotateOption(rotateAngle));
                  final Uint8List? result = await ImageEditor.editImage(
                    image: img,
                    imageEditorOption: option,
                  );
                  if (widget.cameFromEdit == true) {

                    imageEditProvider.addState(result!);

                  }else{

                    cameraProvider.updateImage(
                      index: widget.index,
                      image: ImageModel(
                        imageByte: result!,
                        name: widget.imageModel.name,
                        docType: widget.imageModel.docType,
                      ),
                    );
                  }
                  Navigator.pop(context);
                }
              },
              child:  Text(
                translation(context).done,style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColor.primaryColor,
              ),
              ))
        ],
      ),
      body: Center(
        child: ExtendedImage.memory(
          cacheRawData: true,
          extendedImageEditorKey: editorKey,
          widget.cameFromEdit==true?imageEditProvider.currentState:  widget.imageModel.imageByte,
          mode: ExtendedImageMode.editor,
          fit: BoxFit.contain,
          initEditorConfigHandler: (state) {
            return EditorConfig(
              cornerColor: AppColor.primaryColor,
            );
          },

        ),
      ),
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
              children: [
                IconButton(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  icon: const Icon(Icons.rotate_left),
                  onPressed: () {
                    editorKey.currentState!.rotate(right: false);
                  },
                ),
                 Text(translation(context).rotateLeft)
              ],
            ),
            Column(
              children: [
                IconButton(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  icon: const Icon(Icons.rotate_right),
                  onPressed: () {
                    editorKey.currentState!.rotate(right: true);
                  },
                ),
                 Text(translation(context).rotateRight)
              ],
            ),
          ],
        ),
      ),
    );
  }
}
