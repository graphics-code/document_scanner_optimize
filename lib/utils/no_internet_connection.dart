import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class NoInternetOverlay {
  static OverlayEntry? _currentOverlay;

  static show(BuildContext context) {
    if (_currentOverlay != null) return;

    final overlay = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: _NoInternetBanner(
            onClose: () {
              _currentOverlay?.remove();
              _currentOverlay = null;
            },
          ),
        ),
      ),
    );

    Overlay.of(context, rootOverlay: true)?.insert(overlay);
    _currentOverlay = overlay;
  }
}

class _NoInternetBanner extends StatefulWidget {
  final VoidCallback onClose;

  const _NoInternetBanner({Key? key, required this.onClose}) : super(key: key);

  @override
  State<_NoInternetBanner> createState() => _NoInternetBannerState();
}

class _NoInternetBannerState extends State<_NoInternetBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);
    Future.delayed(const Duration(seconds: 3), widget.onClose);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            height: 50,
            width: 50,
            child: Lottie.asset(
              'assets/png/nointernet.json',
              controller: _controller,
              onLoaded: (composition) {
                _controller
                  ..duration = composition.duration
                  ..repeat();
              },
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'No Internet Connection',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}