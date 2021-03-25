import 'dart:convert';

import 'package:fhir/r4.dart';
import 'package:flutter/material.dart';
import 'package:simple_html_css/simple_html_css.dart';
import 'package:widgets_on_fhir/questionnaires/model/model.dart';

import '../../util/safe_access_extensions.dart';

/// Build Widgets from Xhtml
class Xhtml {
  static Widget? buildFromString(
      BuildContext context, QuestionnaireTopLocation topLocation, String? xhtml,
      {Key? key}) {
    if (xhtml == null) {
      return null;
    }
    const imgBase64Prefix = "<img src='data:image/png;base64,";
    const imgHashPrefix = "<img src='#";
    const imgSuffix = "'/>";
    if (xhtml.startsWith(imgBase64Prefix)) {
      final base64String = xhtml.substring(
          imgBase64Prefix.length, xhtml.length - imgSuffix.length);
      return Image.memory(base64.decode(base64String));
    }
    if (xhtml.startsWith(imgHashPrefix)) {
      final base64Binary = topLocation.findContainedByElementId(xhtml.substring(
              imgHashPrefix.length, xhtml.length - imgSuffix.length + 1))
          as Binary?;
      final base64String = base64Binary?.data?.value;
      return Image.memory(base64.decode(base64String!));
    } else {
      return HTML.toRichText(context, xhtml);
    }
  }

  static Widget? buildFromExtension(BuildContext context,
      QuestionnaireTopLocation topLocation, List<FhirExtension>? extension,
      {Key? key}) {
    final xhtml = extension
        ?.extensionOrNull(
            'http://hl7.org/fhir/StructureDefinition/rendering-xhtml')
        ?.valueString;

    return Xhtml.buildFromString(context, topLocation, xhtml);
  }
}