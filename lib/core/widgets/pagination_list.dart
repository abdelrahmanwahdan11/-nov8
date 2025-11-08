import 'package:flutter/material.dart';

class PaginationList extends StatelessWidget {
  const PaginationList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.onLoadMore,
    required this.isLoading,
    this.controller,
    this.header,
    this.padding,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final VoidCallback onLoadMore;
  final bool isLoading;
  final ScrollController? controller;
  final Widget? header;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (!isLoading && notification.metrics.pixels >= notification.metrics.maxScrollExtent - 200) {
          onLoadMore();
        }
        return false;
      },
      child: ListView.builder(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: padding,
        itemCount: itemCount + (isLoading ? 1 : 0) + (header != null ? 1 : 0),
        itemBuilder: (context, index) {
          if (header != null && index == 0) {
            return header!;
          }
          final dataIndex = index - (header != null ? 1 : 0);
          if (dataIndex >= itemCount) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return itemBuilder(context, dataIndex);
        },
      ),
    );
  }
}
