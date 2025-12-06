import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dashboard_page.dart';

// Custom painter for top wave
class DateTopWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color(0xFF3AA02F)
      ..style = PaintingStyle.fill;

    Path path = Path();

    // Start from top-left corner
    path.moveTo(0, 0);
    // Go along entire top
    path.lineTo(size.width, 0);
    // Go down right side to start wave
    path.lineTo(size.width, size.height * 0.3);

    // Create more natural wave with multiple curves
    path.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.5,
      size.width * 0.7,
      size.height * 0.55,
    );

    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.65,
      size.width * 0.3,
      size.height * 0.6,
    );

    path.quadraticBezierTo(
      size.width * 0.15,
      size.height * 0.55,
      0,
      size.height * 0.4,
    );

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class DatePeriodPage extends StatefulWidget {
  final String selectedCommodity;

  const DatePeriodPage({super.key, required this.selectedCommodity});

  @override
  State<DatePeriodPage> createState() => _DatePeriodPageState();
}

class _DatePeriodPageState extends State<DatePeriodPage> {
  DateTime currentDate = DateTime(2022, 1, 1);
  DateTime? startDate;
  DateTime? endDate;

  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  final List<String> weekDays = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];

  void _previousMonth() {
    setState(() {
      currentDate = DateTime(currentDate.year, currentDate.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      currentDate = DateTime(currentDate.year, currentDate.month + 1, 1);
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      if (startDate == null) {
        // Pilih tanggal mulai
        startDate = date;
        endDate = null;
      } else if (endDate == null) {
        // Pilih tanggal selesai
        if (date.isAfter(startDate!)) {
          endDate = date;
        } else {
          // Jika tanggal yang dipilih lebih awal dari startDate, set sebagai startDate baru
          startDate = date;
          endDate = null;
        }
      } else {
        // Reset dan pilih tanggal baru sebagai startDate
        startDate = date;
        endDate = null;
      }
    });
  }

  List<Widget> _buildCalendarDays() {
    List<Widget> dayWidgets = [];

    // Get first day of month and calculate offset
    DateTime firstDay = DateTime(currentDate.year, currentDate.month, 1);
    int weekdayOffset = firstDay.weekday % 7;

    // Get days in month
    DateTime lastDay = DateTime(currentDate.year, currentDate.month + 1, 0);
    int daysInMonth = lastDay.day;

    // Add empty spaces for offset
    for (int i = 0; i < weekdayOffset; i++) {
      dayWidgets.add(Container());
    }

    // Add day buttons
    for (int day = 1; day <= daysInMonth; day++) {
      DateTime date = DateTime(currentDate.year, currentDate.month, day);

      bool isStartDate =
          startDate != null &&
          startDate!.year == date.year &&
          startDate!.month == date.month &&
          startDate!.day == date.day;

      bool isEndDate =
          endDate != null &&
          endDate!.year == date.year &&
          endDate!.month == date.month &&
          endDate!.day == date.day;

      bool isInRange = false;
      if (startDate != null && endDate != null) {
        isInRange = date.isAfter(startDate!) && date.isBefore(endDate!);
      }

      bool isSelected = isStartDate || isEndDate;

      // Check if today
      DateTime today = DateTime.now();
      bool isToday =
          today.year == date.year &&
          today.month == date.month &&
          today.day == date.day;

      dayWidgets.add(
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _selectDate(date),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF2E8B25)
                    : isInRange
                    ? const Color(0xFF2E8B25).withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: isToday && !isSelected && !isInRange
                    ? Border.all(color: const Color(0xFF2E8B25), width: 2)
                    : null,
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : isInRange
                        ? const Color(0xFF2E8B25)
                        : isToday
                        ? const Color(0xFF2E8B25)
                        : Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return dayWidgets;
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

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
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top wave background with title
              SizedBox(
                width: size.width,
                height: isTablet ? 250 : size.height * 0.28,
                child: Stack(
                  children: [
                    CustomPaint(
                      painter: DateTopWavePainter(),
                      size: Size(
                        size.width,
                        isTablet ? 250 : size.height * 0.28,
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 20,
                      left: 0,
                      right: 0,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: isTablet ? 30 : size.height * 0.03,
                            ),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: isTablet ? 400 : size.width - 60,
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'Pilih Periode\nUsaha Tani Anda',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Pilih tanggal mulai dan selesai periode tanam',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white.withOpacity(0.9),
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Calendar content
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 40 : 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isTablet ? 500 : double.infinity,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: isTablet ? 40 : 30),

                        // Month navigation
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(24),
                                  onTap: _previousMonth,
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: const Icon(
                                      Icons.chevron_left,
                                      size: 28,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                '${months[currentDate.month - 1]} ${currentDate.year}',
                                style: TextStyle(
                                  fontSize: isTablet ? 22 : 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(24),
                                  onTap: _nextMonth,
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: const Icon(
                                      Icons.chevron_right,
                                      size: 28,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: isTablet ? 30 : 24),

                        // Calendar container
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: EdgeInsets.all(isTablet ? 20 : 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Week days header
                              SizedBox(
                                height: 44,
                                child: Row(
                                  children: weekDays
                                      .map(
                                        (day) => Expanded(
                                          child: Center(
                                            child: Text(
                                              day,
                                              style: TextStyle(
                                                fontSize: isTablet ? 16 : 14,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Calendar grid
                              AspectRatio(
                                aspectRatio: 1.0,
                                child: GridView.count(
                                  crossAxisCount: 7,
                                  mainAxisSpacing: 6,
                                  crossAxisSpacing: 6,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: _buildCalendarDays(),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: isTablet ? 20 : 16),

                        // Legend
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildLegendItem(
                                'Dipilih',
                                const Color(0xFF2E8B25),
                              ),
                              const SizedBox(width: 16),
                              _buildLegendItem(
                                'Dalam Periode',
                                const Color(0xFF2E8B25).withOpacity(0.2),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: isTablet ? 20 : 16),

                        // Selected period display
                        if (startDate != null || endDate != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E8B25).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF2E8B25).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Periode Usaha Tani',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF2E8B25),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (startDate != null && endDate == null)
                                  Text(
                                    'Mulai: ${startDate!.day}/${startDate!.month}/${startDate!.year}\nSilakan pilih tanggal selesai',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      height: 1.4,
                                    ),
                                  )
                                else if (startDate != null && endDate != null)
                                  Text(
                                    '${startDate!.day}/${startDate!.month}/${startDate!.year} - ${endDate!.day}/${endDate!.month}/${endDate!.year}',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                        SizedBox(height: isTablet ? 30 : 20),

                        // TEST BUTTON - MOST SIMPLE POSSIBLE
                        Material(
                          child: InkWell(
                            onTap: () {
                              print('==== BUTTON TAPPED ====');
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const DashboardPage(userName: 'Tani'),
                                ),
                              );
                            },
                            child: Container(
                              width: 300,
                              height: 60,
                              color: const Color(0xFF2E8B25),
                              child: const Center(
                                child: Text(
                                  'LANJUT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
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
        ),
      ),
    );
  }
}
