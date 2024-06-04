// custom_list_tile.dart

import 'package:elbi_donation_system/textstyles.dart';
import 'package:flutter/material.dart';

class EDSDonationTile extends StatelessWidget {
  final String image;
  final String status;
  final String orgDonor;
  final String orgName;

  const EDSDonationTile(
      {super.key,
      required this.image,
      required this.status,
      required this.orgDonor,
      required this.orgName});

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
              backgroundImage: NetworkImage(image),
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
              status,
              style: textStyles.title,
            ),
            subtitle: Text(
              orgDonor,
            ),
            trailing: const Icon(Icons.delete),
          ),
        ),
      ),
    );
  }
}
