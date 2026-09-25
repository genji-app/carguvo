import 'package:flutter/material.dart';
import 'package:sun_sports/features/profile/deposit/presentation/widgets/codepay_container_section.dart';

class CodepayContainer extends StatefulWidget {
  const CodepayContainer({super.key});

  @override
  State<CodepayContainer> createState() => _CodepayContainerState();
}

class _CodepayContainerState extends State<CodepayContainer> {
  @override
  Widget build(BuildContext context) => const CodepayContainerSection();
}
