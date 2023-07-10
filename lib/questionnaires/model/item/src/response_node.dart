import 'package:flutter/foundation.dart';

/// Commonalities between all nodes in the response tree.
///
/// Unifies certain aspects of groups and answers.
abstract class ResponseNode with Diagnosticable, ChangeNotifier {
  final ResponseNode? parentNode;
  late final ResponseNode? rootNode;

  late final String _nodeUid;

  /// Returns a unique id that identifies this item in a tree of response nodes.
  String get nodeUid => _nodeUid;

  ResponseNode(this.parentNode) {
    _nodeUid = calculateNodeUid();
    rootNode = parentNode?.rootNode ?? parentNode;
  }

  String calculateNodeUid();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);

    properties.add(StringProperty('nodeUid', nodeUid));
  }
}
