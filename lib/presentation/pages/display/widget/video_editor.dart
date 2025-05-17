import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../assets/image.dart';

class MainFunction extends StatefulWidget {
  const MainFunction({super.key});

  @override
  State<MainFunction> createState() => _MainFunctionState();
}

class _MainFunctionState extends State<MainFunction> {
  final List<Map<String, String>> actions = [
    {'icon': 'filter', 'label': 'Filter'},
    {'icon': 'speed', 'label': 'Speed'},
    {'icon': 'volume', 'label': 'Volume'},
    {'icon': 'delete', 'label': 'Delete'},
    {'icon': 'rm_background', 'label': 'Remove Background'},
    {'icon': 'slipt', 'label': 'Split'},
    {'icon': 'trim', 'label': 'Trim'},
    {'icon': 'crop', 'label': 'Crop'},
    {'icon': 'component', 'label': 'Canvas'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      color: Colors.black, // Nền đen cho toàn bộ widget
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Card(
          color: const Color.fromARGB(255, 0, 0, 0), // Thẻ có nền tối
          elevation: 8,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 1.0),
            child: ListView(
              scrollDirection: Axis.horizontal, // Để listview cuộn ngang
              children: actions.map((action) {
                return _buildActionButton(
                  action['icon']!,
                  action['label']!,
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String iconName, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: () {
          // Thêm hành động khi nhấn vào nút
        },
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: SvgPicture.asset(
            _getIconPath(iconName),
            width: 60,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.9),
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  String _getIconPath(String iconName) {
    switch (iconName) {
      case 'component':
        return ImageUtils.component;
      case 'rm_background':
        return ImageUtils.rmBackground;
      case 'trim':
        return ImageUtils.trim;
      case 'slipt':
        return ImageUtils.slipt;
      case 'crop':
        return ImageUtils.crop;
      case 'filter':
        return ImageUtils.filter;
      case 'volume':
        return ImageUtils.volume;
      case 'speed':
        return ImageUtils.speed;
      case 'delete':
        return ImageUtils.delete;
      default:
        return ImageUtils.circle;
    }
  }
}
