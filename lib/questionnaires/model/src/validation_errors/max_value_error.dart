import 'package:faiadashu/l10n/src/fdash_localizations.g.dart';
import 'package:faiadashu/questionnaires/model/src/validation_errors/validation_error.dart';

class MaxValueError extends ValidationError {
  final String maxValue;
  MaxValueError(String nodeUid, this.maxValue) : super(nodeUid);

  @override
  String? getMessage(FDashLocalizations localizations) {
    return localizations.validatorMaxValue(maxValue);
  }
}
