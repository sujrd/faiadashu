import 'package:faiadashu/faiadashu.dart';
import 'package:html/parser.dart' as htmlp;
import 'package:html/dom.dart' as dom;

/// Configuration for HTML title rendering
class HtmlTitleConfig {
  final String requiredMarker;
  final String requiredStyle;
  final String? groupPrefix;
  final String groupOpenTag;
  final String groupCloseTag;
  final String questionOpenTag;
  final String questionCloseTag;
  final String displayOpenTag;
  final String displayCloseTag;

  const HtmlTitleConfig({
    this.requiredMarker = ' *',
    this.requiredStyle = 'color:red;font-weight:bold;',
    this.groupPrefix,
    this.groupOpenTag = '<h2>',
    this.groupCloseTag = '</h2>',
    this.questionOpenTag = '<b>',
    this.questionCloseTag = '</b>',
    this.displayOpenTag = '<p>',
    this.displayCloseTag = '</p>',
  });
}

/// Basic configuration that matches the legacy default renderer
const basicHtmlTitleConfig = HtmlTitleConfig();

/// Renders HTML title for questionnaire items with configurable styling
String renderHtmlTitle({
  required FillerItemModel fillerItem,
  HtmlTitleConfig config = basicHtmlTitleConfig,
}) {
  final q = fillerItem.questionnaireItemModel;
  final isRequired = q.isRequired;
  final prefix = fillerItem.prefix?.xhtmlText;
  final titleHtml = q.text?.xhtmlText ?? '';

  // Build the raw fragment
  String raw = titleHtml;

  // Add group prefix if configured
  if (q.isGroup && config.groupPrefix != null) {
    raw = '${config.groupPrefix}$raw';
  }

  // Add prefix if present
  if (prefix != null) {
    raw = '$prefix&nbsp;$raw';
  }

  // Process the HTML fragment (convert styles, add required marker)
  final processed = postProcessXhtmlFragment(
    raw,
    isRequired: isRequired,
    requiredMarker: config.requiredMarker,
    requiredStyle: config.requiredStyle,
  );

  // Wrap with appropriate tags
  final openTag = q.isGroup
      ? config.groupOpenTag
      : q.isQuestion
          ? config.questionOpenTag
          : config.displayOpenTag;

  final closeTag = q.isGroup
      ? config.groupCloseTag
      : q.isQuestion
          ? config.questionCloseTag
          : config.displayCloseTag;

  return '$openTag$processed$closeTag';
}

/// Converts inline text-align styles to legacy align=""
/// and appends a required marker at the very end (if required),
/// ensuring it stays on the same line as the last text.
String postProcessXhtmlFragment(
  String input, {
  required bool isRequired,
  String requiredMarker = ' *',
  String requiredStyle = 'color:red;font-weight:bold;',
}) {
  if (input.trim().isEmpty) {
    if (isRequired) {
      return '<span style="$requiredStyle">$requiredMarker</span>';
    }
    return input;
  }

  // Parse as a fragment because input is not a full HTML document.
  final frag = htmlp.parseFragment(input);

  // 1) Convert style="text-align: X" -> align="X"
  void convertAlign(dom.Element el) {
    final style = el.attributes['style'];
    if (style == null || style.isEmpty) return;

    final parts = style
        .split(';')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    String? align;
    final kept = <String>[];

    for (final p in parts) {
      final m = RegExp(
        r'^text-align\s*:\s*(left|right|center|justify)$',
        caseSensitive: false,
      ).firstMatch(p);
      if (m != null) {
        align = m.group(1)!.toLowerCase();
      } else {
        kept.add(p);
      }
    }

    if (align != null) {
      el.attributes['align'] = align;
    }

    if (kept.isEmpty) {
      el.attributes.remove('style');
    } else {
      el.attributes['style'] = kept.join('; ');
    }
  }

  void walk(dom.Node n) {
    if (n is dom.Element) {
      convertAlign(n);
      for (final c in n.nodes) {
        walk(c);
      }
    }
  }

  for (final n in frag.nodes) {
    walk(n);
  }

  // 2) Append the required marker inside the last inline context
  if (isRequired) {
    // Find the last non-whitespace node in the fragment.
    dom.Node? last = _findLastContentNode(frag.nodes);
    if (last == null) {
      // No content: just create a span with marker
      final span = dom.Element.tag('span')
        ..attributes['style'] = requiredStyle
        ..text = requiredMarker;
      frag.append(span);
    } else if (last is dom.Text) {
      // Append a span after the last text node
      final parent = last.parent;
      if (parent != null) {
        final idx = parent.nodes.indexOf(last);
        final span = dom.Element.tag('span')
          ..attributes['style'] = requiredStyle
          ..text = requiredMarker;
        parent.nodes.insert(idx + 1, span);
      } else {
        // Rare: text node directly in fragment
        frag.append(dom.Element.tag('span')
          ..attributes['style'] = requiredStyle
          ..text = requiredMarker);
      }
    } else if (last is dom.Element) {
      // Place the marker as the last child of that element
      last.nodes.add(dom.Element.tag('span')
        ..attributes['style'] = requiredStyle
        ..text = requiredMarker);
    }
  }

  // Return the updated fragment HTML
  return frag.outerHtml;
}

// Find deepest, last meaningful content node (prefers text, otherwise last element)
dom.Node? _findLastContentNode(List<dom.Node> nodes) {
  for (int i = nodes.length - 1; i >= 0; i--) {
    final n = nodes[i];
    if (n is dom.Text) {
      if (n.text.trim().isNotEmpty) return n;
      // keep scanning upwards for non-whitespace
    } else if (n is dom.Element) {
      // Dive into element children first
      final deep = _findLastContentNode(n.nodes);
      if (deep != null) return deep;
      // If element has no texty children, use the element itself
      return n;
    }
  }
  return null;
}
