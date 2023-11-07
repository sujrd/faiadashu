import 'package:faiadashu/l10n/l10n.dart';

abstract class ValidationError {
  final String nodeUid;

  const ValidationError(this.nodeUid);

  String? getMessage(FDashLocalizations localizations);
}
