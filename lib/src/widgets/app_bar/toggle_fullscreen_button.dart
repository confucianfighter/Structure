import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class ToggleFullScreenButton extends StatefulWidget {
  const ToggleFullScreenButton({Key? key}) : super(key: key);

  @override
  _ToggleFullScreenButtonState createState() => _ToggleFullScreenButtonState();
}

class _ToggleFullScreenButtonState extends State<ToggleFullScreenButton> with WindowListener {
  bool isFullScreen = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _getFullScreenStatus();
  }

  Future<void> _getFullScreenStatus() async {
    bool fullScreen = await windowManager.isFullScreen();
    setState(() {
      isFullScreen = fullScreen;
    });
  }

  Future<void> _toggleFullScreen() async {
    if (isFullScreen) {
      await windowManager.setFullScreen(false);
    } else {
      await windowManager.setFullScreen(true);
    }
    _getFullScreenStatus();
  }

  @override
  void onWindowEnterFullScreen() {
    setState(() {
      isFullScreen = true;
    });
  }

  @override
  void onWindowLeaveFullScreen() {
    setState(() {
      isFullScreen = false;
    });
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
      onPressed: _toggleFullScreen,
    );
  }
}
