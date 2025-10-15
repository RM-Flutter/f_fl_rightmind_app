import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cpanal/constants/app_colors.dart';

import '../constants/app_sizes.dart';

class TemplatePage extends StatelessWidget {
  final String title;
  final Widget body;
  final Widget? widget;
  final List<Widget>? actions;
  final BuildContext pageContext;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottomAppbarWidget;
  final Widget? bottomNavigationBar;

  /// used if you want to active [PULLTOREFRESH] option to page.
  final Future<void> Function()? onRefresh;
  const TemplatePage(
      {super.key,
      this.actions,
      this.widget,
      this.bottomNavigationBar,
      this.bottomAppbarWidget,
      this.backgroundColor,
      required this.pageContext,
      required this.title,
      required this.body,
      this.floatingActionButton,
      this.onRefresh});

  @override
  Widget build(context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      appBar: AppBar(
        actions: actions,
        backgroundColor:
            backgroundColor ?? Theme.of(pageContext).scaffoldBackgroundColor,
        title: widget ?? Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(AppColors.dark)
          ),
        ),
        bottom: bottomAppbarWidget,
        leading: Padding(
          padding: const EdgeInsets.all(AppSizes.s10),
          child: InkWell(
            onTap: () {
              if(context.canPop()){
                context.pop(context);
              }else{
                Navigator.pop(context);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(AppColors.dark)),
              child: const Icon(
                Icons.arrow_back_sharp,
                color: Colors.white,
                size: AppSizes.s18,
              ),
            ),
          ),
        )
      ),
      body: onRefresh != null
          ? RefreshIndicator.adaptive(
              onRefresh: onRefresh!,
              child: ListView(
                children: [
                  body,
                ],
              ),
            )
          : body,
    );
  }
}
