// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:async';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:visibility_detector/visibility_detector.dart';
// import 'package:structure/src/widgets/code_editor/code_editor.dart';
// import 'package:structure/src/widgets/log/log_manager.dart';

// class HTMLViewer extends StatefulWidget {
//   final String initialText;
//   final String _cssPath;
//   final String _highlightJsCssPath;
//   final Function(String)? onLanguageChanged;
//   final Function(String)? onChanged;
//   final bool showEditButton;
//   final String language;

//   const HTMLViewer({
//     super.key,
//     required this.initialText,
//     required String cssPath,
//     required String highlightJsCssPath,
//     required this.onLanguageChanged,
//     required this.onChanged,
//     required this.showEditButton,
//     required this.language,
//   })  : _cssPath = cssPath,
//         _highlightJsCssPath = highlightJsCssPath;

//   @override
//   _HTMLViewerState createState() => _HTMLViewerState();
// }

// class _HTMLViewerState extends State<HTMLViewer> with WidgetsBindingObserver {
//   late InAppWebViewController _webViewController;
//   bool _controllerReady = false;

//   // Example: Additional JavaScript you want to persist in the global scope.
//   // You could split these up if you want to manage them separately.
//   static const String _globalUserScript = r"""
//     // ================================
//     // Global script for YouTube + HLJS
//     // ================================

//     // 1. Global players array
//     window.players = [];

//     // 2. Stop All Videos
//     window.stopAllVideos = function() {
//       if (!Array.isArray(window.players) || window.players.length === 0) {
//         console.error("No players available to stop.");
//         return;
//       }
//       for (var i = 0; i < window.players.length; i++) {
//         try {
//           window.players[i].stopVideo();
//         } catch (err) {
//           console.error("Error stopping video player " + i + ": " + err);
//         }
//       }
//     };

//     // 3. YouTube IFrame API callback
//     window.onYouTubeIframeAPIReady = function() {
//       var ytTags = document.querySelectorAll("youtube");
//       if (ytTags.length === 0) {
//         console.error("No <youtube> tags found in the document.");
//         return;
//       }

//       for (var index = 0; index < ytTags.length; index++) {
//         var ytTag = ytTags[index];
//         var videoId = ytTag.getAttribute("video-id");
//         if (!videoId) {
//           console.error("No video ID provided for <youtube> at index " + index);
//           var errorMsg = document.createElement("p");
//           errorMsg.textContent = "Error: No video ID provided at index " + index;
//           errorMsg.style.color = "red";
//           ytTag.replaceWith(errorMsg);
//           continue;
//         }

//         var playerId = "youtube-player-" + index;
//         var div = document.createElement("div");
//         div.id = playerId;
//         ytTag.replaceWith(div);

//         var player = new YT.Player(playerId, {
//           videoId: videoId,
//           playerVars: {
//             autoplay: 1,
//             controls: 1,
//             enablejsapi: 1,
//             modestbranding: 0,
//             rel: 0,
//             showinfo: 1,
//             fs: 1,
//           },
//           events: {
//             onReady: function() { console.log("YouTube Player " + index + " is ready!"); },
//             onError: function(err) { console.error("YouTube Player error: ", err); }
//           }
//         });
//         window.players.push(player);
//       }
//     };

//     // 4. Process custom tags
//     //    Called after we update innerHTML
//     window.processCustomTags = function() {
//       // Replace <x> with <pre><code> for code highlighting
//       var customTags = document.querySelectorAll('x');
//       for (var i = 0; i < customTags.length; i++) {
//         var customTag = customTags[i];
//         var codeContent = customTag.innerHTML.trim();
//         var pre = document.createElement('pre');
//         var code = document.createElement('code');
//         codeContent = codeContent.replace(/</g, '&lt;').replace(/>/g, '&gt;');
//         code.innerHTML = codeContent;
//         pre.appendChild(code);
//         customTag.replaceWith(pre);
//       }

//       // Highlight.js
//       try {
//         hljs.highlightAll();
//       } catch (e) {
//         console.error("Highlight.js error: " + e);
//       }

//       // Dynamically load the YouTube IFrame API if needed
//       var ytScript = document.createElement("script");
//       ytScript.src = "https://www.youtube.com/iframe_api";
//       ytScript.async = true;
//       ytScript.defer = true;
//       document.head.appendChild(ytScript);
//     };
//   """;

//   @override
//   void initState() {
//     super.initState();
//     log("HTMLViewer initState");
//   }

//   @override
//   void didUpdateWidget(covariant HTMLViewer oldWidget) {
//     super.didUpdateWidget(oldWidget);

//     // If anything relevant changes and the controller is ready, reload or update
//     if (_controllerReady) {
//       final changedHTML = widget.initialText != oldWidget.initialText;
//       final changedCSS = widget._cssPath != oldWidget._cssPath ||
//           widget._highlightJsCssPath != oldWidget._highlightJsCssPath;

//       if (changedHTML || changedCSS) {
//         // Quick approach: re-load the entire doc each time 
//         // or update only the #content if you prefer:
//         _loadInitialDocument(widget.initialText);
//       }
//     }
//   }

//   /// Loads the HTML content into the WebView.
//   /// First we load the CSS, then build the final HTML string,
//   /// then call `loadData` on the controller.
//   Future<void> _loadInitialDocument(String htmlContent) async {
//     final cssContent = await _loadCssFile(widget._cssPath);
//     final highlightCss = await _loadCssFile(widget._highlightJsCssPath);

//     if (cssContent.isEmpty) {
//       throw Exception('CSS content is empty');
//     }

//     final finalHTML = _buildHtmlString(htmlContent, cssContent, highlightCss);

//     // Finally, load the data in the webview
//     await _webViewController.loadData(
//       data: finalHTML,
//       baseUrl: WebUri("about:blank"),
//       mimeType: 'text/html',
//       encoding: 'utf-8',
//       androidHistoryUrl: Uri.parse("about:blank"),
//     );
//   }

//   /// Helper that returns the full HTML for the page.
//   String _buildHtmlString(
//     String htmlContent,
//     String cssContent,
//     String highlightCss,
//   ) {
//     return '''
// <!DOCTYPE html>
// <html lang="en">
// <head>
//   <meta charset="UTF-8"/>
//   <meta name="viewport" content="width=device-width, initial-scale=1.0">
//   <style>
//     /* Combined CSS: highlight + user-defined */
//     $highlightCss
//     $cssContent
//   </style>

//   <!-- We'll load highlight.js from a CDN, for example. 
//        Or you can inline that script as well. -->
//   <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.8.0/highlight.min.js"></script>

// </head>
// <body>
//   <div id="content">$htmlContent</div>
// </body>
// </html>
// ''';
//   }

//   /// Loads a CSS file from asset into a string.
//   Future<String> _loadCssFile(String assetPath) async {
//     try {
//       return await rootBundle.loadString(assetPath);
//     } catch (e) {
//       print("Error loading CSS file: $e");
//       return "";
//     }
//   }

//   /// Stops all playing videos by calling our global JS function
//   void stopVideos() {
//     if (_controllerReady) {
//       _webViewController.evaluateJavascript(source: '''
//         if (typeof window.stopAllVideos === 'function') {
//           window.stopAllVideos();
//         }
//       ''');
//     }
//   }

//   @override
//   void dispose() {
//     stopVideos();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(builder: (context, constraints) {
//       return Stack(
//         children: [
//           SizedBox(
//             width: constraints.maxWidth,
//             height: constraints.maxHeight,
//             child: VisibilityDetector(
//               key: const Key('html-viewer'),
//               onVisibilityChanged: (info) {
//                 // The widget is not visible => stop videos
//                 if (info.visibleFraction == 0) {
//                   stopVideos();
//                 }
//               },
//               child: InAppWebView(
//                 initialOptions: InAppWebViewGroupOptions(
//                   crossPlatform: InAppWebViewOptions(
//                     useShouldOverrideUrlLoading: true,
//                     mediaPlaybackRequiresUserGesture: false,
//                   ),
//                 ),
//                 onWebViewCreated: (controller) async {
//                   _webViewController = controller;

//                   // 1. Add your user script (the global JS definitions)
//                   await controller.addUserScript(
//                     userScript: UserScript(
//                       source: _globalUserScript,
//                       injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
//                     ),
//                   );

//                   // 2. Once user scripts are in place, mark controller as ready
//                   _controllerReady = true;

//                   // 3. Load the initial HTML content
//                   _loadInitialDocument(widget.initialText);
//                 },
//               ),
//             ),
//           ),
//           if (widget.showEditButton)
//             Positioned(
//               top: 16.0,
//               right: 16.0,
//               child: IconButton(
//                 icon: const Icon(Icons.edit),
//                 onPressed: () {
//                   stopVideos();
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => CodeEditorWidget(
//                         language: widget.language,
//                         initialText: widget.initialText,
//                         onChanged: widget.onChanged,
//                         onLanguageChanged: widget.onLanguageChanged,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//         ],
//       );
//     });
//   }
// }
