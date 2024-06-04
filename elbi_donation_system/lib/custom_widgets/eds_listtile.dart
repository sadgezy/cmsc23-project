// custom_list_tile.dart

import 'package:elbi_donation_system/textstyles.dart';
import 'package:flutter/material.dart';

class EDSListTile extends StatelessWidget {
  final String logoUrl;
  final String title;
  final String subtitle;

  const EDSListTile({
    super.key,
    required this.logoUrl,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final textStyles = AppTextStyles(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SizedBox(
        height: 125,
        child: Center(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.transparent,
              backgroundImage: NetworkImage(logoUrl),
              // child: Image.network(
              //   fit: BoxFit.cover,
              //   scale: 1.5,
              //   logoUrl,
              //   loadingBuilder: (BuildContext context, Widget child,
              //       ImageChunkEvent? loadingProgress) {
              //     if (loadingProgress == null) return child;
              //     return Center(
              //       child: CircularProgressIndicator(
              //         value: loadingProgress.expectedTotalBytes != null
              //             ? loadingProgress.cumulativeBytesLoaded /
              //                 loadingProgress.expectedTotalBytes!
              //             : null,
              //       ),
              //     );
              //   },
              // ),
            ),
            title: Text(
              title,
              style: textStyles.title,
            ),
            subtitle: Text(
              subtitle,
              style: AppTextStyles.subtitle,
            ),
            // trailing: const Icon(Icons.delete),
          ),
        ),
      ),
    );
  }
}
