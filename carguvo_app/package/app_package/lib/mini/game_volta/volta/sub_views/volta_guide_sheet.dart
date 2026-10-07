import 'package:flutter/material.dart';

import '../../common/volta_icons.dart';
import '../../common/widgets/volta_sheet_scaffold.dart';

class VoltaGuideSheet extends StatelessWidget {
  const VoltaGuideSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return VoltaSheetScaffold(
      title: 'Hướng dẫn',
      chrome: VoltaSheetChrome.panel,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: <Widget>[VoltaIcons.guideBackground()],
      ),
    );
  }
}
