import 'package:faiadashu/fhir_types/fhir_types.dart';
import 'package:fhir/primitive_types/date_time.dart';
import 'package:flutter/material.dart';

import 'exhibit_page.dart';

class PrimitivePage extends ExhibitPage {
  const PrimitivePage({super.key});

  @override
  Widget buildExhibit(BuildContext context) {
    return Column(
      children: [
        Text('Default locale', style: Theme.of(context).textTheme.titleLarge),
        FhirDateTimeText(FhirDateTime('2002-02-05')),
        FhirDateTimeText(FhirDateTime('2010-02-05 14:02')),
        FhirDateTimeText(FhirDateTime('2010-02')),
        const Spacer(),
        Text('Germany', style: Theme.of(context).textTheme.titleLarge),
        Localizations.override(
          context: context,
          locale: const Locale.fromSubtags(
            languageCode: 'de',
            countryCode: 'DE',
          ),
          child: FhirDateTimeText(
            FhirDateTime('2010-02-05 14:02'),
          ),
        ),
        const Spacer(),
        Text('Japan', style: Theme.of(context).textTheme.titleLarge),
        Localizations.override(
          context: context,
          locale: const Locale.fromSubtags(
            languageCode: 'ja',
            countryCode: 'JP',
          ),
          child: FhirDateTimeText(
            FhirDateTime('2010-02'),
          ),
        ),
        Localizations.override(
          context: context,
          locale: const Locale.fromSubtags(
            languageCode: 'ja',
            countryCode: 'JP',
          ),
          child: FhirDateTimeText(
            FhirDateTime('2010-02-05 14:02'),
          ),
        ),
        const Spacer(),
        Text('Bahrain', style: Theme.of(context).textTheme.titleLarge),
        Localizations.override(
          context: context,
          locale: const Locale.fromSubtags(
            languageCode: 'ar',
            countryCode: 'BH',
          ),
          child: FhirDateTimeText(
            FhirDateTime('2010-02-05 14:02'),
          ),
        ),
      ],
    );
  }

  @override
  String get title => 'Primitives';
}
