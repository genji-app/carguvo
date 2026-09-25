import 'package:flutter/material.dart';
import 'package:sun_sports/features/profile/deposit/presentation/widgets/bank_container_section.dart';

class BankContainer extends StatefulWidget {
  const BankContainer({super.key});

  @override
  State<BankContainer> createState() => _BankContainerState();
}

class _BankContainerState extends State<BankContainer> {
  @override
  Widget build(BuildContext context) => const BankContainerSection();
}
