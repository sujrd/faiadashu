import 'package:faiadashu/l10n/src/fdash_localizations.g.dart';
import 'package:faiadashu/questionnaires/model/src/validation_errors/validation_error.dart';

class MaxLengthError extends ValidationError {
  final int maxLength;
  MaxLengthError(String nodeUid, this.maxLength) : super(nodeUid);

  @override
  String? getMessage(FDashLocalizations localizations) {
    return localizations.validatorMaxLength(maxLength);
  }
}
