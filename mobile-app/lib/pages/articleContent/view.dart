import 'package:app/i18n/index.dart';
import 'package:app/pages/articleContent/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ArticleContentPage extends StatefulWidget {
  const ArticleContentPage({super.key});

  @override
  State<ArticleContentPage> createState() => _ArticleContentPageState();
}

class _ArticleContentPageState extends State<ArticleContentPage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ArticleContentController>(
      init: ArticleContentController(),
      builder: (controller) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(LocaleKeys.detail.tr),
        ),
        body: controller.isIniting
            ? Center(child: CircularProgressIndicator())
            : WebViewWidget(controller: controller.webViewController),
      ),
    );
  }
}
