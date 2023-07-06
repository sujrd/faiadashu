import 'package:faiadashu/fhir_types/fhir_types.dart';
import 'package:faiadashu/questionnaires/questionnaires.dart';
import 'package:fhir/r4.dart';
import 'package:flutter/material.dart';

class AttachmentAnswerFiller extends QuestionnaireAnswerFiller {
  AttachmentAnswerFiller(
    super.answerModel, {
    super.key,
  });
  @override
  State<StatefulWidget> createState() => _AttachmentAnswerState();
}

class _AttachmentAnswerState extends QuestionnaireAnswerFillerState<Attachment,
    AttachmentAnswerFiller, AttachmentAnswerModel> {
  _AttachmentAnswerState();

  @override
  // ignore: no-empty-block
  void postInitState() {
    // Intentionally do nothing.
  }

  @override
  Widget createInputControl() => _AttachmentInputControl(
        answerModel,
        focusNode: firstFocusNode,
      );
}

class _AttachmentInputControl extends AnswerInputControl<AttachmentAnswerModel> {
  const _AttachmentInputControl(
    AttachmentAnswerModel answerModel, {
    FocusNode? focusNode,
  }) : super(
          answerModel,
          focusNode: focusNode,
        );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: FhirAttachmentPicker(
        focusNode: focusNode,
        enabled: answerModel.isControlEnabled,
        initialAttachment: answerModel.value,
        allowedMimeTypes: answerModel.mimeTypes,
        onChanged: (attachment) => answerModel.value = attachment,
        decoration: InputDecoration(
          errorText: answerModel.displayErrorText,
        ),
      ),
    );
  }
}
