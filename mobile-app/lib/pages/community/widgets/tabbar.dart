import 'package:flutter/material.dart';

class BuildTabBar extends StatefulWidget {
  final List<Widget> tabs;

  const BuildTabBar({super.key, required this.tabs});

  @override
  State<BuildTabBar> createState() => _BuildTabBarState();
}

class _BuildTabBarState extends State<BuildTabBar>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: widget.tabs.length, vsync: this)
      ..addListener(() {
        if (!tabController.indexIsChanging) {
          setState(() {});
        }
      });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: tabController,
      isScrollable: true,
      tabs: widget.tabs,
    );
  }
}
