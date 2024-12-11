import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class HTMLViewer extends StatefulWidget {
  final String htmlContent;
  final String _cssPath;
  const HTMLViewer({Key? key, required this.htmlContent, required String style})
      : _cssPath = style,
        super(key: key);

  @override
  _HTMLViewerState createState() => _HTMLViewerState();
}

class _HTMLViewerState extends State<HTMLViewer> {
  final WebviewController _controller = WebviewController();
  bool _isWebViewInitialized = false;
  bool _isWebView2Installed = true;

  @override
  void initState() {
    super.initState();
    _checkWebView2Installation();
  }

  Future<String> loadCssContent(String assetPath) async {
    try {
      return await rootBundle.loadString(assetPath);
    } catch (e) {
      print("Error loading CSS file: $e");
      return ""; // Return empty string if the asset cannot be loaded
    }
  }

  Future<void> _checkWebView2Installation() async {
    try {
      await _controller.initialize();
      setState(() {
        _isWebViewInitialized = true;
      });
      _updateWebView(widget.htmlContent, widget._cssPath!);
    } catch (e) {
      // If initialization fails, assume WebView2 Runtime is not installed
      debugPrint('WebView2 Runtime not installed: $e');
      setState(() {
        _isWebView2Installed = false;
      });
    }
  }

  @override
  void didUpdateWidget(covariant HTMLViewer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If HTML content has changed, update
    if (widget.htmlContent != oldWidget.htmlContent) {
      _updateWebView(widget.htmlContent, widget._cssPath!);
    }

    // If the CSS path changed, re-load and update
    if (widget._cssPath != oldWidget._cssPath) {
      _updateWebView(widget.htmlContent, widget._cssPath!);
    }
  }

  Future<void> _updateWebView(String htmlContent, String cssAssetPath) async {
    // load the CSS content
    var _cssContent = await loadCssContent(cssAssetPath);
    if (_isWebViewInitialized) {
      final script = '''
      document.open();
      document.write(`<!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            ${_cssContent} <!-- Inject the CSS content -->
          </style>
          <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.8.0/styles/monokai-sublime.min.css">
          <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.8.0/highlight.min.js"></script>
          <script>
            document.addEventListener("DOMContentLoaded", () => {
              // Replace <x> with <pre><code>
              document.querySelectorAll('x').forEach(customTag => {
                const codeContent = customTag.innerHTML.trim(); // Get content
                const pre = document.createElement('pre');       // Create <pre>
                const code = document.createElement('code');     // Create <code>
                code.innerHTML = codeContent;                    // Set content
                pre.appendChild(code);                           // Wrap in <pre>
                customTag.replaceWith(pre);                      // Replace <x>
              });

              // Highlight code blocks after replacements
              hljs.highlightAll();
            });
          </script>
        </head>
        <body>
          ${htmlContent} <!-- Your user content -->
        </body>
        </html>
      `);
      document.close();
    ''';

      await _controller.executeScript(script);
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
        ? LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: Webview(_controller),
              );
            },
          )
        : Center(child: CircularProgressIndicator());
  }
}
