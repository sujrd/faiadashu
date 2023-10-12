import 'package:faiadashu/l10n/l10n.dart';
import 'package:faiadashu/logging/logging.dart';
import 'package:faiadashu/questionnaires/questionnaires.dart';
import 'package:flutter/material.dart';

/// A view for filler items of type "group".
class GroupItem extends ResponseItemFiller {
  GroupItem(
    QuestionnaireFillerData questionnaireFiller,
    ResponseItemModel responseItemModel, {
    Key? key,
  }) : super(questionnaireFiller, responseItemModel, key: key);

  @override
  State<StatefulWidget> createState() => _GroupItemState();
}

class _GroupItemState extends ResponseItemFillerState<GroupItem> {
  static final _gLogger = Logger(GroupItem);

  _GroupItemState();

  @override
  Widget build(BuildContext context) {
    _gLogger.trace(
      'build group ${widget.responseItemModel}',
    );

    final titleWidget = this.titleWidget;

    return AnimatedBuilder(
      animation: widget.responseItemModel,
      builder: (context, _) {
        final errorText = widget.responseItemModel.getErrorText(
          FDashLocalizations.of(context),
        );

        return widget.responseItemModel.displayVisibility !=
                DisplayVisibility.hidden
            ? QuestionnaireTheme.of(context).groupItemLayoutBuilder(
                context,
                widget.responseItemModel as GroupItemModel,
                titleWidget: titleWidget,
                errorText: errorText,
              )
            : const SizedBox.shrink();
      },
    );
  }
}
