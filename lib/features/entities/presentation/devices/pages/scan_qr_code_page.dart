import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:ionicons/ionicons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../main_screen/presentation/widgets/widgets.dart';


class ScanQrCodePage extends StatefulWidget {
  const ScanQrCodePage({super.key});

  @override
  State<ScanQrCodePage> createState() => _ScanQrCodePageState();
}

class _ScanQrCodePageState extends State<ScanQrCodePage> {
  MobileScannerController cameraController = MobileScannerController();

  bool processingCode = false;

  @override
  Widget build(BuildContext context) {
    final safePadding = MediaQuery.of(context).viewPadding;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) async {
              if (processingCode) {
                return;
              }
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                processingCode = true;
                final splittedStr = barcodes.first.rawValue!.split(';');
                if (splittedStr.length != 2) {
                  await MyDialogs.showErrorDialog(
                      context, 'invalidQrCode'.tr());
                  processingCode = false;
                } else {
                  Navigator.of(context, rootNavigator: true)
                      .pop(barcodes.first.rawValue);
                }
              }
            },
          ),
          Container(
            constraints: const BoxConstraints.expand(),
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: CustomPaint(
                size: Size(0.7, 0.7 * width),
                painter: OverlayPainter(),
              ),
            ),
          ),
          Positioned(
            right: 24,
            bottom: 80,
            child: IconButton(
              color: Colors.white,
              icon: ValueListenableBuilder(
                valueListenable: cameraController.torchState,
                builder: (context, state, child) {
                  switch (state) {
                    case TorchState.off:
                      return const Icon(Ionicons.flash_off_outline, color: Colors.grey);
                    case TorchState.on:
                      return const Icon(Ionicons.flash_outline, color: Colors.yellow);
                  }
                },
              ),
              iconSize: 32.0,
              onPressed: () => cameraController.toggleTorch(),
            ),
          ),
          Positioned(
            left: 24,
            bottom: 80,
            child: IconButton(
              color: Colors.white,
              icon: ValueListenableBuilder(
                valueListenable: cameraController.cameraFacingState,
                builder: (context, state, child) {
                  switch (state) {
                    case CameraFacing.front:
                      return const Icon(Ionicons.camera_outline);
                    case CameraFacing.back:
                      return const Icon(Ionicons.camera_reverse);
                  }
                },
              ),
              iconSize: 32.0,
              onPressed: () => cameraController.switchCamera(),
            ),
          ),
          Positioned(
              top: safePadding.top,
              left: 24,
              child: IconButton(
                onPressed: () {
                  context.pop();
                },
                icon: const Icon(
                  Ionicons.chevron_back_outline,
                  color: Colors.white,
                  size: 40,
                ),
              ))
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController.stop();
    cameraController.dispose();
    super.dispose();
  }
}

class OverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..blendMode = BlendMode.clear
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, 0.7 * size.width)
      ..lineTo(0.7 * size.width, 0.7 * size.width)
      ..lineTo(0.7 * size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
