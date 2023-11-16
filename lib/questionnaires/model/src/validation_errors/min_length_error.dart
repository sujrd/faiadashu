import 'package:faiadashu/l10n/src/fdash_localizations.g.dart';
import 'package:faiadashu/questionnaires/model/src/validation_errors/validation_error.dart';

class MinLengthError extends ValidationError {
  final int minLength;
  MinLengthError(super.nodeUid, this.minLength);

  @override
  String? getMessage(FDashLocalizations localizations) {
    return localizations.validatorMinLength(minLength);
  }
}
