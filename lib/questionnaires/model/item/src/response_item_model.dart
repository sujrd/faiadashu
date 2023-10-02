import 'package:faiadashu/faiadashu.dart';
import 'package:faiadashu/questionnaires/model/src/validation_errors/constraint_validation_error.dart';
import 'package:faiadashu/questionnaires/model/src/validation_errors/custom_validation_error.dart';
import 'package:faiadashu/questionnaires/model/src/validation_errors/required_item_error.dart';
import 'package:faiadashu/questionnaires/model/src/validation_errors/validation_error.dart';
import 'package:fhir/r4.dart';

/// Model a response item
///
/// This is a base class for either a question or a group item model.
abstract class ResponseItemModel extends FillerItemModel {
  static final _rimLogger = Logger(ResponseItemModel);

  late final FhirPathExpressionEvaluator? _constraintExpression;

  ResponseItemModel(
    super.parentNode,
    super.questionnaireResponseModel,
    super.questionnaireItemModel,
  ) {
    final constraintExpression = questionnaireItemModel.constraintExpression;

    _constraintExpression = constraintExpression != null
        ? FhirPathExpressionEvaluator(
            () => questionnaireResponseModel
                .createQuestionnaireResponseForFhirPath(),
            Expression(
              expression: constraintExpression,
              language: ExpressionLanguage.text_fhirpath,
            ),
            [
              ...itemWithPredecessorsExpressionEvaluators,
            ],
          )
        : null;
  }

  /// Can the item be answered?
  ///
  /// Static or read-only items cannot be answered.
  /// Items which are not enabled cannot be answered.
  bool get isAnswerable {
    final returnValue = !(questionnaireItemModel.isReadOnly || !isEnabled);

    _rimLogger.trace('isAnswerable $nodeUid: $returnValue');

    return returnValue;
  }

  /// Returns a description of the current error situation with this item.
  ///
  /// Localized text if an error exists. Or null if no error exists.
  String? getErrorText(FDashLocalizations localizations) {
    return _exception?.getMessage(localizations);
  }

  ValidationError? _exception;

  List<ValidationError> validate({
    bool updateErrorText = true,
    bool notifyListeners = false,
  }) {
    if (questionnaireItemModel.isRequired && isUnanswered) {
      return [RequiredItemError(nodeUid)];
    }
    try {
      validateConstraint();
      _exception = null;
    } on ValidationError catch (exception) {
      _exception ??= exception;

      if (_exception != exception) {
        if (updateErrorText) {
          _exception = exception;
        }
        if (notifyListeners) {
          this.notifyListeners();
        }
      }
      return [_exception!];
    }
    return [];
  }

  /// Returns whether the item is satisfying the `questionnaire-constraint`.
  ///
  /// Throws [CustomValidationError] with human-readable text if not satisfied.
  void validateConstraint() {
    final constraintExpression = _constraintExpression;
    if (constraintExpression == null) {
      return;
    }

    final isSatisfied = constraintExpression.fetchBoolValue(
      unknownValue: true,
      generation: questionnaireResponseModel.generation,
      location: nodeUid,
    );

    if (!isSatisfied) {
      throw ConstraintValidationError(
        nodeUid,
        questionnaireItemModel.constraintHuman,
      );
    }
  }
}
