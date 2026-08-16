import 'package:flutter/material.dart';
import 'package:upgrader/upgrader.dart';

/// Force update dialog on Home (BottomBar).
/// Shown when App Store / Play Store has a newer version.
/// Ignore / Later are hidden — user must update.
class ForceUpdateWrapper extends StatelessWidget {
  const ForceUpdateWrapper({super.key, required this.child});

  final Widget child;

  static final Upgrader _upgrader = Upgrader(
    durationUntilAlertAgain: Duration.zero,
  );

  @override
  Widget build(BuildContext context) {
    return UpgradeAlert(
      upgrader: _upgrader,
      showIgnore: false,
      showLater: false,
      barrierDismissible: false,
      shouldPopScope: () => false,
      dialogStyle: UpgradeDialogStyle.material,
      child: child,
    );
  }
}
