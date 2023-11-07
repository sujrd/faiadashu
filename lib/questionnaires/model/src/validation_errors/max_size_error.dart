import 'package:faiadashu/l10n/src/fdash_localizations.g.dart';
import 'package:faiadashu/questionnaires/model/src/validation_errors/validation_error.dart';
import 'package:filesize/filesize.dart';

class MaxSizeError extends ValidationError {
  final num size;
  MaxSizeError(super.nodeUid, this.size);

  @override
  String? getMessage(FDashLocalizations localizations) {
    return localizations.validatorMaxSize(filesize(size));
  }
}
