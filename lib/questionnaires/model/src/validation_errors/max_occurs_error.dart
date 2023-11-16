import 'package:faiadashu/l10n/src/fdash_localizations.g.dart';
import 'package:faiadashu/questionnaires/model/src/validation_errors/validation_error.dart';

class MaxOccursError extends ValidationError {
  final int maxOccurs;
  MaxOccursError(super.nodeUid, this.maxOccurs);

  @override
  String? getMessage(FDashLocalizations localizations) {
    return localizations.validatorMaxOccurs(maxOccurs);
  }
}
