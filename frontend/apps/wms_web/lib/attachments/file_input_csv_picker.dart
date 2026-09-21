import 'dart:async';
import 'dart:js_interop';

import 'package:feature_consumption/feature_consumption.dart';
import 'package:web/web.dart' as web;

/// [CsvFilePicker] on the web: a hidden `<input type="file">`.
///
/// No plugin is involved. `accept` is limited to CSV so the file dialog
/// filters before the 5 MB check in the upload screen runs; the parser
/// itself detects the delimiter and the encoding (UTF-8 / Windows-1254).
class FileInputCsvPicker implements CsvFilePicker {
  const FileInputCsvPicker({this.accept = defaultAccept});

  static const String defaultAccept = '.csv,text/csv,text/plain';

  /// `accept` attribute of the input element.
  final String accept;

  @override
  bool get isAvailable => true;

  @override
  Future<PickedCsvFile?> pickCsv() {
    final completer = Completer<PickedCsvFile?>();
    final input = web.HTMLInputElement()
      ..type = 'file'
      ..accept = accept
      ..multiple = false
      ..style.display = 'none';

    void finish(PickedCsvFile? value) {
      if (!completer.isCompleted) completer.complete(value);
      input.remove();
    }

    input.onchange = ((web.Event _) {
      final files = input.files;
      if (files == null || files.length == 0) {
        finish(null);
        return;
      }
      final file = files.item(0);
      if (file == null) {
        finish(null);
        return;
      }
      final reader = web.FileReader();
      reader.onload = ((web.Event _) {
        final result = reader.result;
        if (result.isA<JSArrayBuffer>()) {
          finish(
            PickedCsvFile(
              fileName: file.name,
              bytes: (result! as JSArrayBuffer).toDart.asUint8List(),
            ),
          );
        } else {
          finish(null);
        }
      }).toJS;
      reader.onerror = ((web.Event _) => finish(null)).toJS;
      reader.readAsArrayBuffer(file);
    }).toJS;
    // A cancelled dialog fires `cancel` in modern browsers; without it the
    // future would never complete and the button would spin forever.
    input.oncancel = ((web.Event _) => finish(null)).toJS;

    web.document.body?.append(input);
    input.click();
    return completer.future;
  }
}
