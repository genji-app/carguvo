import 'package:flutter/material.dart';
import 'package:sun_sports/shared/responsive/responsive_builder.dart';
import 'package:sun_sports/shared/widgets/buttons/sound_tap.dart';

class SportTabletSidebar extends StatelessWidget {
  const SportTabletSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final sidebarWidth = ResponsiveBuilder.responsive<double>(
      context,
      mobile: 200.0,
      tablet: 200.0,
      desktop: 236.0,
    );

    return Container(
      width: sidebarWidth,
      color: Colors.white,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: _TabButton(
                        label: 'Thể thao',
                        isActive: true,
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: _TabButton(
                        label: 'Casino',
                        isActive: false,
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ),
              _MenuSection(
                items: [
                  _MenuItem(icon: Icons.home, label: 'Tất cả thể thao'),
                  _MenuItem(icon: Icons.play_circle, label: 'Đang chơi'),
                  _MenuItem(icon: Icons.schedule, label: 'Sắp diễn ra'),
                  _MenuItem(icon: Icons.receipt, label: 'Cược của tôi'),
                  _MenuItem(icon: Icons.star, label: 'Top giải đấu'),
                  _MenuItem(icon: Icons.event, label: 'Sự kiện'),
                  _MenuItem(icon: Icons.sports_volleyball, label: 'Volta'),
                ],
              ),
              Divider(height: 1, color: Colors.grey[300]),
              _MenuSection(
                title: 'Thể loại',
                items: [
                  _MenuItem(icon: Icons.sports_soccer, label: 'Bóng đá'),
                  _MenuItem(icon: Icons.sports_tennis, label: 'Quần vợt'),
                  _MenuItem(icon: Icons.sports_basketball, label: 'Bóng rổ'),
                  _MenuItem(icon: Icons.sports, label: 'Bóng bàn'),
                  _MenuItem(
                    icon: Icons.sports_volleyball,
                    label: 'Bóng chuyền',
                  ),
                ],
              ),
              Divider(height: 1, color: Colors.grey[300]),
              Padding(
                padding: const EdgeInsets.all(8),
                child: _MenuTile(
                  item: _MenuItem(icon: Icons.download, label: 'Tải app'),
                ),
              ),
              Divider(height: 1, color: Colors.grey[300]),
              _MenuSection(
                items: [
                  _MenuItem(icon: Icons.chat, label: 'Live chat'),
                  _MenuItem(icon: Icons.swap_horiz, label: 'Hướng dẫn'),
                  _MenuItem(icon: Icons.info, label: 'Troll thể thao'),
                  _MenuItem(icon: Icons.article, label: 'Nhận định'),
                  _MenuItem(icon: Icons.help, label: 'Hỗ trợ'),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: _MenuTile(
                  item: _MenuItem(icon: Icons.settings, label: 'Cài đặt'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    Key? key,
    required this.label,
    required this.isActive,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: SoundTap.wrap(onTap),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: isActive ? Colors.orange[50] : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: isActive ? Border.all(color: Colors.orange, width: 1) : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? Colors.orange : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String? title;
  final List<_MenuItem> items;

  const _MenuSection({Key? key, this.title, required this.items})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              title!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
        ...items.map((item) => _MenuTile(item: item)),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final _MenuItem item;

  const _MenuTile({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: SoundTap.wrap(() {}),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            Icon(item.icon, size: 18, color: Colors.grey[700]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(fontSize: 11, color: Colors.grey[800]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;

  _MenuItem({required this.icon, required this.label});
}
