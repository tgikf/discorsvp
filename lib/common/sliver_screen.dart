import 'package:discorsvp/common/sliver_section.dart';
import 'package:flutter/material.dart';

import 'persistent_header_delegate.dart';

class SliverScreen extends StatelessWidget {
  final List<SliverSection> sections;
  const SliverScreen({required this.sections, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> slivers = [];
    bool addAppBar = true;
    for (int i = 0; i < sections.length; i++) {
      //the title of the first section will be used as app bar title
      if (addAppBar) {
        slivers.add(SliverAppBar(
            pinned: true,
            floating: true,
            snap: false,
            expandedHeight: 80.0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.all(16),
              title: Text(sections[i].sectionTitle),
              background: Image(
                  image: const AssetImage('assets/icon.png'),
                  alignment: Alignment.center,
                  color: Colors.white.withOpacity(0.75),
                  colorBlendMode: BlendMode.modulate),
            )));
        addAppBar = false;
      } else {
        slivers.add(SliverPersistentHeader(
            pinned: true,
            floating: false,
            delegate: PersistentHeaderDelegate(sections[i].sectionTitle)));
      }
      slivers.add(
          SliverList(delegate: SliverChildListDelegate(sections[i].children)));
    }
    return CustomScrollView(slivers: slivers);
  }
}
