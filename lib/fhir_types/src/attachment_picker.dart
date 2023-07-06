import 'dart:convert';
import 'dart:io';

import 'package:fhir/r4.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';

/// Present a picker for Attachment
///
/// The control is displayed as a text field that can be tapped to open
/// a file selector.
class FhirAttachmentPicker extends StatefulWidget {
  final Attachment? initialAttachment;
  final InputDecoration? decoration;
  final FocusNode? focusNode;
  final List<String>? allowedMimeTypes;
  final bool enabled;
  final void Function(Attachment?)? onChanged;

  const FhirAttachmentPicker({
    required this.initialAttachment,
    this.decoration,
    this.onChanged,
    this.focusNode,
    this.allowedMimeTypes,
    this.enabled = true,
    Key? key,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _FhirAttachmentPickerState createState() => _FhirAttachmentPickerState();
}

class _FhirAttachmentPickerState extends State<FhirAttachmentPicker> {
  final _attachmentFieldController = TextEditingController();
  Attachment? _attachmentValue;
  final _clearFocusNode = FocusNode(skipTraversal: true);

  @override
  void initState() {
    super.initState();
    _attachmentValue = widget.initialAttachment;
    _attachmentFieldController.text = _describeAttachment(_attachmentValue);
  }

  @override
  void dispose() {
    _attachmentFieldController.dispose();
    _clearFocusNode.dispose();
    super.dispose();
  }

  String _describeAttachment(Attachment? attachment) {
    if (attachment == null) return '';

    // TODO: What if we have an attachment with no title nor url?
    return attachment.title ?? attachment.url?.toString() ?? 'N/A';
  }

  Future<void> _pickFile() async {
    // NOTE1: "Platform" is not available in web, leading to crashes.
    // NOTE2: mimeTypes parameter is not available in iOS nor Windows: https://pub.dev/packages/file_selector#filtering-by-file-types
    // TODO: Find a way to convert MIME types to Uniform Type Identifiers supported by iOS.
    final typeGroups = (kIsWeb || !(Platform.isIOS || Platform.isWindows))
      ? [XTypeGroup(mimeTypes: widget.allowedMimeTypes)]
      : const <XTypeGroup>[];

    final file = await openFile(acceptedTypeGroups: typeGroups);

    if (file == null) return;

    final size = await file.length();
    final creation = await file.lastModified();
    final bytes = await file.readAsBytes();
    final mimeType = lookupMimeType('', headerBytes: bytes);

    final attachment = Attachment(
      title: file.name,
      contentType: Code(mimeType),
      size: UnsignedInt(size),
      data: Base64Binary(base64.encode(bytes)),
      creation: FhirDateTime(creation),
    );

    setState(() {
      _attachmentFieldController.text = _describeAttachment(attachment);
    });
    _attachmentValue = attachment;
    widget.onChanged?.call(attachment);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Refactor this with date_time_picker?
    return Stack(
      alignment: AlignmentDirectional.centerEnd,
      children: [
        TextFormField(
          focusNode: widget.focusNode,
          enabled: widget.enabled,
          textAlignVertical: TextAlignVertical.center,
          decoration: (widget.decoration ?? const InputDecoration()).copyWith(
            prefixIcon: const Icon(Icons.attach_file),
          ),
          controller: _attachmentFieldController,
          onTap: () async {
            await _pickFile();
          },
          readOnly: true,
        ),
        if (widget.enabled && _attachmentFieldController.text.isNotEmpty)
          IconButton(
            focusNode: _clearFocusNode,
            onPressed: () {
              setState(() {
                _attachmentFieldController.text = '';
              });
              widget.onChanged?.call(null);
            },
            icon: const Icon(Icons.cancel),
          ),
      ],
    );
  }
}
