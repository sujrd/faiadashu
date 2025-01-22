import 'package:faiadashu/fhir_types/fhir_types.dart';
import 'package:faiadashu/logging/logging.dart';
import 'package:faiadashu/questionnaires/model/model.dart';
import 'package:fhir/r4.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

// OPTIMIZE: Can this wrapper around a child be avoided?

/// Display XHTML formatted texts.
@immutable
class Xhtml extends StatelessWidget {
  static final Logger _logger = Logger(Xhtml);

  final Widget _child;

  const Xhtml._(this._child);

  static const int defaultMaxLines = 5;

  factory Xhtml.fromPlainTextAndExtensions(
    BuildContext context,
    String plainText, {
    List<FhirExtension>? extensions,
    QuestionnaireModel? questionnaireModel,
    double? imageWidth,
    double? imageHeight,
    TextStyle? defaultTextStyle,
    Key? key,
  }) {
    final xhtmlString = RenderingString.fromText(
      plainText,
      locale: Localizations.localeOf(context),
      extensions: extensions,
    );

    return Xhtml.fromRenderingString(
      context,
      xhtmlString,
      questionnaireModel: questionnaireModel,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
      defaultTextStyle: defaultTextStyle,
      key: key,
    );
  }

  factory Xhtml.fromRenderingString(
    BuildContext context,
    RenderingString renderingString, {
    QuestionnaireModel? questionnaireModel,
    double? imageWidth,
    double? imageHeight,
    TextStyle? defaultTextStyle,
    int maxLines = defaultMaxLines,
    Key? key,
  }) {
    _logger.trace('enter fromRenderingString $renderingString');

    final xhtml = renderingString.xhtmlText;
    final plainText = renderingString.plainText;

    if (renderingString.isPlain) {
      return Xhtml._(
        Text(
          plainText,
          style: defaultTextStyle,
          semanticsLabel: plainText,
          key: key,
        ),
      );
    }

    final base64StringFromSrc = _extractBase64FromImgTag(xhtml);

    if (base64StringFromSrc != null) {
      return Xhtml._(
        Base64Image(
          base64StringFromSrc,
          width: imageWidth,
          height: imageHeight,
          semanticLabel: plainText,
          key: key,
        ),
      );
    }

    // TODO: Could this also have an alt tag?
    const imgHashPrefix = "<img src='#";
    if (xhtml.startsWith(imgHashPrefix)) {
      final elementId = xhtml.substring(
        imgHashPrefix.length,
        xhtml.lastIndexOf("'"),
      );
      if (questionnaireModel == null) {
        throw StateError(
          'questionnaireModel missing. Cannot resolve #$elementId.',
        );
      }

      final base64Binary =
          questionnaireModel.findContainedByElementId(elementId) as Binary?;
      final base64String = base64Binary?.data?.value;
      if (base64String == null) {
        throw QuestionnaireFormatException(
          'Malformed base64 string for image element ID $elementId',
          elementId,
        );
      }

      return Xhtml._(
        Base64Image(
          base64String,
          width: imageWidth,
          height: imageHeight,
          semanticLabel: plainText,
          key: key,
        ),
      );
    } else {
      return Xhtml._(
        HtmlWidget(
          xhtml,
          textStyle: defaultTextStyle ?? Theme.of(context).textTheme.bodyMedium,
          customStylesBuilder: (element) => {
            'display': '-webkit-box',
            '-webkit-line-clamp': maxLines.toString(),
            '-webkit-box-orient': 'vertical',
            'overflow': 'hidden',
            'text-overflow': 'ellipsis',
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _child;
  }

  static String? _extractBase64FromImgTag(String imgTag) {
    for (final contentType in [
      'image/png',
      'image/jpeg',
      'image/jpg',
    ]) {
      final scrAttribute = "src='data:$contentType;base64,";

      // Handle img tag with optional attributes, such as 'alt'.
      if (imgTag.startsWith('<img ') && imgTag.contains(scrAttribute)) {
        final srcAttributeIndex = imgTag.indexOf(scrAttribute);
        final base64String = imgTag.substring(
          srcAttributeIndex + scrAttribute.length,
          imgTag.indexOf("'", srcAttributeIndex + scrAttribute.length),
        );

        _logger.debug('Length of base64: ${base64String.length}');

        return base64String;
      }
    }

    return null;
  }
}
