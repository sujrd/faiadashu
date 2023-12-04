import 'package:faiadashu/logging/logging.dart';
import 'package:faiadashu/questionnaires/questionnaires.dart';
import 'package:flutter/material.dart';

/// A view for filler items of type "display".
class DisplayItem extends QuestionnaireItemFiller {
  DisplayItem(
    super.questionnaireFiller,
    super.fillerItem, {
    super.key,
  });
  @override
  State<StatefulWidget> createState() => _DisplayItemState();
}

class _DisplayItemState extends QuestionnaireItemFillerState<DisplayItem> {
  _DisplayItemState();

  static final _dlogger = Logger(GroupItem);

  @override
  Widget build(BuildContext context) {
    _dlogger.trace(
      'build ${widget.fillerItemModel}',
    );

    final questionnaireTheme = QuestionnaireTheme.of(context);
    final titleWidget = QuestionnaireItemFillerTitle.fromFillerItem(
      fillerItem: widget.fillerItemModel,
      questionnaireTheme: questionnaireTheme,
    );

    return AnimatedBuilder(
      animation: widget.fillerItemModel,
      builder: (context, _) {
        return widget.fillerItemModel.displayVisibility !=
                DisplayVisibility.hidden
            ? questionnaireTheme.displayItemLayoutBuilder(
                context,
                widget.fillerItemModel as DisplayItemModel,
                titleWidget: titleWidget,
              )
            : const SizedBox.shrink();
      },
    );
  }
}
