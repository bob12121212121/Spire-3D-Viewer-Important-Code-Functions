import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spire Virtual Viewer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const ScannerScreen(),
    );
  }
}

// ─── Screen 1: QR Code Scanner ───────────────────────────────────────────────

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  bool _isNavigating = false;
  bool _isMatchFound = false;
  String? _lastScannedCode;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/logo.png', height: 40),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final scanWindow = Rect.fromCenter(
            center: Offset(
              constraints.maxWidth / 2,
              (constraints.maxHeight / 2) - 40,
            ),
            width: 180,
            height: 180,
          );
          return Stack(
            children: [
              MobileScanner(
                scanWindow: scanWindow,
                errorBuilder: (context, error) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.redAccent,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Scanner Error',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Could not initialize the camera or barcode scanner (${error.errorCode.name}). Please check camera permissions or restart the app.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                onDetect: (capture) async {
                  if (_isNavigating) return;
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    final String? code = barcode.rawValue;
                    if (code != null) {
                      setState(() {
                        _lastScannedCode = code;
                      });

                      if (code.trim().toLowerCase().contains(
                        "spire.com/meter/280w-tap",
                      )) {
                        setState(() {
                          _isNavigating = true;
                          _isMatchFound = true;
                        });
                        _animationController.stop();

                        await Future.delayed(
                          const Duration(milliseconds: 1500),
                        );
                        if (!mounted) return;

                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (context) => const ModelViewerScreen(),
                              ),
                            )
                            .then((_) {
                              if (mounted) {
                                setState(() {
                                  _isNavigating = false;
                                  _isMatchFound = false;
                                  _lastScannedCode = null;
                                });
                                _animationController.repeat(reverse: true);
                              }
                            });
                        break;
                      }
                    }
                  }
                },
              ),
              // White background overlay with transparent 180x180 hole
              Positioned.fill(
                child: CustomPaint(
                  painter: WhiteOverlayPainter(boxRect: scanWindow),
                ),
              ),
              // Target Box Overlay
              Positioned(
                left: (constraints.maxWidth - 180) / 2,
                top: ((constraints.maxHeight - 180) / 2) - 40,
                width: 180,
                height: 180,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: CornerPainter(
                          color: _isMatchFound
                              ? Colors.green.shade600
                              : Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.8),
                          strokeWidth: _isMatchFound ? 6.0 : 4.0,
                          cornerLength: 25.0,
                          borderRadius: 12.0,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          children: [
                            if (_isMatchFound)
                              Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(20),
                                  child: const Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.green,
                                    size: 72,
                                  ),
                                ),
                              )
                            else
                              AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  final isReversing =
                                      _animationController.status ==
                                      AnimationStatus.reverse;
                                  final topPos = isReversing
                                      ? (_animationController.value * 180)
                                      : (_animationController.value * 180) - 60;

                                  return Positioned(
                                    top: topPos,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      height: 60,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: isReversing
                                              ? Alignment.bottomCenter
                                              : Alignment.topCenter,
                                          end: isReversing
                                              ? Alignment.topCenter
                                              : Alignment.bottomCenter,
                                          colors: [
                                            Colors.lightBlueAccent.withOpacity(
                                              0.0,
                                            ),
                                            Colors.lightBlueAccent.withOpacity(
                                              0.5,
                                            ),
                                          ],
                                        ),
                                      ),
                                      child: Align(
                                        alignment: isReversing
                                            ? Alignment.topCenter
                                            : Alignment.bottomCenter,
                                        child: Container(
                                          height: 3,
                                          decoration: BoxDecoration(
                                            color: Colors.lightBlueAccent,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.lightBlueAccent
                                                    .withOpacity(0.8),
                                                blurRadius: 8,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Scanned Text Overlay
              Positioned(
                bottom: 50,
                left: 24,
                right: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isMatchFound) ...[
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 36,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Meter Verified!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Opening 3D Model...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ] else ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Image.asset('assets/logo.png', height: 32),
                        ),
                        const Text(
                          'Point camera at a meter QR code',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_lastScannedCode != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            'Scanned: "$_lastScannedCode"',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Screen 2: 3D Model Viewer ──────────────────────────────────────────────

class ModelViewerScreen extends StatefulWidget {
  const ModelViewerScreen({super.key});

  @override
  State<ModelViewerScreen> createState() => _ModelViewerScreenState();
}

class _ModelViewerScreenState extends State<ModelViewerScreen> {
  late final WebViewController _webController;
  String _currentMode = 'closed';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'ModelViewerChannel',
        onMessageReceived: (JavaScriptMessage message) {
          if (message.message == 'loading_started') {
            setState(() => _isLoading = true);
          } else if (message.message == 'loading_finished') {
            setState(() => _isLoading = false);
          }
        },
      )
      ..setNavigationDelegate(NavigationDelegate(onPageFinished: (_) {}));

    _loadLocalHtml();
  }

  // Load the index.html file bundled in the assets folder
  Future<void> _loadLocalHtml() async {
    String htmlData = await rootBundle.loadString('assets/index.html');
    _webController.loadHtmlString(
      htmlData,
      baseUrl: 'https://firebasestorage.googleapis.com/',
    );
  }

  void _setCapMode(String mode) {
    if (_currentMode == mode) return;
    // Trigger the JavaScript function inside index.html
    _webController.runJavaScript("setCapMode('$mode')");
    setState(() {
      _currentMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/logo.png', height: 40),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black87, size: 26),
            tooltip: 'Exit Model Viewer',
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _webController),
          // Toggle buttons
          Positioned(
            bottom: 75,
            left: 20,
            right: 20,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 400),
              opacity: _isLoading ? 0.0 : 1.0,
              child: IgnorePointer(
                ignoring: _isLoading,
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: _currentMode == 'closed'
                              ? Colors.blueAccent
                              : Colors.blue.shade900,
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(12),
                          ),
                          boxShadow: _currentMode == 'closed'
                              ? [
                                  BoxShadow(
                                    color: Colors.blueAccent.withOpacity(0.5),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : [],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _setCapMode('closed'),
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.lock, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Closed Cap',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: _currentMode == 'open'
                              ? Colors.blueAccent
                              : Colors.blue.shade900,
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(12),
                          ),
                          boxShadow: _currentMode == 'open'
                              ? [
                                  BoxShadow(
                                    color: Colors.blueAccent.withOpacity(0.5),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : [],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _setCapMode('open'),
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.lock_open, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Open Cap',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Custom Painter for Corners ──────────────────────────────────────────────

class CornerPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double cornerLength;
  final double borderRadius;

  CornerPainter({
    required this.color,
    this.strokeWidth = 4.0,
    this.cornerLength = 30.0,
    this.borderRadius = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Top-left corner
    path.moveTo(0, cornerLength);
    path.lineTo(0, borderRadius);
    path.quadraticBezierTo(0, 0, borderRadius, 0);
    path.lineTo(cornerLength, 0);

    // Top-right corner
    path.moveTo(size.width - cornerLength, 0);
    path.lineTo(size.width - borderRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, borderRadius);
    path.lineTo(size.width, cornerLength);

    // Bottom-right corner
    path.moveTo(size.width, size.height - cornerLength);
    path.lineTo(size.width, size.height - borderRadius);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - borderRadius,
      size.height,
    );
    path.lineTo(size.width - cornerLength, size.height);

    // Bottom-left corner
    path.moveTo(cornerLength, size.height);
    path.lineTo(borderRadius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - borderRadius);
    path.lineTo(0, size.height - cornerLength);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CornerPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.cornerLength != cornerLength ||
        oldDelegate.borderRadius != borderRadius;
  }
}

class WhiteOverlayPainter extends CustomPainter {
  final Rect boxRect;
  WhiteOverlayPainter({required this.boxRect});

  @override
  void paint(Canvas canvas, Size size) {
    final Path screenPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final Path holePath = Path()
      ..addRRect(RRect.fromRectAndRadius(boxRect, const Radius.circular(12)));

    final Path overlayPath = Path.combine(
      PathOperation.difference,
      screenPath,
      holePath,
    );

    final Paint paint = Paint()..color = Colors.black.withOpacity(0.35);
    canvas.drawPath(overlayPath, paint);
  }

  @override
  bool shouldRepaint(covariant WhiteOverlayPainter oldDelegate) {
    return oldDelegate.boxRect != boxRect;
  }
}
