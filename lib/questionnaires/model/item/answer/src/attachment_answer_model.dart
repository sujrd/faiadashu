import 'package:faiadashu/fhir_types/fhir_types.dart';
import 'package:faiadashu/questionnaires/model/model.dart';
import 'package:fhir/r4.dart';

class AttachmentAnswerModel extends AnswerModel<Attachment, Attachment> {
  final num maxSize;
  final List<String> mimeTypes;

  AttachmentAnswerModel(super.responseModel)
      : maxSize = responseModel.questionnaireItem.extension_
                ?.extensionOrNull('http://hl7.org/fhir/StructureDefinition/maxSize')
                ?.valueDecimal
                ?.value ?? 0,
        mimeTypes = responseModel.questionnaireItem.extension_
                ?.whereExtensionIs('http://hl7.org/fhir/StructureDefinition/mimeType')
                ?.map((ext) => ext.valueCode?.value ?? '')
                .where((mimeType) => mimeType != '')
                .toList() ?? [];

  @override
  RenderingString get display => (value != null)
      ? RenderingString.fromText(value?.title ?? value?.url?.toString() ?? '')
      : RenderingString.nullText;

  @override
  String? validateInput(Attachment? inValue) {
    return validateValue(inValue);
  }

  @override
  String? validateValue(Attachment? inputValue) {
    if (inputValue == null) return null;

    // TODO: Add translations.
    if (maxSize > 0) {
      final attachmentSize = inputValue.size?.value;
      if (attachmentSize == null) return 'Attachment had size missing and maxSize extension was specified';
      if (attachmentSize > maxSize) return 'Maximum file size limit exceeded';
    }

    if (mimeTypes.isNotEmpty) {
      final attachmentMimeType = inputValue.contentType?.value;
      if (attachmentMimeType == null) return 'Attachment mime type is missing.';
      if (!mimeTypes.contains(attachmentMimeType)) return 'Unsupported mime type';
    }

    return null;
  }

  @override
  QuestionnaireResponseAnswer? createFhirAnswer(
    List<QuestionnaireResponseItem>? items,
  ) {
    final value = this.value;

    return (value != null)
        ? QuestionnaireResponseAnswer(valueAttachment: value, item: items)
        : null;
  }

  @override
  bool get isEmpty => value == null;

  @override
  void populate(QuestionnaireResponseAnswer answer) {
    value = answer.valueAttachment;
  }
}
