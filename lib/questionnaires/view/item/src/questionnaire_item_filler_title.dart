import 'package:faiadashu/fhir_types/fhir_types.dart';
import 'package:faiadashu/logging/logging.dart';
import 'package:faiadashu/questionnaires/questionnaires.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

class QuestionnaireItemFillerTitle extends StatelessWidget {
  final Widget? leading;
  final Widget? help;
  final Widget? media;
  final QuestionnaireItemModel questionnaireItemModel;
  final String htmlTitleText;

  const QuestionnaireItemFillerTitle._({
    required this.questionnaireItemModel,
    required this.htmlTitleText,
    this.leading,
    this.help,
    this.media,
    super.key,
  });

  static Widget? fromFillerItem({
    required FillerItemModel fillerItem,
    required QuestionnaireThemeData questionnaireTheme,
    Key? key,
  }) {
    final questionnaireItemModel = fillerItem.questionnaireItemModel;
    final text = questionnaireItemModel.text;

    if (text == null) {
      return null;
    } else {
      final leading =
          _QuestionnaireItemFillerTitleLeading.fromFillerItem(fillerItem);
      final help = _createHelp(questionnaireItemModel);
      final media =
          ItemMediaImage.fromItemMedia(questionnaireItemModel.itemMedia);

      final htmlTitleText = questionnaireTheme.fillerItemHtmlTitleRenderer(
          fillerItem: fillerItem);

      return QuestionnaireItemFillerTitle._(
        questionnaireItemModel: questionnaireItemModel,
        htmlTitleText: htmlTitleText,
        leading: leading,
        help: help,
        media: media,
        key: key,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final questionnaireTheme = QuestionnaireTheme.of(context);
    final hasInlinedMedia = questionnaireTheme.inlineItemMedia && media != null;
    final leadingWidget = leading;

    return questionnaireTheme.fillerItemTitleLayoutBuilder(
      context,
      questionnaireItemModel: questionnaireItemModel,
      contentWidget: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leadingWidget != null)
            leadingWidget
          else if (hasInlinedMedia)
            SizedBox(
              height: 24.0,
              child: media,
            ),
          if (leadingWidget != null || hasInlinedMedia)
            const SizedBox(width: 16.0),
          Expanded(
            child: HtmlWidget(
              htmlTitleText,
              textStyle: Theme.of(context).textTheme.bodyMedium,
              // Add any other HtmlWidget configurations you need
            ),
          ),
        ],
      ),
      mediaWidget: !questionnaireTheme.inlineItemMedia ? media : null,
      helpWidget: help,
    );
  }

  static Widget? _createHelp(
    QuestionnaireItemModel itemModel, {
    Key? key,
  }) {
    final helpItem = itemModel.helpTextItem;

    if (helpItem != null) {
      return _QuestionnaireItemFillerHelp(helpItem, key: key);
    }

    final supportLink = itemModel.questionnaireItem.extension_
        ?.extensionOrNull(
          'http://hl7.org/fhir/StructureDefinition/questionnaire-supportLink',
        )
        ?.valueUri
        ?.value;

    if (supportLink != null) {
      return _QuestionnaireItemFillerSupportLink(supportLink, key: key);
    }

    return null;
  }
}

class _QuestionnaireItemFillerHelp extends StatefulWidget {
  final QuestionnaireItemModel ql;

  const _QuestionnaireItemFillerHelp(this.ql, {super.key});

  @override
  State<StatefulWidget> createState() => _QuestionnaireItemFillerHelpState();
}

class _QuestionnaireItemFillerHelpState
    extends State<_QuestionnaireItemFillerHelp> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      mouseCursor: SystemMouseCursors.help,
      icon: const Icon(Icons.help),
      onPressed: () {
        _showHelp(context, widget.ql);
      },
    );
  }

  Future<void> _showHelp(
    BuildContext context,
    QuestionnaireItemModel questionnaireItemModel,
  ) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Help'),
          content: Xhtml.fromRenderingString(
            context,
            questionnaireItemModel.text ?? RenderingString.nullText,
            defaultTextStyle: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: <Widget>[
            OutlinedButton(
              onPressed: () {
                setState(() {
                  Navigator.pop(context);
                });
              },
              child: const Text('Dismiss'),
            ),
          ],
        );
      },
    );
  }
}

class _QuestionnaireItemFillerSupportLink extends StatelessWidget {
  static final _logger = Logger(_QuestionnaireItemFillerSupportLink);
  final Uri supportLink;

  const _QuestionnaireItemFillerSupportLink(this.supportLink, {super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      mouseCursor: SystemMouseCursors.help,
      icon: const Icon(Icons.help),
      onPressed: () {
        _logger.debug("supportLink '$supportLink'");
        QuestionnaireResponseFiller.of(context)
            .onLinkTap
            ?.call(context, supportLink);
      },
    );
  }
}

class _QuestionnaireItemFillerTitleLeading extends StatelessWidget {
  final Widget _leadingWidget;

  const _QuestionnaireItemFillerTitleLeading._(Widget leadingWidget)
      : _leadingWidget = leadingWidget;

  static Widget? fromFillerItem(
    FillerItemModel fillerItemModel, {
    // ignore: unused_element
    Key? key,
  }) {
    final displayCategory = fillerItemModel.questionnaireItem.extension_
        ?.extensionOrNull(
          'http://hl7.org/fhir/StructureDefinition/questionnaire-displayCategory',
        )
        ?.valueCodeableConcept
        ?.coding
        ?.firstOrNull
        ?.code
        ?.value;

    if (displayCategory == null) return null;

    final leadingWidget = (displayCategory == 'instructions')
        ? const Icon(Icons.info)
        : (displayCategory == 'security')
            ? const Icon(Icons.lock)
            : const Icon(Icons.help_center_outlined); // Error / unclear

    return _QuestionnaireItemFillerTitleLeading._(leadingWidget);
  }

  @override
  Widget build(BuildContext context) {
    return _leadingWidget;
  }
}
