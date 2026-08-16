import 'package:flutter/material.dart';

class GitHubLogo extends StatelessWidget {
  final double size;

  const GitHubLogo({
    super.key,
    this.size = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      'https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.terminal,
          size: size,
          color: Colors.black87,
        );
      },
    );
  }
}
