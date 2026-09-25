import 'package:flutter/material.dart';
import 'package:sun_sports/features/search/presentation/widgets/search_dialog.dart';

class SearchDesktopScreen extends StatefulWidget {
  const SearchDesktopScreen({super.key});

  @override
  State<SearchDesktopScreen> createState() => _SearchDesktopScreenState();
}

class _SearchDesktopScreenState extends State<SearchDesktopScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showDialog());
  }

  Future<void> _showDialog() async {
    if (!mounted) return;
    await SearchDialog.show(context);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
