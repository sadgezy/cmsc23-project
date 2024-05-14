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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SizedBox(
        height: 100,
        child: Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                logoUrl,
              ),
            ),
            title: Text(
              title,
              style: AppTextStyles.title,
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
