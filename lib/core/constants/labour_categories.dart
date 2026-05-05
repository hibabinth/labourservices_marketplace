import 'package:flutter/material.dart';

class LabourCategory {
  final String key;
  final String title;
  final IconData icon;

  const LabourCategory({
    required this.key,
    required this.title,
    required this.icon,
  });
}

class LabourCategories {
  static const List<LabourCategory> all = [
    LabourCategory(key: 'mason', title: 'Mason', icon: Icons.foundation),
    LabourCategory(key: 'carpenter', title: 'Carpenter', icon: Icons.carpenter),
    LabourCategory(key: 'painter', title: 'Painter', icon: Icons.format_paint),
    LabourCategory(key: 'plumber', title: 'Plumber', icon: Icons.plumbing),
    LabourCategory(
      key: 'electrician',
      title: 'Electrician',
      icon: Icons.electrical_services,
    ),
    LabourCategory(key: 'welder', title: 'Welder', icon: Icons.construction),
    LabourCategory(
      key: 'tile_worker',
      title: 'Tile Worker',
      icon: Icons.grid_view,
    ),
    LabourCategory(
      key: 'roof_worker',
      title: 'Roof Worker',
      icon: Icons.roofing,
    ),
    LabourCategory(
      key: 'cleaner',
      title: 'Cleaner',
      icon: Icons.cleaning_services,
    ),
    LabourCategory(key: 'gardener', title: 'Gardener', icon: Icons.yard),
    LabourCategory(
      key: 'helper',
      title: 'General Helper',
      icon: Icons.handyman,
    ),
    LabourCategory(key: 'driver', title: 'Driver', icon: Icons.local_shipping),
  ];
}
