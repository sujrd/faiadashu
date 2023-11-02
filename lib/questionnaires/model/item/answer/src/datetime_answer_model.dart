import 'package:faiadashu/fhir_types/fhir_types.dart';
import 'package:faiadashu/questionnaires/model/model.dart';
import 'package:faiadashu/questionnaires/model/src/validation_errors/date_time_error.dart';
import 'package:faiadashu/questionnaires/model/src/validation_errors/validation_error.dart';
import 'package:fhir/r4.dart'
    show
        FhirCode,
        FhirDate,
        FhirDateTime,
        FhirTime,
        QuestionnaireResponseAnswer,
        QuestionnaireResponseItem;

class DateTimeAnswerModel extends AnswerModel<FhirDateTime, FhirDateTime> {
  DateTimeAnswerModel(super.responseModel);

  @override
  RenderingString get display => (value != null)
      ? RenderingString.fromText(
          value!.format(locale, defaultText: AnswerModel.nullText),
        )
      : RenderingString.nullText;

  @override
  QuestionnaireResponseAnswer? createFhirAnswer(
    List<QuestionnaireResponseItem>? items,
  ) {
    final itemType = qi.type;

    if (value?.value == null) {
      return null;
    }

    if (itemType == FhirCode('date')) {
      return QuestionnaireResponseAnswer(
        valueDate: FhirDate(value!.value),
        item: items,
      );
    } else if (itemType == FhirCode('dateTime')) {
      return QuestionnaireResponseAnswer(
        valueDateTime: value,
        item: items,
      );
    } else if (itemType == FhirCode('time')) {
      return QuestionnaireResponseAnswer(
        valueTime: FhirTime(
          value!.value!.toIso8601String().substring('yyyy-MM-ddT'.length),
        ),
        item: items,
      );
    } else {
      throw StateError('Unexpected itemType: $itemType');
    }
  }

  @override
  ValidationError? validateInput(FhirDateTime? inValue) {
    return validateValue(inValue);
  }

  @override
  ValidationError? validateValue(FhirDateTime? inValue) {
    if (!(inValue == null || inValue.isValid)) {
      return DateTimeError(nodeUid);
    }
    return null;
  }

  @override
  bool get isEmpty => value == null;

  @override
  void populateFromExpression(dynamic evaluationResult) {
    if (evaluationResult == null) {
      value = null;

      return;
    }

    value = FhirDateTime(evaluationResult);
  }

  @override
  void populate(QuestionnaireResponseAnswer answer) {
    // NOTE: Model should probably be populated based on QuestionnaireItemType
    value = answer.valueDateTime ??
        ((answer.valueDate != null)
            ? FhirDateTime(answer.valueDate)
            : (answer.valueTime != null)
                // TODO: Find a better way to convert FhirTime values to FhirDateTime
                ? FhirDateTime('1970-01-01T${answer.valueTime}')
                : null);
  }
}
