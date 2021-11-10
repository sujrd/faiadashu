import 'package:fhir/r4.dart';

import '../../../model.dart';

class BooleanAnswerModel extends AnswerModel<Boolean, Boolean> {
  BooleanAnswerModel(QuestionItemModel responseModel) : super(responseModel);

  @override
  QuestionnaireResponseAnswer? get filledAnswer =>
      (value != null) ? QuestionnaireResponseAnswer(valueBoolean: value) : null;

  @override
  String get display => (value == null)
      ? AnswerModel.nullText
      : (value == Boolean(true))
          ? '[X]'
          : '[ ]';

  @override
  String? validateInput(Boolean? inValue) {
    return null;
  }

  @override
  QuestionnaireErrorFlag? get isComplete => null;

  @override
  bool get isUnanswered => value == null;

  @override
  void populate(QuestionnaireResponseAnswer answer) {
    value = answer.valueBoolean;
  }
}
