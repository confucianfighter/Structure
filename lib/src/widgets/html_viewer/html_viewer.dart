import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:url_launcher/url_launcher.dart';

class HTMLViewer extends StatefulWidget {
  final String htmlContent;

  const HTMLViewer({Key? key, required this.htmlContent}) : super(key: key);

  @override
  _HTMLViewerState createState() => _HTMLViewerState();
}

class _HTMLViewerState extends State<HTMLViewer> {
  final WebviewController _controller = WebviewController();
  bool _isWebViewInitialized = false;
  bool _isWebView2Installed = true; // Assume true initially

  @override
  void initState() {
    super.initState();
    _checkWebView2Installation();
  }

  Future<void> _checkWebView2Installation() async {
    try {
      await _controller.initialize();
      setState(() {
        _isWebViewInitialized = true;
      });
      await _controller.loadStringContent(widget.htmlContent);
    } catch (e) {
      // If initialization fails, assume WebView2 Runtime is not installed
      debugPrint('WebView2 Runtime not installed: $e');
      setState(() {
        _isWebView2Installed = false;
      });
    }
  }

  Future<void> _launchWebView2Installer() async {
    const url = 'https://go.microsoft.com/fwlink/p/?LinkId=2124703';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isWebView2Installed) {
      // If WebView2 Runtime is missing
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Microsoft Edge WebView2 Runtime is required to view this content.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _launchWebView2Installer,
              child: Text('Download WebView2 Runtime'),
            ),
          ],
        ),
      );
    }

    // If WebView2 Runtime is installed
    return _isWebViewInitialized
        ? Webview(_controller)
        : Center(child: CircularProgressIndicator());
  }
}
