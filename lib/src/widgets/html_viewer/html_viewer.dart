import 'package:Structure/src/widgets/code_editor/code_editor.dart';
import 'package:flutter/material.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:Structure/src/widgets/log/log_manager.dart';

class HTMLViewer extends StatefulWidget {
  final String initialText;
  final String _cssPath;
  final String _highlightJsCssPath;
  final Function(String)? onLanguageChanged;
  final Function(String)? onChanged;
  final bool showEditButton;
  final String language;

  const HTMLViewer({
    super.key,
    required this.initialText,
    required String cssPath,
    required String highlightJsCssPath,
    required this.onLanguageChanged,
    required this.onChanged,
    required this.showEditButton,
    required this.language,
  })  : _cssPath = cssPath,
        _highlightJsCssPath = highlightJsCssPath;

  @override
  _HTMLViewerState createState() => _HTMLViewerState();
}

class _HTMLViewerState extends State<HTMLViewer> with WidgetsBindingObserver {
  final WebviewController _controller = WebviewController();

  bool _isWebViewInitialized = false;
  bool _isWebView2Installed = true;

  @override
  void initState() {
    log("HTMLViewer initState");
    super.initState();
    _checkWebView2Installation();
    //WidgetsBinding.instance?.addObserver(this);
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

      // Handle window close event
      //onWindowClose();

      setState(() {
        _isWebViewInitialized = true;
      });
      _updateWebView(widget.initialText, widget._cssPath);
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
    if (widget.initialText != oldWidget.initialText) {
      _updateWebView(widget.initialText, widget._cssPath);
    }

    // If the CSS path changed, re-load and update
    if (widget._cssPath != oldWidget._cssPath) {
      _updateWebView(widget.initialText, widget._cssPath);
    }
    if (widget._highlightJsCssPath != oldWidget._highlightJsCssPath) {
      _updateWebView(widget.initialText, widget._cssPath);
    }
  }

  Future<void> _updateWebView(String htmlContent, String cssAssetPath) async {
    // Load the CSS content
    var cssContent = await loadCssContent(cssAssetPath); // Your main CSS
    var highlightJsCssContent = await loadCssContent(
        widget._highlightJsCssPath); // Highlight.js theme CSS
    var customJs = await rootBundle
        .loadString('assets/js/youtube_player.js'); // Load the custom.js file
    // throw an error if string is empty
    if (cssContent.isEmpty) {
      throw Exception('CSS content is empty');
    }
    if (_isWebViewInitialized) {
      final script = '''
document.open();
document.write(`<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    /* Injected custom CSS content */
    

    /* Injected Highlight.js theme CSS */
    $highlightJsCssContent
    $cssContent
  </style>

  <script>
    // Define globals before DOMContentLoaded
    window.players = [];
    window.stopAllVideos = function() {
      if (!Array.isArray(window.players) || window.players.length === 0) {
        console.error("No players available to stop.");
        return;
      }
      for (var i = 0; i < window.players.length; i++) {
        var player = window.players[i];
        try {
          player.stopVideo();
        } catch (err) {
          console.error("Error stopping video player " + i + ": " + err);
        }
      }
    };

    window.onYouTubeIframeAPIReady = function() {
      var ytTags = document.querySelectorAll("youtube");
      if (ytTags.length === 0) {
        console.error("No <youtube> tags found in the document.");
        return;
      }

      for (var index = 0; index < ytTags.length; index++) {
        var ytTag = ytTags[index];
        var videoId = ytTag.getAttribute("video-id");
        if (!videoId) {
          console.error("No video ID provided for <youtube> at index " + index + ".");
          var errorMsg = document.createElement("p");
          errorMsg.textContent = "Error: No video ID provided at index " + index + ".";
          errorMsg.style.color = "red";
          ytTag.replaceWith(errorMsg);
          continue;
        }

        var playerId = "youtube-player-" + index;
        var div = document.createElement("div");
        div.id = playerId;
        ytTag.replaceWith(div);

// Function to log errors by inserting <p> elements into the page
function logError(message) {
  const errorElement = document.createElement("p");
  errorElement.textContent = "Error: " + message;
  errorElement.style.color = "red"; // Make errors stand out
  document.body.appendChild(errorElement);
}

var player = new YT.Player(playerId, {
  videoId: videoId,
  playerVars: {
    autoplay: 1,
    controls: 1,
    enablejsapi: 1,
    modestbranding: 0,
    rel: 0,
    showinfo: 1,
    fs: 1,
  },
  events: {
    onReady: function(event) {
  // Log that we've triggered the onReady event
  logError("onReady event triggered... Checking quality levels soon.");

  setTimeout(() => {
    // 1) Fetch available quality levels
    const qualityLevels = event.target.getAvailableQualityLevels() || [];
    logError("Available Quality Levels: " + qualityLevels.join(", "));

    // 2) If no levels at all, handle gracefully
    if (qualityLevels.length === 0) {
      logError("No quality levels returned from the player.");
      const messageElement = document.createElement("p");
      messageElement.textContent = "No quality levels available at the moment.";
      document.body.appendChild(messageElement);
      return; // Stop here
    }

    // 3) Create an array of objects with (index, numericValue)
    //    so we can find both the highest value and its index.
    const numericQualitiesWithIndices = qualityLevels
      .map((level, idx) => {
        //logError("matching against: " + level);
        // Double-escaped backslash for Dart strings -> /\\d+/
        const match = level.match(/\\\\d+/);
        //logError("match.length = " + match.length);
        //logError("match = " + match[0]);
        const val = match ? parseInt(match[0], 10) : 0;
        logError("val = " + val);
        return { index: idx, value: val };
      })
      .filter(item => item.value > 0);

    // 4) If no numeric matches, show an error and stop
    if (numericQualitiesWithIndices.length === 0) {
      logError("No numeric qualities found in available quality levels.");
      const messageElement = document.createElement("p");
      messageElement.textContent = "Error: No numeric qualities found in available quality levels.";
      document.body.appendChild(messageElement);
      return;
    }

    // 5) Find the tuple that has the highest numeric value
    let bestTuple = numericQualitiesWithIndices[0];
    for (let i = 1; i < numericQualitiesWithIndices.length; i++) {
      if (numericQualitiesWithIndices[i].value > bestTuple.value) {
        bestTuple = numericQualitiesWithIndices[i];
      }
    }
    logError("Max numeric resolution: " + bestTuple.value);

    // 6) Use bestTuple's index to retrieve the full original string
    const bestQuality = qualityLevels[bestTuple.index];
    logError("Best matching quality string: " + bestQuality);

    // 7) If for some reason it's undefined, handle gracefully
    if (!bestQuality) {
      logError("No suitable numeric playback quality found.");
      const messageElement = document.createElement("p");
      messageElement.textContent = "No suitable numeric playback quality found.";
      document.body.appendChild(messageElement);
      return;
    }

    // 8) We have our valid bestQuality - set it
    logError("Setting playback quality to: " + bestQuality);
    event.target.setPlaybackQuality(bestQuality);
    let actualQuality = "";
    setTimeout(() => {
    const actualQuality = event.target.getPlaybackQuality();
    logError("Confirmed playback quality: " + actualQuality);
    }, 1000);
    
    // 9) Show a short message with the final selection
    const currentQualityElement = document.createElement("p");
    currentQualityElement.textContent = "Selected Playback Quality: " + bestQuality;
    document.body.appendChild(currentQualityElement);
  }, 500); // Adjust delay if needed
},
    onError: function (error) {
      logError("YouTube Player Error: " + JSON.stringify(error));
    },
  },
});

        window.players.push(player);
      }
    };

    document.addEventListener("DOMContentLoaded", function() {
      // Replace <x> with <pre><code> for code highlighting
      var customTags = document.querySelectorAll('x');
      for (var i = 0; i < customTags.length; i++) {
        var customTag = customTags[i];
        var codeContent = customTag.innerHTML.trim();
        var pre = document.createElement('pre');
        var code = document.createElement('code');
        codeContent = codeContent.replace('<', '&lt;').replace('>', '&gt;');
        code.innerHTML = codeContent;
        pre.appendChild(code);
        customTag.replaceWith(pre);
      }

      // Highlight code blocks
      try {
        hljs.highlightAll();
      } catch (e) {
        console.error("Highlight.js error: " + e);
      }

      // Dynamically load the YouTube IFrame API
      var ytScript = document.createElement("script");
      ytScript.src = "https://www.youtube.com/iframe_api";
      ytScript.async = true;
      ytScript.defer = true;
      document.head.appendChild(ytScript);
    });
  </script>

  <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.8.0/highlight.min.js"></script>
</head>
<body>
  $htmlContent
</body>
</html>
`);
document.close();
''';
      await _controller.executeScript(script);
    }
  }

  // @override
  // void didPushNext() {
  //   // Widget is no longer visible, stop the video
  //   stopVideos();
  // }

  // @override
  // void didPopNext() {
  //   stopVideos();
  // }

  Future<void> _launchWebView2Installer() async {
    const url = 'https://go.microsoft.com/fwlink/p/?LinkId=2124703';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      debugPrint('Could not launch $url');
    }
  }

  @override
  void dispose() {
    //WidgetsBinding.instance?.removeObserver(this);
    stopVideos();
    // Dispose of the WebView controller
    _controller.dispose();
    super.dispose();
  }

  void stopVideos() {
    if (_isWebViewInitialized) {
      _controller?.executeScript('''
        if(typeof window.stopAllVideos === 'function') {
          window.stopAllVideos();
        }
      ''');
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

    return _isWebViewInitialized
        ? LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      child: VisibilityDetector(
                        key: Key('html-viewer'),
                        onVisibilityChanged: (info) {
                          if (info.visibleFraction == 0) {
                            //stopVideos();
                            //_controller.stop();
                          }
                        },
                        child: Webview(_controller),
                      )),
                  if (widget.showEditButton)
                    Positioned(
                      top: 16.0,
                      right: 16.0,
                      child: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          stopVideos();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CodeEditorWidget(
                                language: widget.language,
                                initialText: widget.initialText,
                                onChanged: (str) {
                                  _updateWebView(str, widget._cssPath);
                                  widget.onChanged?.call(str);
                                },
                                onLanguageChanged: widget.onLanguageChanged,
                              ),
                            ),
                          );
                          // Handle edit action
                        },
                      ),
                    ),
                ],
              );
            },
          )
        : Center(child: CircularProgressIndicator());
  }
}
