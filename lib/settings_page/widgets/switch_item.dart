import 'package:doc_scanner/utils/app_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utils/helper.dart';

class SwitchItem extends StatefulWidget {
  final String iconPath;
  final String title;
  final Function(bool) onChanged;
  final bool value;

  const SwitchItem(
      {super.key,
      required this.iconPath,
      required this.title,
      required this.onChanged,
      required this.value});

  @override
  State<SwitchItem> createState() => _SwitchItemState();
}

class _SwitchItemState extends State<SwitchItem> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          widget.iconPath,
          height:AppHelper.isIpad(context)?30: 20,
          width:AppHelper.isIpad(context)?30: 20,
        ),
        SizedBox(
          width: MediaQuery.sizeOf(context).width * 0.015,
        ),
        Text(
          widget.title,
          style:  TextStyle(
            fontWeight: FontWeight.w600,
              fontSize: AppHelper.isIpad(context)?20: 17
          ),
        ),
        const Spacer(),
        SizedBox(
          width: 50, // Adjust width as needed
          height: 30, // Adjust height as needed
          child: Transform.scale(
            scale: 1.2,
            child: CupertinoSwitch(
              value: widget.value,
              onChanged: widget.onChanged,
              activeColor: AppColor.primaryColor,
            ),
          ),
        )
      ],
    );
  }
}
