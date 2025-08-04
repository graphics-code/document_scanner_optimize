// import 'dart:developer';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import 'package:internet_connection_checker/internet_connection_checker.dart';
// import 'package:pdf_converter/features/localization/model/language.dart';
// import 'package:pdf_converter/features/settings/view/web_screen.dart';
// import 'package:pdf_converter/features/settings/widgets/switch_item.dart';
// import 'package:pdf_converter/utils/app_helper.dart';
// import 'package:provider/provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../../../main.dart';
// import '../../../utils/app_assets.dart';
// import '../../../utils/app_color.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
//
// import '../../../utils/global_variable.dart';
// import '../language/utils/constrant.dart';
// import '../language/utils/string.dart';
// import '../provider/setting_provider.dart';
// import '../widgets/app_storage.dart';
// import 'language_setting.dart';
//
// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({super.key});
//
//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }
//
// class _SettingsScreenState extends State<SettingsScreen> {
//   bool batchScan = false;
//   bool vibration = false;
//   bool beep = false;
//   bool history = false;
//   String selectedLanguage = 'English (US)';
//   AppStorageService appStorage = AppStorageService();
//   Color _bgColor = Colors.transparent;
//   Color _historyColor = Colors.transparent;
//   Color _rateColor = Colors.transparent;
//   Color _privacyPolicyColor = Colors.transparent;
//   Color _termConditonColor = Colors.transparent;
//
//   void _handleShareTap() async {
//     setState(() {
//       _bgColor = Colors.red.withOpacity(0.2);
//     });
//
//     await Future.delayed(const Duration(milliseconds: 200));
//
//     setState(() {
//       _bgColor = Colors.transparent;
//     });
//     final box = context.findRenderObject() as RenderBox?;
//     if (box != null) {
//       final position = box.localToGlobal(Offset.zero) & box.size;
//       Share.shareUri(Uri.parse('https://apps.apple.com/app/id6472611450'),
//           sharePositionOrigin: position);
//     } else {
//       Share.shareUri(Uri.parse('https://apps.apple.com/app/id6472611450'));
//     }
//   }
//
//   void _handleHistoryTap() async {
//     setState(() {
//       _historyColor = Colors.red.withOpacity(0.2);
//     });
//
//     await Future.delayed(Duration(milliseconds: 200));
//
//     setState(() {
//       _historyColor = Colors.transparent;
//     });
//     // Share.shareUri(Uri.parse('https://play.google.com/store/apps/details?id=com.qr.code.reader.qrscan.barcode.scanner'));
//   }
//
//   void launchStore() async {
//     final Uri toLaunch = Platform.isAndroid
//         ? Uri(
//       scheme: 'https',
//       host: 'play.google.com',
//       path: '/store/apps/details',
//       queryParameters: {
//         'id': 'com.pdfconverter.jpgtopdf.imagetopdf.pdfmaker'
//       },
//     )
//         : Uri.parse('https://apps.apple.com/app/id6472611450');
//
//     if (await canLaunchUrl(toLaunch)) {
//       await launchUrl(toLaunch, mode: LaunchMode.externalApplication);
//     } else {
//       throw 'Could not launch $toLaunch';
//     }
//   }
//
//   void _handleRateTap() async {
//     setState(() {
//       _rateColor = Colors.red.withOpacity(0.2);
//     });
//
//     await Future.delayed(Duration(milliseconds: 200));
//
//     setState(() {
//       _rateColor = Colors.transparent;
//     });
//     launchStore();
//   }
//
//   void _handlePrivacyPolicyTap() async {
//     setState(() {
//       _privacyPolicyColor = Colors.red.withOpacity(0.2);
//     });
//
//     await Future.delayed(Duration(milliseconds: 200));
//
//     setState(() {
//       _privacyPolicyColor = Colors.transparent;
//     });
//     Navigator.of(context).push(MaterialPageRoute(
//         builder: (context) => WebViewPages(
//           appBarTitleName: "Privacy Policy",
//           url: "https://sites.google.com/view/pdf-converter-scanner-maker",
//         )));
//   }
//
//   void _handleTermConditionTap() async {
//     setState(() {
//       _termConditonColor = Colors.red.withOpacity(0.2);
//     });
//
//     await Future.delayed(Duration(milliseconds: 200));
//
//     setState(() {
//       _termConditonColor = Colors.transparent;
//     });
//     // Share.shareUri(Uri.parse('https://play.google.com/store/apps/details?id=com.qr.code.reader.qrscan.barcode.scanner'));
//
//     Navigator.of(context).push(MaterialPageRoute(
//         builder: (context) => WebViewPages(
//           appBarTitleName: 'Terms & Conditions'.tr,
//           url: "https://sites.google.com/view/pdfconverter-photo-to-pdf",
//         )));
//   }
//
//   bool isIpad(BuildContext context) {
//     final width = MediaQuery.of(context).size.shortestSide;
//     return width >= 768;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final settingScreenProvider = Provider.of<SettingsProvider>(context);
//     final size = MediaQuery.of(context).size;
//     return Scaffold(
//       backgroundColor: Color(0xffF8F8F8),
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         elevation: 0.4,
//         shadowColor: Colors.grey.withOpacity(0.3),
//         title: Text(
//           AppLocalizations.of(context)!.settings,
//           style: TextStyle(
//             fontSize: isIpad(context) ? 30 : 20,
//             fontWeight: FontWeight.w500,
//             color: Colors.black, // Title text color
//           ),
//         ),
//         iconTheme: const IconThemeData(
//             color: Colors.black), // Optional: make back button black
//       ),
//       body: SingleChildScrollView(
//         scrollDirection: Axis.vertical,
//         child: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const SizedBox(height: 15),
//               Container(
//                 width: MediaQuery.sizeOf(context).width,
//                 padding:
//                 const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
//                 decoration: BoxDecoration(
//                   color: Color(0xffFFFFFF),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Column(
//                   children: [
//                     Builder(
//                       builder: (context) => GestureDetector(
//                         onTap: () async {
//                           setState(() {
//                             _bgColor = Colors.red.withOpacity(0.2);
//                           });
//
//                           await Future.delayed(
//                               const Duration(milliseconds: 200));
//
//                           setState(() {
//                             _bgColor = Colors.transparent;
//                           });
//
//                           final box = context.findRenderObject() as RenderBox?;
//                           if (box != null) {
//                             final position =
//                             box.localToGlobal(Offset.zero) & box.size;
//                             Share.shareUri(
//                                 Uri.parse(
//                                     'https://apps.apple.com/app/id6472611450'),
//                                 sharePositionOrigin: position);
//                           } else {
//                             Share.shareUri(Uri.parse(
//                                 'https://apps.apple.com/app/id6472611450'));
//                           }
//                         },
//                         child: AnimatedContainer(
//                           duration: const Duration(milliseconds: 200),
//                           padding: const EdgeInsets.symmetric(
//                               vertical: 10, horizontal: 8),
//                           decoration: BoxDecoration(
//                             color: _bgColor,
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Row(
//                             children: [
//                               SvgPicture.asset(AppAssets.share_with_friend,
//                                   height: isIpad(context) ? 30 : 24,
//                                   width: isIpad(context) ? 30 : 24),
//                               const SizedBox(width: 12),
//                               Text(
//                                 'Share with Friends'.tr,
//                                 style: GlobalVariable.style(
//                                   isIpad(context) ? 20 : 16,
//                                   fontWeight: FontWeight.w600,
//                                   color: const Color(0xff373737),
//                                 ),
//                               ),
//                               const Spacer(),
//                               SvgPicture.asset("assets/svg/right.svg"),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     // GestureDetector(
//                     //   onTap: _handleShareTap,
//                     //   child: AnimatedContainer(
//                     //     duration: const Duration(milliseconds: 200),
//                     //     padding: const EdgeInsets.symmetric(
//                     //         vertical: 10, horizontal: 8),
//                     //     decoration: BoxDecoration(
//                     //       color: _bgColor,
//                     //       borderRadius: BorderRadius.circular(8),
//                     //     ),
//                     //     child: Row(
//                     //       children: [
//                     //         SvgPicture.asset(
//                     //           AppAssets.share_with_friend,
//                     //           height: isIpad(context) ? 30 : 24,
//                     //           width: isIpad(context) ? 30 : 24,
//                     //         ),
//                     //         SizedBox(width: 12),
//                     //         Text(
//                     //           'Share with Friends'.tr,
//                     //           style: GlobalVariable.style(
//                     //               isIpad(context) ? 20 : 16,
//                     //               fontWeight: FontWeight.w600,
//                     //               color: Color(0xff373737)),
//                     //         ),
//                     //         Spacer(),
//                     //         SvgPicture.asset("assets/svg/right.svg")
//                     //       ],
//                     //     ),
//                     //   ),
//                     // ),
//                     const SizedBox(height: 20),
//                     InkWell(
//                       onTap: () async {
//                         try {
//                           if (Platform.isAndroid || Platform.isIOS) {
//                             final appId = Platform.isAndroid
//                                 ? 'com.qr.code.reader.qrscan.barcode.scanner'
//                                 : '6471344894';
//                             final url = Uri.parse(
//                               Platform.isAndroid
//                                   ? "https://play.google.com/store/apps/details?id=$appId"
//                                   : "https://apps.apple.com/app/id$appId",
//                             );
//                             await launchUrl(
//                               url,
//                               mode: LaunchMode.externalApplication,
//                             );
//                           }
//                         } catch (e) {
//                           log(e.toString());
//                         }
//                       },
//                       child: GestureDetector(
//                         onTap: () async {
//                           bool hasInternet =
//                           await InternetConnectionChecker().hasConnection;
//                           // print("internet connection checker $hasInternet");
//
//                           if (hasInternet) {
//                             _handleRateTap();
//                           } else {
//                             AppHelper.showTopSnackBar(
//                                 context, "No Internet Conneciton");
//                           }
//                         },
//                         child: AnimatedContainer(
//                           duration: const Duration(milliseconds: 200),
//                           padding: const EdgeInsets.symmetric(
//                               vertical: 10, horizontal: 8),
//                           decoration: BoxDecoration(
//                             color: _rateColor,
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Row(
//                             children: [
//                               SvgPicture.asset(
//                                 AppAssets.rate_us,
//                                 width: isIpad(context) ? 30 : 24,
//                                 height: isIpad(context) ? 30 : 24,
//                               ),
//                               SizedBox(width: 12),
//                               Text(
//                                 'Rate Us'.tr,
//                                 style: GlobalVariable.style(
//                                     isIpad(context) ? 20 : 16,
//                                     fontWeight: FontWeight.w600,
//                                     color: Color(0xff373737)),
//                               ),
//                               Spacer(),
//                               SvgPicture.asset("assets/svg/right.svg")
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 15),
//               Container(
//                 width: MediaQuery.sizeOf(context).width,
//                 padding:
//                 const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
//                 decoration: BoxDecoration(
//                   color: Color(0xffFFFFFF),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Column(
//                   children: [
//                     InkWell(
//                       onTap: () async {
//                         bool hasInternetConnection =
//                         await InternetConnectionChecker().hasConnection;
//
//                         if (hasInternetConnection) {
//                           _handlePrivacyPolicyTap();
//                         } else {
//                           AppHelper.showTopSnackBar(
//                               context, "No Internet Connection");
//                         }
//                       },
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 200),
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 10, horizontal: 8),
//                         decoration: BoxDecoration(
//                           color: _privacyPolicyColor,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Row(
//                           children: [
//                             SvgPicture.asset(
//                               AppAssets.privacy_policy,
//                               width: isIpad(context) ? 30 : 24,
//                               height: isIpad(context) ? 30 : 24,
//                             ),
//                             SizedBox(width: 12),
//                             Text(
//                               'Privacy Policy'.tr,
//                               style: GlobalVariable.style(
//                                   isIpad(context) ? 20 : 16,
//                                   fontWeight: FontWeight.w600,
//                                   color: Color(0xff373737)),
//                             ),
//                             Spacer(),
//                             SvgPicture.asset("assets/svg/right.svg")
//                           ],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     GestureDetector(
//                       onTap: () async {
//                         bool connection =
//                         await InternetConnectionChecker().hasConnection;
//                         if (connection) {
//                           _handleTermConditionTap();
//                         } else {
//                           AppHelper.showTopSnackBar(
//                               context, "No Internet Connection");
//                         }
//                       },
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 200),
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 10, horizontal: 8),
//                         decoration: BoxDecoration(
//                           color: _termConditonColor,
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Row(
//                           children: [
//                             SvgPicture.asset(
//                               AppAssets.term_condition,
//                               width: isIpad(context) ? 30 : 24,
//                               height: isIpad(context) ? 30 : 24,
//                             ),
//                             SizedBox(width: 12),
//                             Text(
//                               'Terms & Conditions'.tr,
//                               style: GlobalVariable.style(
//                                   isIpad(context) ? 20 : 16,
//                                   fontWeight: FontWeight.w600,
//                                   color: Color(0xff373737)),
//                             ),
//                             Spacer(),
//                             SvgPicture.asset("assets/svg/right.svg")
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   GestureDetector buildLanguageButton(
//       SettingsProvider settingScreenProvider, Size size) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => const LanguageSelectionScreenView(),
//           ),
//         );
//       },
//       child: Container(
//         decoration: BoxDecoration(
//             color: Color(0xffffffff), borderRadius: BorderRadius.circular(6)),
//         // padding: EdgeInsets.all(size.width*(10/240)),
//         height: 56,
//
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               children: [
//                 SizedBox(
//                   width: 8,
//                 ),
//                 SvgPicture.asset(AppAssets.language_icon),
//                 SizedBox(
//                   width: 12,
//                 ),
//                 Text(
//                   Strings.languagesLabel.tr,
//                   overflow: TextOverflow.ellipsis,
//                   style: GlobalVariable.style(16,
//                       fontWeight: FontWeight.w600, color: Color(0xff373737)),
//                 )
//               ],
//             ),
//             Row(
//               children: [
//                 Text(
//                   languagesList[languagesList.indexWhere((element) =>
//                   element['locale'] == appStorage.getLocale)]['name'],
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     color: AppColor.darkTextColor,
//                     fontWeight: FontWeight.w400,
//                     fontSize: size.width * (14 / 375),
//                   ),
//                 ),
//                 SizedBox(
//                   width: size.width * (5 / 375),
//                 ),
//                 SvgPicture.asset("assets/svg/right.svg"),
//                 SizedBox(
//                   width: 9,
//                 )
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }