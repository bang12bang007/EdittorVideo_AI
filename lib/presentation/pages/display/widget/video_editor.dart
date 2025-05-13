import 'package:flutter/material.dart';

class MainFunction extends StatefulWidget {
  const MainFunction({super.key});

  @override
  State<MainFunction> createState() => _MainFunctionState();
}

class _MainFunctionState extends State<MainFunction> {
  final List<Map<String, String>> actions = [
    {'icon': 'volume_mute', 'label': 'Tắt âm'},
    {'icon': 'content_cut_sharp', 'label': 'Cắt'},
    {'icon': 'music_note_sharp', 'label': 'Nhạc nền'},
    {'icon': 'text_increase_rounded', 'label': 'Chữ'},
    {'icon': 'auto_awesome_rounded', 'label': 'Hiệu ứng'}
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
          elevation: 6,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: ListView(
              scrollDirection: Axis.horizontal, // Để listview cuộn ngang
              children: actions.map((action) {
                return _buildActionButton(
                  _getIconData(action['icon']!), // Lấy icon từ map
                  action['label']!,
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  // Hàm lấy icon từ tên icon
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'volume_mute':
        return Icons.volume_mute;
      case 'content_cut_sharp':
        return Icons.content_cut_sharp;
      case 'music_note_sharp':
        return Icons.music_note_sharp;
      case 'text_increase_rounded':
        return Icons.text_increase_rounded;
      case 'auto_awesome_rounded':
        return Icons.auto_awesome_rounded;
      default:
        return Icons
            .help_outline; // Nếu không tìm thấy thì trả về icon mặc định
    }
  }

  Widget _buildActionButton(IconData icon, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: () {
          // Thêm hành động khi nhấn vào nút
        },
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Icon(
            icon,
            size: 30,
            color: Colors.white.withOpacity(0.9), // Màu icon sáng hơn
          ),
        ),
      ),
    );
  }
}
