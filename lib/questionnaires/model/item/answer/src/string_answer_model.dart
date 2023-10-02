import 'package:faiadashu/coding/coding.dart';
import 'package:faiadashu/fhir_types/fhir_types.dart';
import 'package:faiadashu/questionnaires/model/model.dart';
import 'package:faiadashu/questionnaires/model/src/validation_errors/entry_format_error.dart';
import 'package:faiadashu/questionnaires/model/src/validation_errors/min_length_error.dart';
import 'package:faiadashu/questionnaires/model/src/validation_errors/regex_error.dart';
import 'package:faiadashu/questionnaires/model/src/validation_errors/url_error.dart';
import 'package:fhir/r4.dart';

enum StringAnswerKeyboard { plain, email, phone, number, multiline, url }

/// Models string answers, incl. URLs.
class StringAnswerModel extends AnswerModel<String, String> {
  static final _urlRegExp = RegExp(
    r'^(http|https|ftp|sftp)://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\(\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+',
  );

  late final RegExp? regExp;
  late final int minLength;
  late final int? maxLength;
  late final StringAnswerKeyboard keyboard;

  StringAnswerModel(super.responseModel) {
    final regexPattern = qi.extension_
        ?.extensionOrNull('http://hl7.org/fhir/StructureDefinition/regex')
        ?.valueString;

    regExp =
        (regexPattern != null) ? RegExp(regexPattern, unicode: true) : null;

    minLength = qi.extension_
            ?.extensionOrNull(
              'http://hl7.org/fhir/StructureDefinition/minLength',
            )
            ?.valueInteger
            ?.value ??
        0;

    maxLength = qi.maxLength?.value;

    final keyboardExtension = qi.extension_
        ?.extensionOrNull(
          'http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-keyboard',
        )
        ?.valueCode
        ?.value;

    keyboard = (qi.type == QuestionnaireItemType.text)
        ? StringAnswerKeyboard.multiline
        : (qi.type == QuestionnaireItemType.url)
            ? StringAnswerKeyboard.url
            : (keyboardExtension == 'email')
                ? StringAnswerKeyboard.email
                : (keyboardExtension == 'phone')
                    ? StringAnswerKeyboard.phone
                    : (keyboardExtension == 'number')
                        ? StringAnswerKeyboard.number
                        : StringAnswerKeyboard.plain;
  }

  @override
  RenderingString get display => (value != null)
      ? RenderingString.fromText(value!)
      : RenderingString.nullText;

  @override
  void validateInput(String? inValue) {
    final checkValue = inValue?.trim();

    return validateValue(checkValue);
  }

  @override
  void validateValue(String? inputValue) {
    if (inputValue == null || inputValue.isEmpty) {
      return;
    }

    if (inputValue.length < minLength) {
      throw MinLengthError(nodeUid, minLength);
    }

    if (maxLength != null && inputValue.length > maxLength!) {
      throw MinLengthError(nodeUid, maxLength!);
    }

    if (qi.type == QuestionnaireItemType.url) {
      if (!_urlRegExp.hasMatch(inputValue)) {
        throw UrlError(nodeUid);
      }
    }

    if (regExp != null) {
      if (!regExp!.hasMatch(inputValue)) {
        throw (entryFormat != null)
            ? EntryFormatError(nodeUid, entryFormat!)
            : RegexError(nodeUid);
      }
    }
  }

  @override
  QuestionnaireResponseAnswer? createFhirAnswer(
    List<QuestionnaireResponseItem>? items,
  ) {
    try {
      final value = this.value?.trim();

      validateInput(value);

      final dataAbsentReasonExtension = [
        FhirExtension(
          url: dataAbsentReasonExtensionUrl,
          valueCode: dataAbsentReasonAsTextCode,
        ),
      ];

      return (value != null && value.isNotEmpty)
          ? (qi.type != QuestionnaireItemType.url)
              ? QuestionnaireResponseAnswer(
                  valueString: value,
                  extension_: dataAbsentReasonExtension,
                  item: items,
                )
              : QuestionnaireResponseAnswer(
                  valueUri: FhirUri(value),
                  extension_: dataAbsentReasonExtension,
                  item: items,
                )
          : null;
    } on Exception {
      return null;
    }
  }

  @override
  bool get isEmpty => value?.trim().isEmpty ?? true;

  @override
  void populateFromExpression(dynamic evaluationResult) {
    if (evaluationResult == null) {
      value = null;

      return;
    }

    value = evaluationResult as String?;
  }

  @override
  void populate(QuestionnaireResponseAnswer answer) {
    value = answer.valueString;
  }
}
