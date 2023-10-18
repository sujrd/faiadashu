import 'package:faiadashu/coding/coding.dart';
import 'package:faiadashu/fhir_types/fhir_types.dart';
import 'package:faiadashu/logging/logging.dart';
import 'package:faiadashu/questionnaires/model/model.dart';
import 'package:faiadashu/questionnaires/model/src/validation_errors/max_value_error.dart';
import 'package:faiadashu/questionnaires/model/src/validation_errors/min_value_error.dart';
import 'package:faiadashu/questionnaires/model/src/validation_errors/nan_error.dart';
import 'package:faiadashu/questionnaires/model/src/validation_errors/validation_error.dart';
import 'package:fhir/r4.dart';
import 'package:intl/intl.dart';

/// Models numerical answers.
class NumericalAnswerModel extends AnswerModel<String, Quantity> {
  static final _logger = Logger(NumericalAnswerModel);

  late final String _numberPattern;
  late final bool _isSliding;
  late final double _minValue;
  late final double _maxValue;
  late final int _maxDecimal;
  late final NumberFormat _numberFormat;
  late final double? _sliderStepValue;
  late final int? _sliderDivisions;

  RenderingString? _upperSliderLabel;
  RenderingString? _lowerSliderLabel;

  RenderingString? get upperSliderLabel => _upperSliderLabel;
  RenderingString? get lowerSliderLabel => _lowerSliderLabel;

  int? get sliderDivisions => _sliderDivisions;
  double? get sliderStepValue => _sliderStepValue;

  String get numberPattern => _numberPattern;
  bool get isSliding => _isSliding;
  double get minValue => _minValue;
  double get maxValue => _maxValue;
  int get maxDecimal => _maxDecimal;
  NumberFormat get numberFormat => _numberFormat;

  late final Map<String, Coding> _units;

  bool get hasUnit => value?.hasUnit ?? false;

  bool get hasUnitChoices => _units.isNotEmpty;

  bool get hasSingleUnitChoice => _units.length == 1;

  Iterable<Coding> get unitChoices => _units.values;

  Coding? unitChoiceByKey(String? key) {
    return (key != null) ? _units[key] : null;
  }

  String keyForUnitChoice(Coding coding) {
    final choiceString =
        (coding.code != null) ? coding.code?.value : coding.display;

    if (choiceString == null) {
      throw QuestionnaireFormatException(
        'Insufficient info for key string in $coding',
        coding,
      );
    } else {
      return choiceString;
    }
  }

  /// Returns a unique slug for the current unit.
  String? get keyOfUnit {
    if (!(value?.hasUnit ?? false)) {
      return null;
    }

    final coding =
        Coding(system: value?.system, code: value?.code, display: value?.unit);

    return keyForUnitChoice(coding);
  }

  NumericalAnswerModel(super.responseModel) {
    _initializeRanges();
    _initializeFormatting();
    _initializeUnits();
  }

  void _initializeRanges() {
    _isSliding =
        questionnaireItemModel.questionnaireItem.isItemControl('slider');

    final minValueExtension = qi.extension_
        ?.extensionOrNull('http://hl7.org/fhir/StructureDefinition/minValue');
    final maxValueExtension = qi.extension_
        ?.extensionOrNull('http://hl7.org/fhir/StructureDefinition/maxValue');
    _minValue = minValueExtension?.valueDecimal?.value ??
        minValueExtension?.valueInteger?.value?.toDouble() ??
        0.0;
    _maxValue = maxValueExtension?.valueDecimal?.value ??
        maxValueExtension?.valueInteger?.value?.toDouble() ??
        (_isSliding ? modelDefaults.sliderMaxValue : double.maxFinite);

    if (_isSliding) {
      final sliderStepValueExtension = qi.extension_?.extensionOrNull(
        'http://hl7.org/fhir/StructureDefinition/questionnaire-sliderStepValue',
      );
      _sliderStepValue = sliderStepValueExtension?.valueDecimal?.value ??
          sliderStepValueExtension?.valueInteger?.value?.toDouble();
      _sliderDivisions = (_sliderStepValue != null)
          ? ((_maxValue - _minValue) / _sliderStepValue!).round()
          : null;

      _upperSliderLabel = questionnaireItemModel.upperTextItem?.text;
      _lowerSliderLabel = questionnaireItemModel.lowerTextItem?.text;
    }
  }

  void _initializeFormatting() {
    switch (qi.type) {
      case QuestionnaireItemType.integer:
        _maxDecimal = 0;
        break;
      case QuestionnaireItemType.decimal:
      case QuestionnaireItemType.quantity:
        // TODO: Evaluate special extensions for quantities
        _maxDecimal = qi.extension_
                ?.extensionOrNull(
                  'http://hl7.org/fhir/StructureDefinition/maxDecimalPlaces',
                )
                ?.valueInteger
                ?.value ??
            modelDefaults.maxDecimal;
        break;
      default:
        throw StateError('item.type cannot be ${qi.type}');
    }

    // Build a number format based on item and SDC properties.
    _numberFormat = NumberFormat.decimalPatternDigits(
      locale: locale.toLanguageTag(), // TODO: toString or toLanguageTag?
      decimalDigits: _maxDecimal,
    );
  }

  void _initializeUnits() {
    _units = <String, Coding>{};

    final unitsUri = qi.extension_
        ?.extensionOrNull('http://hl7.org/fhir/StructureDefinition/questionnaire-unitValueSet')
        ?.valueCanonical
        .toString();
    if (unitsUri != null) {
      questionnaireItemModel.questionnaireModel.forEachInValueSet(
        unitsUri,
        (coding) {
          _units[keyForUnitChoice(coding)] = coding;
        },
        context: qi.linkId,
      );
    }

    qi.extension_
        ?.whereExtensionIs('http://hl7.org/fhir/StructureDefinition/questionnaire-unitOption')
        ?.forEach((extension) {
      final coding = extension.valueCoding;
      if (coding == null) return;
      _units[keyForUnitChoice(coding)] = coding;
    });

    // Using updated usage for questionnaire-unit in R5 (http://hl7.org/fhir/extensions/StructureDefinition-questionnaire-unit.html)
    final questionnaireUnit = qi.extension_
        ?.extensionOrNull(
            'http://hl7.org/fhir/StructureDefinition/questionnaire-unit')
        ?.valueCoding;
    if (questionnaireUnit != null && questionnaireUnit.display != null) {
      _units[keyForUnitChoice(questionnaireUnit)] = questionnaireUnit;
    }
  }

  @override
  RenderingString get display => (value != null)
      ? RenderingString.fromText(
          value!.format(locale, defaultText: AnswerModel.nullText),
        )
      : RenderingString.nullText;

  @override
  ValidationError? validateInput(String? inputValue) {
    if (inputValue == null || inputValue.isEmpty) {
      return null;
    }
    num number = double.nan;
    try {
      number = numberFormat.parse(inputValue);
    } catch (_) {
      // Ignore FormatException, number remains nan.
    }
    if (number.isNaN) {
      return NanError(nodeUid);
    }

    final quantity = _valueFromNumber(number);

    return validateValue(quantity);
  }

  @override
  ValidationError? validateValue(Quantity? inputValue) {
    if (inputValue == null) {
      return null;
    }

    final number = inputValue.value;

    if (number == null) {
      return null;
    }

    if (number > _maxValue) {
      return MaxValueError(nodeUid, Decimal(_maxValue).format(locale));
    }
    if (number < _minValue) {
      return MinValueError(nodeUid, Decimal(_minValue).format(locale));
    }

    return null;
  }

  /// Returns a modified copy of the current [value].
  ///
  /// * Keeps the numerical value
  /// * Updates the unit based on a key as returned by [keyForUnitChoice]
  Quantity? copyWithUnit(String? unitChoiceKey) {
    final unitCoding = unitChoiceByKey(unitChoiceKey);

    return (value != null)
        ? value!.copyWith(
            unit: unitCoding?.localizedDisplay(locale),
            system: unitCoding?.system,
            code: unitCoding?.code,
          )
        : Quantity(
            unit: unitCoding?.localizedDisplay(locale),
            system: unitCoding?.system,
            code: unitCoding?.code,
          );
  }

  /// Returns a modified copy of the current [value].
  ///
  /// * Updates the numerical value based on a [Decimal]
  /// * Keeps the unit
  Quantity? copyWithValue(Decimal? newValue) {
    return (value != null)
        ? value!.copyWith(value: newValue)
        : Quantity(value: newValue);
  }

  /// Returns a modified copy of the current [value].
  ///
  /// * Updates the numerical value based on text input
  /// * Keeps the unit
  Quantity? copyWithTextInput(String textInput) {
    final valid = validateInput(textInput);

    final dataAbsentReasonExtension = valid != null
        ? [
            FhirExtension(
              url: dataAbsentReasonExtensionUrl,
              valueCode: dataAbsentReasonAsTextCode,
            ),
          ]
        : null;

    return textInput.trim().isEmpty
        ? value?.copyWith(value: null)
        : value == null
            ? Quantity(
                value: Decimal(numberFormat.parse(textInput)),
                extension_: dataAbsentReasonExtension,
              )
            : value!.copyWith(
                value: Decimal(numberFormat.parse(textInput)),
                extension_: dataAbsentReasonExtension,
              );
  }

  @override
  QuestionnaireResponseAnswer? createFhirAnswer(
    List<QuestionnaireResponseItem>? items,
  ) {
    _logger.debug('createFhirAnswer: $value');
    if (value == null) {
      return null;
    }

    switch (qi.type) {
      case QuestionnaireItemType.decimal:
        return (value!.value != null)
            ? QuestionnaireResponseAnswer(
                valueDecimal: value!.value,
                extension_: value!.extension_,
                item: items,
              )
            : null;
      case QuestionnaireItemType.quantity:
        return QuestionnaireResponseAnswer(
          valueQuantity: value,
          extension_: value!.extension_,
          item: items,
        );
      case QuestionnaireItemType.integer:
        return (value!.value != null)
            ? QuestionnaireResponseAnswer(
                valueInteger: Integer(value!.value!.value!.round()),
                extension_: value!.extension_,
                item: items,
              )
            : null;
      default:
        throw StateError('item.type cannot be ${qi.type}');
    }
  }

  @override
  bool get isEmpty => (value == null) || (value!.value == null);

  Quantity? _valueFromNumber(dynamic inputNumber) {
    final unitCoding = qi.computableUnit;

    final quantityValue = Decimal(inputNumber);

    return Quantity(
      value: quantityValue,
      unit: unitCoding?.localizedDisplay(locale),
      system: unitCoding?.system,
      code: unitCoding?.code,
      extension_: (unitCoding != null &&
              (qi.type == QuestionnaireItemType.decimal ||
                  qi.type == QuestionnaireItemType.integer))
          ? [
              FhirExtension(
                url: FhirUri(
                  'http://hl7.org/fhir/StructureDefinition/questionnaire-unit',
                ),
                valueCoding: unitCoding,
              ),
            ]
          : null,
    );
  }

  @override
  void populateFromExpression(dynamic evaluationResult) {
    if (evaluationResult == null) {
      value = null;

      return;
    }

    value = _valueFromNumber(evaluationResult);
  }

  @override
  void populate(QuestionnaireResponseAnswer answer) {
    value = answer.valueQuantity ??
        ((answer.valueDecimal != null && answer.valueDecimal!.isValid)
            ? Quantity(value: answer.valueDecimal)
            : (answer.valueInteger != null && answer.valueInteger!.isValid)
                ? Quantity(
                    value: Decimal(answer.valueInteger),
                  )
                : null);
  }
}
