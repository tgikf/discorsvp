import 'package:flutter/material.dart';

class PersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String _title;

  PersistentHeaderDelegate(this._title);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      color: Theme.of(context).colorScheme.surface,
      child: FittedBox(
        alignment: Alignment.centerLeft,
        fit: BoxFit.none,
        child: Text(_title, style: const TextStyle(fontSize: 23)),
      ),
    );
  }

  @override
  double get maxExtent => 60;

  @override
  double get minExtent => 60;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
