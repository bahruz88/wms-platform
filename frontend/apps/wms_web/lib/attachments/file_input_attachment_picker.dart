import 'dart:async';
import 'dart:js_interop';

import 'package:feature_inventory/feature_inventory.dart';
import 'package:web/web.dart' as web;
import 'package:wms_api_client/wms_api_client.dart';

/// [AttachmentPicker] on the web: a hidden `<input type="file">`.
///
/// No plugin is involved, which keeps the web bundle free of a camera
/// dependency. `accept` is limited to the photo MIME types the Documents
/// contract allows, so the file dialog filters before the size/type check
/// in `AttachmentPolicy` runs.
class FileInputAttachmentPicker implements AttachmentPicker {
  const FileInputAttachmentPicker({this.accept = defaultAccept});

  static const String defaultAccept = 'image/jpeg,image/png';

  /// `accept` attribute of the input element.
  final String accept;

  @override
  bool get isAvailable => true;

  @override
  Future<PickedAttachment?> pickPhoto() {
    final completer = Completer<PickedAttachment?>();
    final input = web.HTMLInputElement()
      ..type = 'file'
      ..accept = accept
      ..multiple = false
      ..style.display = 'none';

    void finish(PickedAttachment? value) {
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
            PickedAttachment(
              fileName: file.name,
              contentType: _contentTypeOf(file),
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

  static String _contentTypeOf(web.File file) {
    final type = file.type;
    if (type.isNotEmpty && AttachmentPolicy.isAllowed(type)) {
      return AttachmentPolicy.normalise(type);
    }
    return AttachmentPolicy.contentTypeForFileName(file.name) ??
        AttachmentPolicy.jpeg;
  }
}
