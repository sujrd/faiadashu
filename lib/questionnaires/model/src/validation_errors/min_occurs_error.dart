import 'package:faiadashu/l10n/src/fdash_localizations.g.dart';
import 'package:faiadashu/questionnaires/model/src/validation_errors/validation_error.dart';

class MinOccursError extends ValidationError {
  final int minOccurs;
  MinOccursError(super.nodeUid, this.minOccurs);

  @override
  String? getMessage(FDashLocalizations localizations) {
    return localizations.validatorMinOccurs(minOccurs);
  }
}
