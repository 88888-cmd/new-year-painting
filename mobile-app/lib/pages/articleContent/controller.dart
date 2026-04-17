import 'package:app/services/http.dart';
import 'package:app/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ArticleContentController extends GetxController {
  bool isIniting = true; // 是否初始化中

  String content = '';
  late WebViewController webViewController;

  @override
  void onInit() {
    super.onInit();

    isIniting = true;

    HttpService.to
        .get(
          'banner/getArticleContent',
          params: {'banner_id': Get.arguments['id']},
        )
        .then((result) {
          content = addImageUrlPrefix(result.data.toString());

          final fullHtml =
              '''
    <!DOCTYPE html>
    <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body { 
            padding-left: 10px;
            padding-right: 10px;
          }
          img { 
            max-width: 100%;
            height: auto;
          }
        </style>
      </head>
      <body>
        $content
      </body>
    </html>
    ''';

          webViewController = WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setBackgroundColor(Colors.transparent)
            ..loadHtmlString(fullHtml);

          isIniting = false;

          update();
        });
  }

  String addImageUrlPrefix(String htmlContent) {
    return htmlContent.replaceAllMapped(
      RegExp(r'<img\s+[^>]*src="([^"]+)"[^>]*>'),
      (match) {
        String src = match.group(1)!;
        if (src.startsWith('/') && !src.startsWith('//')) {
          return match
              .group(0)!
              .replaceFirst(src, '${Constants.mediaBaseUrl}$src');
        }
        return match.group(0)!;
      },
    );
  }
}
