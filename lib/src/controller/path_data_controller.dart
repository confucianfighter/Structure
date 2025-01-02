// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/services.dart'; // for rootBundle
// import 'package:flutter/foundation.dart'; // for ValueNotifier
// import 'package:Structure/src/data_store.dart';
// import 'package:Structure/src/data_types/object_box_types/category.dart';
// // … import other model classes as needed

// class PathDataController {
//   // A map from path (e.g. 'box:category/14') to a ValueNotifier of some data type
//   final Map<String, ValueNotifier<Object?>> _notifiers = {};

//   // 1) SUBSCRIBE
//   /// Returns a `ValueNotifier<T?>`, creating it if necessary and loading data.
//   /// If you only plan to subscribe (i.e. read the data in a widget),
//   /// call subscribe.
//   /// If data is not yet loaded, you can either load it lazily or right away.
//   ValueNotifier<T?> subscribe<T>(String path) {
//     if (!_notifiers.containsKey(path)) {
//       // Create a new ValueNotifier for this path
//       _notifiers[path] = ValueNotifier<T?>(null);

//       // Optionally, load the data right away
//       _loadDataIntoNotifier<T>(path);
//     }
//     return _notifiers[path]! as ValueNotifier<T?>;
//   }

//   // 2) READ
//   /// If you just want to do a one-time load, you can call read<T>(path).
//   /// It returns the data in memory. If not in memory, loads from the data source.
//   Future<T?> read<T>(String path) async {
//     // If not subscribed yet, create a notifier but do not necessarily listen to it
//     if (!_notifiers.containsKey(path)) {
//       _notifiers[path] = ValueNotifier<T?>(null);
//     }
//     await _loadDataIntoNotifier<T>(path);
//     return (_notifiers[path]! as ValueNotifier<T?>).value;
//   }

//   // 3) WRITE
//   /// Writes (creates/updates) the data at the given path.
//   /// Then updates the ValueNotifier so any subscribers rebuild.
//   Future<void> write<T>(String path, T newData) async {
//     // Actually write the data out (ObjectBox, file, asset not typically writable, etc.)
//     await _writeDataSource<T>(path, newData);

//     // Update the cached ValueNotifier
//     if (!_notifiers.containsKey(path)) {
//       _notifiers[path] = ValueNotifier<T?>(newData);
//     } else {
//       final notifier = _notifiers[path]! as ValueNotifier<T?>;
//       notifier.value = newData;
//     }
//   }

//   // 4) PRIVATE LOADING HELPER
//   Future<void> _loadDataIntoNotifier<T>(String path) async {
//     final T? data = await _readDataSource<T>(path);
//     // If the path is known to exist in `_notifiers`, update it:
//     if (_notifiers.containsKey(path)) {
//       (_notifiers[path]! as ValueNotifier<T?>).value = data;
//     }
//   }

//   // 5) READ FROM THE RIGHT DATA SOURCE
//   Future<T?> _readDataSource<T>(String path) async {
//     final uri = Uri.parse(path);
//     switch (uri.scheme) {
//       case 'box':
//         return _readBox<T>(uri);
//       case 'file':
//         return _readFile<T>(uri);
//       case 'asset':
//         return _readAsset<T>(uri);
//       default:
//         throw UnsupportedError('Unsupported scheme: ${uri.scheme}');
//     }
//   }

//   // 6) WRITE TO THE RIGHT DATA SOURCE
//   Future<void> _writeDataSource<T>(String path, T newData) async {
//     final uri = Uri.parse(path);
//     switch (uri.scheme) {
//       case 'box':
//         await _writeBox<T>(uri, newData);
//         break;
//       case 'file':
//         await _writeFile<T>(uri, newData);
//         break;
//       case 'asset':
//         throw UnsupportedError('Assets are typically read-only');
//       default:
//         throw UnsupportedError('Unsupported scheme: ${uri.scheme}');
//     }
//   }

//   // ─────────────────────────────────────────────────────────────
//   // The following methods parse the path segments for box, file, or asset
//   // and do the actual read/write using your ObjectBox or file system calls.
//   // ─────────────────────────────────────────────────────────────

//   /// Example: box:flash_card/42
//   ///          box:category/all
//   Future<T?> _readBox<T>(Uri uri) async {
//     final segments = uri.pathSegments; // e.g. ["flash_card", "42"]
//     final boxName = segments.isNotEmpty ? segments[0] : null;
//     final maybeId = (segments.length > 1) ? segments[1] : null;

//     if (boxName == 'flash_card') {
//       if (maybeId == 'all') {
//         // Return all FlashCards
//         final data = Data().store.box<FlashCard>().getAll();
//         return data as T;
//       } else {
//         // Single ID
//         final id = int.tryParse(maybeId ?? '');
//         if (id != null) {
//           final card = Data().store.box<FlashCard>().get(id);
//           return card as T?;
//         }
//       }
//     } else if (boxName == 'category') {
//       if (maybeId == 'all') {
//         // Return all categories
//         final data = Data().store.box<Category>().getAll();
//         return data as T;
//       } else {
//         // Single ID
//         final id = int.tryParse(maybeId ?? '');
//         if (id != null) {
//           final cat = Data().store.box<Category>().get(id);
//           return cat as T?;
//         }
//       }
//     }
//     // … handle other boxes (Subject, WritingPrompt, etc.)

//     // If nothing matched, return null or throw
//     return null;
//   }

//   Future<void> _writeBox<T>(Uri uri, T newData) async {
//     final segments = uri.pathSegments; // e.g. ["flash_card", "42"]
//     final boxName = segments.isNotEmpty ? segments[0] : null;
//     // Typically, newData is either an entire object or a list of objects
//     // You can parse it as needed
//     if (boxName == 'flash_card') {
//       if (newData is FlashCard) {
//         Data().store.box<FlashCard>().put(newData);
//       } else if (newData is List<FlashCard>) {
//         for (var card in newData) {
//           Data().store.box<FlashCard>().put(card);
//         }
//       }
//     } else if (boxName == 'category') {
//       if (newData is Category) {
//         Data().store.box<Category>().put(newData);
//       } else if (newData is List<Category>) {
//         for (var cat in newData) {
//           Data().store.box<Category>().put(cat);
//         }
//       }
//     }
//     // … handle other boxes
//   }

//   /// For file: scheme, e.g. file:/Users/mike/data.txt
//   Future<T?> _readFile<T>(Uri uri) async {
//     final filePath = uri.toFilePath();
//     final file = File(filePath);
//     if (!await file.exists()) return null;
//     if (T == String) {
//       return await file.readAsString() as T;
//     } else if (T == List<int>) {
//       return await file.readAsBytes() as T;
//     }
//     // or parse JSON if T == MyModel, etc. That’s up to you.
//     // For now, just read as string by default if T is unknown
//     return await file.readAsString() as T?;
//   }

//   Future<void> _writeFile<T>(Uri uri, T newData) async {
//     final filePath = uri.toFilePath();
//     final file = File(filePath);
//     if (newData is String) {
//       await file.writeAsString(newData);
//     } else if (newData is List<int>) {
//       await file.writeAsBytes(newData);
//     } else {
//       throw UnsupportedError(
//           'We only support writing String or List<int> to file');
//     }
//   }

//   /// For asset: scheme, e.g. asset:assets/writing_prompts.toml
//   /// Typically read-only, so we just handle reading
//   Future<T?> _readAsset<T>(Uri uri) async {
//     // e.g. pathSegments = ["assets", "writing_prompts.toml"]
//     final assetPath = uri.path; // e.g. "/assets/writing_prompts.toml"
//     final trimmedPath =
//         assetPath.startsWith('/') ? assetPath.substring(1) : assetPath;

//     if (T == String) {
//       return rootBundle.loadString(trimmedPath) as T;
//     } else if (T == ByteData) {
//       return await rootBundle.load(trimmedPath) as T;
//     }
//     // If you need JSON from assets, parse it similarly
//     final rawString = await rootBundle.loadString(trimmedPath);
//     return rawString as T?;
//   }
// }
