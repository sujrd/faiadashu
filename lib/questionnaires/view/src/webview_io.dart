import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:webview_flutter/webview_flutter.dart';

Widget createWebView(String xhtml, {Key? key}) =>
    Platform.isAndroid || Platform.isIOS
        ? _FullHtmlViewer(
            xhtml,
            key: key,
          )
        : _SimpleHtmlViewer(
            xhtml,
            key: key,
          );

class _FullHtmlViewer extends StatelessWidget {
  final String xhtml;

  const _FullHtmlViewer(this.xhtml, {super.key});

  @override
  Widget build(BuildContext context) {
    final dataUrl = Uri.dataFromString(
      xhtml,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    );

    final controller = WebViewController();
    controller.loadRequest(dataUrl);

    return SizedBox.expand(
      child: WebViewWidget(
        controller: controller,
      ),
    );
  }
}

class _SimpleHtmlViewer extends StatelessWidget {
  final String xhtml;

  const _SimpleHtmlViewer(this.xhtml, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: SingleChildScrollView(
        child: HtmlWidget(
          xhtml,
          textStyle: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
