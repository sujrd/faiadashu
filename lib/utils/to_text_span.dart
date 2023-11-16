import 'package:flutter/material.dart';
import 'package:simple_html_css/simple_html_css.dart';

TextSpan toTextSpan(BuildContext context, String htmlContent, {
  TextStyle? defaultTextStyle,
}) {
  // Workaround for addressing parsing issues with `<` and `&lt;` characters
  // in the simple_html_css package. Please remove when this is fixed.
  // References:
  // - https://github.com/ali-thowfeek/simple_html_css_flutter/issues/17
  // - https://github.com/sujrd/faiadashu/issues/48#issuecomment-1770704996
  return HTML.toTextSpan(
    context,
    htmlContent
      // Replace `&lt;` with `&amp;lt;`.
      // Once unescaping is performed in https://github.com/ali-thowfeek/simple_html_css_flutter/blob/main/lib/src/html_stylist.dart#L76
      // `&amp;lt;` should go back to `&lt;` allowing it to be parsed correctly as an HTML escaped entity.
      .replaceAll('&lt;', '&amp;lt;')
      .replaceAll('&gt;', '&amp;gt;'),
    defaultTextStyle: defaultTextStyle,
  );
}
