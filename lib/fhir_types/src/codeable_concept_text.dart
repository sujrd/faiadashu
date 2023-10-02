import 'package:faiadashu/fhir_types/fhir_types.dart';
import 'package:fhir/r4.dart';
import 'package:flutter/material.dart';

class CodeableConceptText extends StatelessWidget {
  final CodeableConcept codeableConcept;
  final TextStyle? style;

  const CodeableConceptText(
    this.codeableConcept, {
    this.style,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      codeableConcept.localizedDisplay(Localizations.localeOf(context)),
      style: style,
    );
  }
}
