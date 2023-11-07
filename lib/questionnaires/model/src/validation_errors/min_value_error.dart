import 'package:faiadashu/l10n/src/fdash_localizations.g.dart';
import 'package:faiadashu/questionnaires/model/src/validation_errors/validation_error.dart';

class MinValueError extends ValidationError {
  final String minValue;
  MinValueError(super.nodeUid, this.minValue);

  @override
  String? getMessage(FDashLocalizations localizations) {
    return localizations.validatorMinValue(minValue);
  }
}
