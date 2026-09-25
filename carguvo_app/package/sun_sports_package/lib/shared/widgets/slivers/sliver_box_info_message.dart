import 'package:flutter/material.dart';
import 'package:sun_sports/shared/widgets/status_information/status_information.dart';

class SliverBoxInfoMessage extends StatelessWidget {
  const SliverBoxInfoMessage({
    super.key,
    this.image,
    this.primaryMessage,
    this.secondaryMessage,
  }) : assert(primaryMessage != null || secondaryMessage != null);

  final Widget? image;
  final Widget? primaryMessage;
  final Widget? secondaryMessage;

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
    child: InfoMessage(
      image: image,
      primaryMessage: primaryMessage,
      secondaryMessage: secondaryMessage,
    ),
  );
}
