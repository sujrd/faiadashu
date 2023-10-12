import 'package:faiadashu/l10n/src/fdash_localizations.g.dart';
import 'package:faiadashu/questionnaires/model/src/validation_errors/validation_error.dart';

class EntryFormatError extends ValidationError {
  final String entryFormat;

  const EntryFormatError(String nodeUid, this.entryFormat) : super(nodeUid);

  @override
  String? getMessage(FDashLocalizations localizations) {
    return localizations.validatorEntryFormat(entryFormat);
  }
}
