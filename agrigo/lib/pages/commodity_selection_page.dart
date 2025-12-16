import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'date_period_page.dart';
import 'commodity_search_page.dart';

// Custom painter for top wave
class CommodityTopWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color(0xFF3AA02F)
      ..style = PaintingStyle.fill;

    Path path = Path();

    // Start from top-left
    path.moveTo(0, 0);
    // Go to top-right
    path.lineTo(size.width, 0);
    // Go down the right side
    path.lineTo(size.width, size.height * 0.6);

    // Create symmetric curve from right to left
    path.quadraticBezierTo(
      size.width * 0.5, // Control point X (center)
      size.height * 1.2, // Control point Y (below for curve down)
      0, // End point X (left side)
      size.height * 0.6, // End point Y (same height as start)
    );

    // Close path back to start
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class CommoditySelectionPage extends StatefulWidget {
  final bool? isFromDashboard;
  final String? selectedCommodity;

  const CommoditySelectionPage({
    super.key,
    this.isFromDashboard = false,
    this.selectedCommodity,
  });

  @override
  State<CommoditySelectionPage> createState() => _CommoditySelectionPageState();
}

class _CommoditySelectionPageState extends State<CommoditySelectionPage> {
  String? selectedCommodity;

  @override
  void initState() {
    super.initState();
    selectedCommodity = widget.selectedCommodity;
  }

  void _openCommoditySearch() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CommoditySearchPage()),
    );

    if (result != null) {
      setState(() {
        selectedCommodity = result;
      });
    }
  }

  void _handleContinue() {
    if (selectedCommodity != null) {
      if (widget.isFromDashboard == true) {
        // Return selected commodity to dashboard
        print(
          '===== COMMODITY SELECTION: Returning to Dashboard with: $selectedCommodity =====',
        );
        Navigator.pop(context, selectedCommodity);
      } else {
        // Navigate to DatePeriodPage for onboarding flow
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                DatePeriodPage(selectedCommodity: selectedCommodity!),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih komoditas terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        automaticallyImplyLeading: false,
      ),
      body: SizedBox(
        width: double.infinity,
        height: size.height,
        child: Column(
          children: [
            // Top wave background with title
            Container(
              width: size.width,
              height: size.height * 0.45,
              child: Stack(
                children: [
                  CustomPaint(
                    painter: CommodityTopWavePainter(),
                    size: Size(size.width, size.height * 0.45),
                  ),
                  SafeArea(
                    child: Container(
                      width: size.width,
                      child: Column(
                        children: [
                          SizedBox(height: size.height * 0.10),
                          Center(
                            child: Text(
                              'Pilih komoditas anda',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content area
            Expanded(
              child: Container(
                width: size.width,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: size.height * 0.08),

                    // Search commodity button
                    Container(
                      width: size.width - 48,
                      constraints: const BoxConstraints(
                        minHeight: 56,
                        maxWidth: 400,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF2E8B25),
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _openCommoditySearch,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.search,
                                  color: Color(0xFF2E8B25),
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    selectedCommodity ?? 'Pilih komoditas',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: selectedCommodity != null
                                          ? Colors.black87
                                          : Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.keyboard_arrow_right,
                                  color: Color(0xFF2E8B25),
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),

                    // Continue button
                    Container(
                      width: size.width - 48,
                      constraints: const BoxConstraints(maxWidth: 400),
                      margin: EdgeInsets.only(
                        bottom: MediaQuery.of(context).padding.bottom + 24,
                      ),
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _handleContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E8B25),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                            shadowColor: Colors.black26,
                          ),
                          child: Text(
                            widget.isFromDashboard == true
                                ? 'Pilih Komoditas'
                                : 'Lanjut',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
