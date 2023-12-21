import 'package:faiadashu/fhir_types/fhir_types.dart';
import 'package:faiadashu/questionnaires/model/model.dart';
import 'package:faiadashu/questionnaires/model/src/validation_errors/date_time_error.dart';
import 'package:faiadashu/questionnaires/model/src/validation_errors/validation_error.dart';
import 'package:fhir/r4.dart'
    show
        FhirDate,
        FhirDateTime,
        FhirExtension,
        FhirTime,
        QuestionnaireResponseAnswer,
        QuestionnaireResponseItem;

class DateTimeAnswerModel extends AnswerModel<FhirDateTime, FhirDateTime> {
  late final FhirExtension? _minValueExtension;
  late final FhirExtension? _maxValueExtension;

  DateTimeAnswerModel(super.responseModel) {
    _minValueExtension = qi.extension_
        ?.extensionOrNull('http://hl7.org/fhir/StructureDefinition/minValue');
    _maxValueExtension = qi.extension_
        ?.extensionOrNull('http://hl7.org/fhir/StructureDefinition/maxValue');
  }

  FhirDateTime? _toDateTime(dynamic value) {
    if (value == null) return null;

    // TODO: Find a better way to convert FhirTime values to FhirDateTime
    return value is FhirTime
      ? FhirDateTime('1970-01-01T$value')
      : FhirDateTime(value);
  }

  FhirDateTime? _calculateDateTimeValue(List<FhirExtension>? extensions) {
    final cqfExpressionExtension = extensions?.extensionOrNull('http://hl7.org/fhir/StructureDefinition/cqf-expression');
    final expression = cqfExpressionExtension?.valueExpression;

    if (expression == null) return null;

    // TODO: Should evaluators be cached?
    final evaluator = FhirExpressionEvaluator.fromExpression(
      null,
      expression,
      [...questionItemModel.itemWithPredecessorsExpressionEvaluators],
      jsonBuilder: () =>
          questionnaireResponseModel.fhirResponseItemByUid(nodeUid),
    );

    final rawEvaluationResult = evaluator.evaluate();
    if (!(rawEvaluationResult is List && rawEvaluationResult.isNotEmpty)) return null;

    return _toDateTime(rawEvaluationResult.first);
  }

  FhirDateTime? _getDateTimeValue(FhirExtension? extension) {
    // NOTE: Model should probably be populated based on QuestionnaireItemType
    if (extension == null) return null;

    final calculatedValue =
      _calculateDateTimeValue(extension.valueDateTimeElement?.extension_) ??
      _calculateDateTimeValue(extension.valueDateElement?.extension_) ??
      _calculateDateTimeValue(extension.valueTimeElement?.extension_);

    return calculatedValue ??
      extension.valueDateTime ??
      _toDateTime(extension.valueDate) ??
      _toDateTime(extension.valueTime);
  }

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

    if (itemType == QuestionnaireItemType.date) {
      return QuestionnaireResponseAnswer(
        valueDate: FhirDate(value!.value),
        item: items,
      );
    } else if (itemType == QuestionnaireItemType.dateTime) {
      return QuestionnaireResponseAnswer(
        valueDateTime: value,
        item: items,
      );
    } else if (itemType == QuestionnaireItemType.time) {
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
    if (inValue == null) return null;
    if (!inValue.isValid) return DateTimeError(nodeUid);

    final minValue = _getDateTimeValue(_minValueExtension);
    final maxValue = _getDateTimeValue(_maxValueExtension);

    if (minValue != null && inValue < minValue) return DateTimeError(nodeUid);
    if (maxValue != null && inValue > maxValue) return DateTimeError(nodeUid);

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
      _toDateTime(answer.valueDate) ??
      _toDateTime(answer.valueTime);
  }
}
