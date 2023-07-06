import 'package:faiadashu/questionnaires/model/model.dart';
import 'package:fhir/r4.dart';

class AttachmentAnswerModel extends AnswerModel<Attachment, Attachment> {
  AttachmentAnswerModel(super.responseModel);

  @override
  RenderingString get display => (value != null)
      ? RenderingString.fromText(value?.title ?? value?.url?.toString() ?? '')
      : RenderingString.nullText;

  @override
  String? validateInput(Attachment? inValue) {
    return null;
  }

  @override
  String? validateValue(Attachment? inputValue) {
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
