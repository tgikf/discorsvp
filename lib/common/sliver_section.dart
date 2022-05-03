import 'package:flutter/material.dart';

class SliverSection {
  SliverSection(
      {required this.sectionTitle,
      required this.children,
      this.showImage = false});

  String sectionTitle;
  List<Widget> children;
  bool showImage;
}
