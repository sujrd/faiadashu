import 'package:faiadashu/l10n/src/fdash_localizations.g.dart';
import 'package:faiadashu/questionnaires/model/src/validation_errors/validation_error.dart';

class SingleSelectionOrOpenStringError extends ValidationError {
  final String? openLabel;
  SingleSelectionOrOpenStringError(
    super.nodeUid,
    this.openLabel,
  );

  @override
  String? getMessage(FDashLocalizations localizations) {
    return localizations.validatorSingleSelectionOrSingleOpenString(
      openLabel ?? localizations.fillerOpenCodingOtherLabel,
    );
  }
}
