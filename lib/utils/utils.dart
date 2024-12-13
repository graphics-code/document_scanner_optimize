import 'dart:io';
import 'dart:ui';

import 'package:doc_scanner/localaization/language_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> showQrAndBarCodeDialogue(
    {required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onCopy,
    required VoidCallback onSave,
    required VoidCallback closeTap,
    required VoidCallback browserView}) async {
  String text = content;

  List<String> parts = text.split(';');
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return PopScope(
        canPop: false,
        child: Dialog(
          child: Container(
            height: 250,
            padding: const EdgeInsets.all(18.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xFFD6D9EA),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                      onTap: closeTap,
                      child: const Icon(
                        Icons.cancel,
                        color: Colors.grey,
                      )),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 100,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color(0xFFC5C7D3),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: content.startsWith('https')
                            ? Text(content)
                            : RegExp(r'^[A-Z]').hasMatch(content)
                                ? Text(content)
                                : RegExp(r'^[a-z]').hasMatch(text)
                                    ? Text(content)
                                    : RegExp(r'^[0-9]').hasMatch(text)
                                        ? Text(content)
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: parts
                                                .where((part) => part
                                                    .isNotEmpty) // Remove empty parts
                                                .map((part) {
                                              // Split each part into key and value
                                              List<String> keyValue =
                                                  part.split(':');
                                              String key = keyValue[0];
                                              String value = keyValue.length > 1
                                                  ? keyValue
                                                      .sublist(1)
                                                      .join(':')
                                                  : '';

                                              // Check if the value starts with 'https'
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4.0),
                                                child: Row(
                                                  children: [
                                                    Text(
                                                      key == "WIFI" ||
                                                              key == "Wifi" ||
                                                              key == "wifi"
                                                          ? "WIFI NAME : "
                                                          : key == "T"
                                                              ? "TYPE : "
                                                              : key == "P"
                                                                  ? "PASSWORD : "
                                                                  : "",
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(value),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                          ),
                      ),
                    ),
                    // const SizedBox(
                    //   height: 10,
                    // ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                alignment: Alignment.center,
                                padding: EdgeInsets.zero,
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            onPressed: browserView,
                            icon: const Icon(
                              Icons.language,
                              color: Colors.blueAccent,
                            ),
                            label: const Text(
                              "Open",
                              style: TextStyle(color: Colors.blueAccent),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                alignment: Alignment.center,
                                backgroundColor: Colors.white,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            onPressed: onCopy,
                            icon: const Icon(
                              Icons.copy,
                              color: Colors.blueAccent,
                            ),
                            label: Text(
                              translation(context).copy,
                              style: const TextStyle(color: Colors.blueAccent),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                                alignment: Alignment.center,
                                padding: EdgeInsets.zero,
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            onPressed: onSave,
                            icon: const Icon(
                              Icons.save_alt_outlined,
                              color: Colors.blueAccent,
                            ),
                            label: Text(
                              translation(context).save,
                              style: const TextStyle(color: Colors.blueAccent),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

// Future<void> showQrAndBarCodeViewDialogue(
//     {required BuildContext context, required String text}) async {
//   showDialog(
//     context: context,
//     builder: (context) {
//       return Dialog(
//         alignment: Alignment.center,
//         child: Container(
//             height: 200,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(10),
//               color: Colors.grey.shade200,
//             ),
//             padding: const EdgeInsets.all(15),
//             child: Column(
//               mainAxisSize: MainAxisSize.max,
//               children: [
//                 Row(
//                   mainAxisSize: MainAxisSize.max,
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(""),
//                     Text(
//                       translation(context).content,
//                       style:
//                           TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//                     ),
//                     IconButton(
//                         onPressed: () {
//                           Navigator.pop(context);
//                         },
//                         icon: const Icon(Icons.close))
//                   ],
//                 ),
//                 Expanded(
//                   child: SingleChildScrollView(
//                     scrollDirection: Axis.vertical,
//                     child: Text(
//                       text,
//                       textAlign: TextAlign.start,
//                     ),
//                   ),
//                 ),
//               ],
//             )),
//       );
//     },
//   );
// }

Future<void> showNormalAlertDialogue({
  required BuildContext context,
  required String title,
  required String content,
  required String onOkText,
  required String onCancelText,
  required VoidCallback onOk,
  required VoidCallback onCancel,
}) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: onOk,
            child: Text(translation(context).ok),
          ),
          TextButton(
            onPressed: onCancel,
            child: Text(translation(context).cancel),
          ),
        ],
      );
    },
  );
}

class TopSnackbar extends StatelessWidget {
  final String message;

  const TopSnackbar({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

Future<void> flutterGenralDialogue({
  required BuildContext context,
  required File imageFile,
}) async {
  await showGeneralDialog(
    context: context,
    barrierColor: Colors.black12.withOpacity(0.6),
    barrierDismissible: false,
    barrierLabel: 'Dialog',
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (context, _, __) {
      return SafeArea(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.file(imageFile),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    height: 30,
                    width: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> showQrAndBarCodeViewDialogue(
    {required BuildContext context,
    required String text,
    VoidCallback? browserView}) async {
  String content = text;
  List<String> parts = text.split(';');
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        alignment: Alignment.center,
        child: Container(
            height: text.startsWith('https') ? 250 : 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.shade200,
            ),
            padding:
                const EdgeInsets.only(left: 25, right: 25, top: 15, bottom: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Content",
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.normal),
                    ),
                    GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.close))
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  width: double.infinity,
                  height: 110,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFFC5C7D3),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: text.startsWith('https')
                        ? Text(text)
                        : RegExp(r'^[A-Z]').hasMatch(content)
                            ? Text(content)
                            : RegExp(r'^[a-z]').hasMatch(text)
                                ? Text(content)
                                : RegExp(r'^[0-9]').hasMatch(text)
                                    ? Text(content)
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: parts
                                            .where((part) => part
                                                .isNotEmpty) // Remove empty parts
                                            .map((part) {
                                          // Split each part into key and value
                                          List<String> keyValue =
                                              part.split(':');
                                          String key = keyValue[0];
                                          String value = keyValue.length > 1
                                              ? keyValue.sublist(1).join(':')
                                              : '';

                                          // Check if the value starts with 'https'
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 4.0),
                                            child: Row(
                                              children: [
                                                Text(
                                                  key == "WIFI" ||
                                                          key == "Wifi" ||
                                                          key == "wifi"
                                                      ? "WIFI NAME : "
                                                      : key == "T"
                                                          ? "TYPE : "
                                                          : key == "P"
                                                              ? "PASSWORD : "
                                                              : "",
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(value),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            alignment: Alignment.center,
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.white,
                            minimumSize: const Size(90, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                        onPressed: () async {
                          Clipboard.setData(ClipboardData(text: text));
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  translation(context).copiedToClipboard)));
                        },
                        icon: const Icon(
                          Icons.copy,
                          color: Colors.blueAccent,
                        ),
                        label: Text(
                          translation(context).copy,
                          style: const TextStyle(color: Colors.blueAccent),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 50,
                    ),
                    Expanded(
                        child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          alignment: Alignment.center,
                          padding: EdgeInsets.zero,
                          backgroundColor: Colors.white,
                          minimumSize: const Size(90, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      onPressed: browserView,
                      icon: const Icon(
                        Icons.language,
                        color: Colors.blueAccent,
                      ),
                      label: const Text(
                        "Open",
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ))
                  ],
                )
              ],
            )),
      );
    },
  );
}
