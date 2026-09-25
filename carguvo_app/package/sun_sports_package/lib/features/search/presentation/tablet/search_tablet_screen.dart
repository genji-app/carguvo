import 'package:flutter/material.dart';
import 'package:sun_sports/features/search/presentation/widgets/search_dialog.dart';

class SearchTabletScreen extends StatefulWidget {
  const SearchTabletScreen({super.key});

  @override
  State<SearchTabletScreen> createState() => _SearchTabletScreenState();
}

class _SearchTabletScreenState extends State<SearchTabletScreen> {
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
