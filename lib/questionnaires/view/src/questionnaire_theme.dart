import 'package:faiadashu/l10n/l10n.dart';
import 'package:faiadashu/logging/logging.dart';
import 'package:faiadashu/questionnaires/questionnaires.dart';
import 'package:flutter/material.dart';

/// Should coding selections be presented in a compact or an expanded format?
///
/// compact = dropdown or auto-complete
/// expanded = radio buttons / check boxes
enum CodingControlPreference {
  compact,
  expanded,
}

class QuestionnaireTheme extends InheritedWidget {
  final QuestionnaireThemeData data;

  const QuestionnaireTheme({
    required this.data,
    required Widget child,
    Key? key,
  }) : super(key: key, child: child);

  static QuestionnaireThemeData of(BuildContext context) {
    final inheritedTheme =
        context.dependOnInheritedWidgetOfExactType<QuestionnaireTheme>();

    return inheritedTheme == null
        ? const QuestionnaireThemeData()
        : inheritedTheme.data;
  }

  @override
  bool updateShouldNotify(QuestionnaireTheme oldWidget) => false;
}

/// Create the views for all levels of a questionnaire. Provide styling theme.
class QuestionnaireThemeData {
  static final _logger = Logger(QuestionnaireThemeData);

  /// Returns whether user will be offered option to skip question.
  final bool canSkipQuestions;

  /// Returns whether a progress bar/circle is displayed while filling
  final bool showProgress;

  /// Returns whether the score is displayed while filling (in stepper mode only)
  final bool showScore;

  static const defaultAutoCompleteThreshold = 10;

  /// Coding answers with more than this amount of choices will be shown as auto-complete control
  final int autoCompleteThreshold;

  static const defaultHorizontalCodingBreakpoint = 750.0;

  /// The minimum display width to show coding answers horizontally
  final double horizontalCodingBreakpoint;

  static const defaultMaxLinesForTextItem = 4;
  final int maxLinesForTextItem;

  static const defaultMaxItemWidth = 800.0;

  /// The maximum width of the questionnaire items
  ///
  /// They will not use more width, even if the display is wider.
  final double maxItemWidth;

  /// Mode of date entry method for the date picker dialog for date and dateTime items.
  ///
  /// Possible Values: https://api.flutter.dev/flutter/material/DatePickerEntryMode.html
  final DatePickerEntryMode datePickerEntryMode;

  /// Interactive input mode of the time picker dialog for dateTime and time items.
  ///
  /// Possible Values: https://api.flutter.dev/flutter/material/TimePickerEntryMode.html
  final TimePickerEntryMode timePickerEntryMode;

  static const defaultCodingControlPreference = CodingControlPreference.compact;
  final CodingControlPreference codingControlPreference;

  final QuestionnaireAnswerFiller Function(AnswerModel, {Key? key})
      createQuestionnaireAnswerFiller;

  /// Builds layouts for question items.
  ///
  /// [titleWidget] contains the text of the question, [answerFillerWidget] is the input control
  /// associated with the corresponding question (textbox, datepicker, etc.).
  ///
  /// [promptTextWidget] contains the prompt text content if the question has an itemControl extension
  /// with `prompt` type.
  ///
  /// [questionSkipperWidget] is returned if `QuestionnaireThemeData.canSkipQuestions` is set to true.
  final Widget Function(
    BuildContext context,
    QuestionItemModel questionItemModel,
    Widget answerFillerWidget, {
    Widget? titleWidget,
    Widget? promptTextWidget,
    Widget? questionSkipperWidget,
  }) questionResponseItemLayoutBuilder;

  /// Builds layouts for group items.
  ///
  /// [titleWidget] contains the text of the group.
  ///
  /// [errorText] contains any validation errors associated with the group in question.
  final Widget Function(
    BuildContext context,
    GroupItemModel groupItemModel, {
    Widget? titleWidget,
    String? errorText,
  }) groupItemLayoutBuilder;

  /// Builds layouts for display items.
  ///
  /// [titleWidget] contains the text of the display item.
  final Widget Function(
    BuildContext context,
    DisplayItemModel displayItemModel, {
    Widget? titleWidget,
  }) displayItemLayoutBuilder;

  /// Builds layouts for the input controls of choice-type items (coding).
  ///
  /// [codingControlWidget] is the input control associated with the question.
  ///
  /// [openStringInputControlWidget] is returned if the item is of type open-choice.
  ///
  /// [errorText] contains any validation errors associated with the question.
  final Widget Function(
    BuildContext context,
    Widget codingControlWidget, {
    Widget? openStringInputControlWidget,
    String? errorText,
  }) codingControlLayoutBuilder;

  /// Builds layouts for QuestionnaireScroller items.
  ///
  /// [responseFiller] contains the state data for the current [QuestionnaireResponseFiller].
  ///
  /// [itemIndex] is the index of the form item that's being currently built.
  final Widget? Function(
    BuildContext context,
    QuestionnaireFillerData responseFiller,
    int itemIndex,
  ) scrollerItemBuilder;

  /// Get [QuestionnaireItemFiller] for a specific page.
  ///
  /// [responseFiller] contains the state data for the current [QuestionnaireResponseFiller].
  ///
  /// [pageIndex] is the index of the page that's being currently built.
  final QuestionnaireItemFiller? Function(
    QuestionnaireFillerData responseFiller,
    int pageIndex,
  ) stepperQuestionnaireItemFiller;

  /// Builds layouts for QuestionnaireStepper pages.
  /// If there are no more pages to show, this method must return `null`.
  ///
  /// [itemFiller] contains [QuestionnaireItemFiller] to be rendered.
  final Widget Function(
    BuildContext context,
    QuestionnaireItemFiller itemFiller,
  ) stepperPageItemBuilder;

  const QuestionnaireThemeData({
    this.canSkipQuestions = false,
    this.showProgress = true,
    this.showScore = true,
    this.autoCompleteThreshold = defaultAutoCompleteThreshold,
    this.horizontalCodingBreakpoint = defaultHorizontalCodingBreakpoint,
    this.maxLinesForTextItem = defaultMaxLinesForTextItem,
    this.codingControlPreference = defaultCodingControlPreference,
    this.maxItemWidth = defaultMaxItemWidth,
    this.datePickerEntryMode = DatePickerEntryMode.calendar,
    this.timePickerEntryMode = TimePickerEntryMode.dial,
    this.createQuestionnaireAnswerFiller = _createDefaultAnswerFiller,
    this.questionResponseItemLayoutBuilder = _defaultQuestionResponseItemLayoutBuilder,
    this.groupItemLayoutBuilder = _defaultGroupItemLayoutBuilder,
    this.displayItemLayoutBuilder = _defaultDisplayItemLayoutBuilder,
    this.codingControlLayoutBuilder = _defaultCodingControlLayoutBuilder,
    this.scrollerItemBuilder = _defaultScrollerItemBuilder,
    this.stepperQuestionnaireItemFiller = _defaultStepperQuestionnaireItemFiller,
    this.stepperPageItemBuilder = _defaultStepperPageItemBuilder,
  });

  /// Returns a [QuestionnaireItemFiller] for a given [QuestionnaireResponseFiller].
  ///
  /// Used by [QuestionnaireResponseFiller].
  QuestionnaireItemFiller createQuestionnaireItemFiller(
    QuestionnaireFillerData questionnaireFiller,
    FillerItemModel fillerItemModel, {
    Key? key,
  }) {
    if (fillerItemModel is QuestionItemModel) {
      return QuestionResponseItemFiller(
        questionnaireFiller,
        fillerItemModel,
        key: key,
      );
    } else if (fillerItemModel is GroupItemModel) {
      return GroupItem(
        questionnaireFiller,
        fillerItemModel,
        key: key,
      );
    } else if (fillerItemModel is DisplayItemModel) {
      return DisplayItem(
        questionnaireFiller,
        fillerItemModel,
        key: key,
      );
    } else {
      throw UnsupportedError('Cannot generate filler for $fillerItemModel');
    }
  }

  /// Returns a [QuestionnaireAnswerFiller] for a given [AnswerModel].
  static QuestionnaireAnswerFiller _createDefaultAnswerFiller(
    AnswerModel answerModel, {
    Key? key,
  }) {
    try {
      final responseModel = answerModel.responseItemModel;

      _logger.debug(
        'Creating AnswerFiller for ${responseModel.questionnaireItemModel} - $answerModel',
      );

      if (responseModel.questionnaireItemModel.isDisplay) {
        throw UnsupportedError(
          'Cannot generate an answer filler on a display item.',
        );
      }

      if (responseModel.questionnaireItemModel.isGroup) {
        throw UnsupportedError(
          'Cannot generate an answer filler on a group item.',
        );
      }

      if (responseModel.questionnaireItemModel.isTotalScore) {
        return TotalScoreItem(answerModel, key: key);
      }

      if (answerModel is NumericalAnswerModel) {
        return NumericalAnswerFiller(answerModel, key: key);
      } else if (answerModel is StringAnswerModel) {
        return StringAnswerFiller(answerModel, key: key);
      } else if (answerModel is DateTimeAnswerModel) {
        return DateTimeAnswerFiller(answerModel, key: key);
      } else if (answerModel is CodingAnswerModel) {
        return CodingAnswerFiller(answerModel, key: key);
      } else if (answerModel is BooleanAnswerModel) {
        return BooleanAnswerFiller(answerModel, key: key);
      } else if (answerModel is AttachmentAnswerModel) {
        return AttachmentAnswerFiller(answerModel, key: key);
      } else if (answerModel is UnsupportedAnswerModel) {
        throw QuestionnaireFormatException(
          'Unsupported item type: ${answerModel.qi.type}',
          answerModel.questionnaireItemModel.linkId,
        );
      } else {
        throw QuestionnaireFormatException('Unknown AnswerModel: $answerModel');
      }
    } catch (exception) {
      _logger.warn('Cannot create answer filler:', error: exception);

      return BrokenAnswerFiller(
        answerModel,
        exception,
        key: key,
      );
    }
  }

  /// Decorate a [QuestionnaireAnswerFiller] with UI elements.
  ///
  ///
  Widget decorateRepeatingAnswer(
    BuildContext context,
    QuestionnaireAnswerFiller answerFiller,
    VoidCallback? removeAnswerCallback, {
    Key? key,
  }) {
    return Row(
      children: [
        Expanded(child: answerFiller),
        IconButton(
          onPressed:
              (removeAnswerCallback != null) ? removeAnswerCallback : null,
          icon: const Icon(Icons.delete),
        ),
      ],
    );
  }

  /// Build a UI element to add another answer to a repeating item
  ///
  /// Will be disabled if [callback] is null.
  Widget buildAddRepetition(
    BuildContext context,
    ResponseItemModel responseItemModel,
    VoidCallback? callback, {
    Key? key,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: callback,
          key: key,
          label: Text(
            FDashLocalizations.of(context).fillerAddAnotherItemLabel(
              responseItemModel.questionnaireItemModel.shortText ??
                  responseItemModel.questionnaireItemModel.text?.plainText ??
                  '',
            ),
          ),
          icon: const Icon(Icons.add),
        ),
        const SizedBox(height: 8.0),
      ],
    );
  }

  static Widget _defaultQuestionResponseItemLayoutBuilder(
    BuildContext context,
    QuestionItemModel questionItemModel,
    Widget answerFillerWidget, {
    Widget? titleWidget,
    Widget? promptTextWidget,
    Widget? questionSkipperWidget,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (titleWidget != null)
          Container(
            padding: const EdgeInsets.only(top: 8),
            child: titleWidget,
          ),
        if (promptTextWidget != null)
          promptTextWidget,
        Container(
          padding: const EdgeInsets.only(top: 8),
          child: answerFillerWidget,
        ),
        if (questionSkipperWidget != null)
          questionSkipperWidget,
        const SizedBox(height: 16),
      ],
    );
  }

  static Widget _defaultGroupItemLayoutBuilder(
    BuildContext context,
    GroupItemModel groupItemModel, {
    Widget? titleWidget,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (titleWidget != null)
          Container(
            padding: const EdgeInsets.only(top: 8.0),
            child: titleWidget,
          ),
        if (errorText != null)
          Container(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              errorText,
              style: Theme.of(context).textTheme.subtitle1!.copyWith(
                    color: Theme.of(context).errorColor,
                  ),
            ),
          ),
      ],
    );
  }

  static Widget _defaultDisplayItemLayoutBuilder(
    BuildContext context,
    DisplayItemModel displayItemModel, {
    Widget? titleWidget,
  }) {
    return Column(
      children: [
        if (titleWidget != null)
          Container(
            padding: const EdgeInsets.only(top: 8.0),
            child: titleWidget,
          ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  static Widget _defaultCodingControlLayoutBuilder(
    BuildContext context,
    Widget codingControlWidget, {
    Widget? openStringInputControlWidget,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        codingControlWidget,
        if (openStringInputControlWidget != null) openStringInputControlWidget,
        if (errorText != null) Text(
          errorText,
          style: Theme.of(context)
              .textTheme
              .caption
              ?.copyWith(color: Theme.of(context).errorColor),
        ),
      ],
    );
  }

  static Widget? _defaultScrollerItemBuilder(
    BuildContext context,
    QuestionnaireFillerData responseFiller,
    int index,
  ) {
    return responseFiller.itemFillerAt(index);
  }

  static QuestionnaireItemFiller? _defaultStepperQuestionnaireItemFiller(
    QuestionnaireFillerData responseFiller,
    int index,
  ) {
    final itemFiller = responseFiller.visibleItemFillerAt(index);
    if (itemFiller == null) return null;

    return itemFiller;
  }

  static Widget _defaultStepperPageItemBuilder(
    BuildContext context,
    QuestionnaireItemFiller itemFiller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: itemFiller,
    );
  }
}
