import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Make sure you have this package imported

class FullScreenQrDialog extends StatelessWidget {
  final String qrData;

  const FullScreenQrDialog({super.key, required this.qrData});

  @override
  Widget build(BuildContext context) {
    // Determine a suitable size for the QR code to fill most of the screen
    final double dialogSize =
        MediaQuery.of(context).size.shortestSide * 0.8; // 80% of the shortest side

    return AlertDialog(
      // Remove default padding and shape to allow the content to take up more space
      insetPadding: const EdgeInsets.all(20.0),
      // Adjust this to control how much space it takes from edges
      contentPadding: EdgeInsets.zero,
      // Remove inner padding
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: Colors.white,

      // Or Get.theme.canvasColor
      content: Container(
        width: dialogSize,
        height: dialogSize,
        padding: const EdgeInsets.all(20.0), // Add padding inside the container
        child: Column(
          mainAxisSize: MainAxisSize.min, // Keep column tight to its children
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, size: 30),
                onPressed: () {
                  Get.back(); // Close the dialog
                },
              ),
            ),
            Expanded(
              // Allow QR image to expand
              child: Center(
                // Center the QR code within the available space
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: dialogSize * 0.8,
                  // Make QR slightly smaller than container to allow for padding
                  errorStateBuilder: (cxt, err) {
                    return const Center(
                      child: Text(
                        'Uh oh! Something went wrong :(',
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                  // You can add foregroundColor and backgroundColor if needed
                  // foregroundColor: Colors.black,
                  // backgroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Scan this QR Code',
              style: Get.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
