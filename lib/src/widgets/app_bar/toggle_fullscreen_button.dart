import 'package:flutter/material.dart';
import 'package:Structure/src/utils/WindowControl.dart';
class ToggleFullScreenButton extends StatefulWidget {
  const ToggleFullScreenButton({super.key});

  @override
  _ToggleFullScreenButtonState createState() => _ToggleFullScreenButtonState();
}

class _ToggleFullScreenButtonState extends State<ToggleFullScreenButton>  {
  bool isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _getFullScreenStatus();
  }

  Future<bool> _getFullScreenStatus() async {
    bool fullScreen = await WindowControl().isFullScreen();
    setState(() {
      isFullScreen = fullScreen;
    });
    return fullScreen;
  }

  Future<void> _toggleFullScreen() async {
    if (!isFullScreen) {
      await WindowControl().setFullscreen();
    } else {
      await WindowControl().exitFullscreen();
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
