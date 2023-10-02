import 'package:faiadashu/l10n/src/fdash_localizations.g.dart';
import 'package:faiadashu/questionnaires/model/src/validation_errors/validation_error.dart';

class DateTimeError extends ValidationError {
  DateTimeError(super.nodeUid);

  @override
  String? getMessage(FDashLocalizations localizations) {
    return localizations.validatorDateTime;
  }
}
