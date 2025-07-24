import 'package:flutter/material.dart';
import '../models/text_properties.dart';

/// Widget that displays a single moving text element
class MovingTextWidget extends StatelessWidget {
  final TextProperties textProps;
  final TextConfig textConfig;

  const MovingTextWidget({
    super.key,
    required this.textProps,
    required this.textConfig,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: textProps.x,
      top: textProps.y,
      child: Text(
        textProps.text,
        key: ValueKey('${textProps.text}-${textConfig.fontFamily}-${textConfig.fontSize}-${textConfig.isBold}'),
        style: textConfig.textStyle.copyWith(color: textProps.color),
      ),
    );
  }
}
