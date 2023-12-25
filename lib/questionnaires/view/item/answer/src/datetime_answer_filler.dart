import 'package:faiadashu/fhir_types/fhir_types.dart';
import 'package:faiadashu/l10n/l10n.dart';
import 'package:faiadashu/questionnaires/questionnaires.dart';
import 'package:fhir/r4.dart'
    show FhirDate, FhirDateTime, FhirTime;
import 'package:flutter/material.dart';

class DateTimeAnswerFiller extends QuestionnaireAnswerFiller {

  DateTimeAnswerFiller(
    super.answerModel, {
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _DateTimeAnswerState();
}

class _DateTimeAnswerState extends QuestionnaireAnswerFillerState<FhirDateTime,
    DateTimeAnswerFiller, DateTimeAnswerModel> {
  _DateTimeAnswerState();

  @override
  // ignore: no-empty-block
  void postInitState() {
    // Intentionally do nothing.
  }

  @override
  Widget createInputControl() => _DateTimeInputControl(
        answerModel,
        focusNode: firstFocusNode,
      );
}

class _DateTimeInputControl extends AnswerInputControl<DateTimeAnswerModel> {

  const _DateTimeInputControl(
    super.answerModel, {
    super.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final itemType = qi.type;

    final initialDate = answerModel.value;

    final pickerType = ArgumentError.checkNotNull(
      {
        QuestionnaireItemType.date: FhirDate,
        QuestionnaireItemType.dateTime: FhirDateTime,
        QuestionnaireItemType.time: FhirTime,
      }[itemType],
    );

    return FhirDateTimePicker(
      focusNode: focusNode,
      enabled: answerModel.isControlEnabled,
      initialDateTime: initialDate,
      // TODO: This can be specified through minValue / maxValue
      firstDate: DateTime(1860),
      lastDate: DateTime(2050),
      pickerType: pickerType,
      datePickerEntryMode: QuestionnaireTheme.of(context).datePickerEntryMode,
      timePickerEntryMode: QuestionnaireTheme.of(context).timePickerEntryMode,
      decoration: InputDecoration(
        errorText: answerModel.displayErrorText(FDashLocalizations.of(context)),
        errorStyle: (itemModel
                .isCalculated) // Force display of error text on calculated item
            ? TextStyle(
                color: Theme.of(context).colorScheme.error,
              )
            : null,
      ),
      onDialogShown: (isDialogShown) => answerModel.questionItemModel.isUserInteractionAllowed = !isDialogShown,
      onChanged: (fhirDatetime) => answerModel.value = fhirDatetime,
    );
  }
}
