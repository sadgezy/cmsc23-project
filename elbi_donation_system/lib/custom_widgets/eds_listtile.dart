// custom_list_tile.dart

import 'package:elbi_donation_system/textstyles.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_svg/svg.dart';

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
              child: path.extension(logoUrl).toLowerCase().contains('.svg')
                  ? ClipOval(
                      child: SvgPicture.network(
                        logoUrl,
                        placeholderBuilder: (BuildContext context) => Container(
                          padding: const EdgeInsets.all(30.0),
                          child: const CircularProgressIndicator(),
                        ),
                      ),
                    )
                  : Image.network(
                      fit: BoxFit.cover,
                      scale: 1.5,
                      logoUrl,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),
            ),
            title: Text(
              title,
              style: textStyles.title,
            ),
            subtitle: Text(
              subtitle,
              style: AppTextStyles.subtitle,
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
        ),
      ),
    );
  }
}
