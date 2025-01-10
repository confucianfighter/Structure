import 'dart:async';
import 'dart:io';

class WindowControl {
  final String cliPath =
      './WindowControlCLI/bin/Debug/net9.0/WindowControlCLI.exe';
  final String windowTitle = "Structure";
  WindowControl();

  /// Helper to run the CLI with a given window title and command
  Future<String> runCommand(String partialWindowTitle, String command) async {
    try {
      final result = await Process.run(
        cliPath,
        [partialWindowTitle, command],
      );

      if (result.exitCode != 0) {
        throw Exception(
          "Error running command '$command'. "
          "Exit code: ${result.exitCode}\n${result.stderr}",
        );
      }

      return result.stdout.toString().trim();
    } catch (e) {
      throw Exception("Failed to execute command: $e");
    }
  }

  /// Make the window always on top
  Future<void> setAlwaysOnTop({String? partialWindowTitle}) async {
    partialWindowTitle ??= windowTitle;
    print(await runCommand(partialWindowTitle, "always_on_top"));
  }

  /// Remove always-on-top
  Future<void> removeAlwaysOnTop({String? partialWindowTitle}) async {
    partialWindowTitle ??= windowTitle;
    print(await runCommand(partialWindowTitle, "remove_always_on_top"));
  }

  /// Minimize the window
  Future<void> minimize({String? partialWindowTitle}) async {
    partialWindowTitle ??= windowTitle;
    print(await runCommand(partialWindowTitle, "minimize"));
  }

  /// Restore the window
  Future<void> restore({String? partialWindowTitle}) async {
    partialWindowTitle ??= windowTitle;
    print(await runCommand(partialWindowTitle, "restore"));
  }

  /// Toggle the window into fullscreen (popup style)
  Future<void> setFullscreen({String? partialWindowTitle}) async {
    partialWindowTitle ??= windowTitle;
    print(await runCommand(partialWindowTitle, "fullscreen"));
  }

  /// Return the window to normal style/size
  Future<void> exitFullscreen({String? partialWindowTitle}) async {
    partialWindowTitle ??= windowTitle;
    print(await runCommand(partialWindowTitle, "normal"));
  }

  /// Check if the window is currently in fullscreen mode
  Future<bool> isFullScreen({String? partialWindowTitle}) async {
    partialWindowTitle ??= windowTitle;
    final output = await runCommand(partialWindowTitle, "isfullscreen");
    // The CLI prints: "Is fullscreen? True" or "Is fullscreen? False"
    // We'll parse that line using a simple regex approach:
    final regex =
        RegExp(r"Is fullscreen\?\s*(true|false)", caseSensitive: false);
    final match = regex.firstMatch(output);

    if (match != null) {
      return match.group(1)!.toLowerCase() == 'true';
    } else {
      // Fallback: just look for the word "true" if regex doesn't match
      return output.toLowerCase().contains("true");
    }
  }
}
