import 'package:faiadashu/l10n/src/fdash_localizations.g.dart';
import 'package:faiadashu/questionnaires/model/src/validation_errors/validation_error.dart';
import 'package:filesize/filesize.dart';

class MaxSizeError extends ValidationError {
  final size;
  MaxSizeError(String nodeUid, this.size) : super(nodeUid);

  @override
  String? getMessage(FDashLocalizations localizations) {
    return localizations.validatorMaxSize(filesize(size));
  }
}
