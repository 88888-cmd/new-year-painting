import 'package:app/i18n/index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchGoodsPage extends StatefulWidget {
  const SearchGoodsPage({super.key});

  @override
  State<SearchGoodsPage> createState() => _SearchGoodsPageState();
}

class _SearchGoodsPageState extends State<SearchGoodsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(LocaleKeys.search.tr),
      ),
    );
  }
}
