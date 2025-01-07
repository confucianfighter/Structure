import 'dart:io';

Future<String> adjustAudioGain(String inputPath, double gain) async {
  // Ensure the input file exists
  final inputFile = File(inputPath);
  if (!await inputFile.exists()) {
    throw Exception('Input file does not exist: $inputPath');
  }

  // Construct the output file path
  final outputPath = '${inputPath}_modified.mp3';
  print("Adjusting to a gain of $gain");

  // FFmpeg command to adjust audio gain with verbose logging
  final arguments = [
    '-y',
    '-v', 'verbose', // Set FFmpeg to verbose logging
    '-i', inputPath,
    '-filter:a', 'volume=$gain',
    outputPath,
  ];

  // Execute the FFmpeg command
  final result = await Process.run('ffmpeg', arguments);

  // Print FFmpeg's verbose output
  print('FFmpeg stdout: ${result.stdout}');
  print('FFmpeg stderr: ${result.stderr}');

  // Check for errors
  if (result.exitCode != 0) {
    throw Exception('FFmpeg failed with exit code ${result.exitCode}');
  }

  // Return the output file path
  return outputPath;
}
