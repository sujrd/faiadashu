import 'package:faiadashu/l10n/src/fdash_localizations.g.dart';
import 'package:faiadashu/questionnaires/model/src/validation_errors/validation_error.dart';

class RequiredItemError extends ValidationError {
  RequiredItemError(super.nodeUid);

  @override
  String? getMessage(FDashLocalizations localizations) {
    return localizations.validatorRequiredItem;
  }
}
