import 'package:faiadashu/l10n/src/fdash_localizations.g.dart';
import 'package:faiadashu/questionnaires/model/src/validation_errors/validation_error.dart';

class MaxValueError extends ValidationError {
  final String maxValue;
  MaxValueError(super.nodeUid, this.maxValue);

  @override
  String? getMessage(FDashLocalizations localizations) {
    return localizations.validatorMaxValue(maxValue);
  }
}
