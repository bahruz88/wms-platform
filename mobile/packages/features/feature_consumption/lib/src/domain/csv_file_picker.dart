import 'dart:typed_data';

import 'package:meta/meta.dart';

/// A CSV chosen by the user, already in memory. The contract caps the
/// upload at 5 MB, so buffering is safe and the size can be checked before
/// anything leaves the browser.
@immutable
class PickedCsvFile {
  const PickedCsvFile({required this.fileName, required this.bytes});

  final String fileName;
  final Uint8List bytes;

  int get sizeBytes => bytes.length;

  @override
  String toString() => 'PickedCsvFile($fileName, $sizeBytes B)';
}

/// File picking boundary, mirroring `BarcodeScanner`/`AttachmentPicker`:
/// the web app provides the `<input type="file">` implementation and this
/// package stays plugin free and testable on the VM.
abstract interface class CsvFilePicker {
  /// `true` when this platform can pick a file at all.
  bool get isAvailable;

  /// `null` when the user cancelled.
  Future<PickedCsvFile?> pickCsv();
}

/// Default on platforms without a file dialog (mobile, tests): the upload
/// panel stays visible but explains why it cannot be used.
class UnsupportedCsvFilePicker implements CsvFilePicker {
  const UnsupportedCsvFilePicker();

  @override
  bool get isAvailable => false;

  @override
  Future<PickedCsvFile?> pickCsv() async => null;
}

/// Picker that always returns the same file; used by widget tests.
class StaticCsvFilePicker implements CsvFilePicker {
  const StaticCsvFilePicker(this.file);

  final PickedCsvFile? file;

  @override
  bool get isAvailable => true;

  @override
  Future<PickedCsvFile?> pickCsv() async => file;
}
