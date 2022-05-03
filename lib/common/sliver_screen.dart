import 'package:flutter/material.dart';

class SliverScreen extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const SliverScreen({required this.title, required this.children, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    return CustomScrollView(slivers: [
      SliverAppBar(
          pinned: true,
          floating: true,
          snap: false,
          expandedHeight: 80.0,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.all(16),
            title: Text(title),
            background: Image(
                image: const AssetImage('assets/icon.png'),
                alignment: Alignment.center,
                color: Colors.white.withOpacity(0.75),
                colorBlendMode: BlendMode.modulate),
          )),
          SliverList(delegate: SliverChildListDelegate(children))
    ]);
  }
}
