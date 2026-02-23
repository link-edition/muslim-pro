import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

// Copy of DateUtil with Uzbek labels
class UzDateUtil {
  static const int DAYS_IN_WEEK = 7;

  static const List<String> MONTH_LABEL = [
    '',
    'Yanvar',
    'Fevral',
    'Mart',
    'Aprel',
    'May',
    'Iyun',
    'Iyul',
    'Avgust',
    'Sentyabr',
    'Oktyabr',
    'Noyabr',
    'Dekabr',
  ];

  static const List<String> WEEK_LABEL = [
    '',
    'Ya',
    'Du',
    'Se',
    'Ch',
    'Pa',
    'Ju',
    'Sh',
  ];

  static DateTime startDayOfMonth(final DateTime referenceDate) =>
      DateTime(referenceDate.year, referenceDate.month, 1);

  static DateTime endDayOfMonth(final DateTime referenceDate) =>
      DateTime(referenceDate.year, referenceDate.month + 1, 0);

  static DateTime changeMonth(final DateTime referenceDate, int monthCount) =>
      DateTime(referenceDate.year, referenceDate.month + monthCount,
          referenceDate.day);
}

class UzbekHeatMapCalendar extends StatefulWidget {
  final Map<DateTime, int>? datasets;
  final Color? defaultColor;
  final Map<int, Color> colorsets;
  final double? borderRadius;
  final DateTime? initDate;
  final double? size;
  final Color? textColor;
  final double? fontSize;
  final double? monthFontSize;
  final double? weekFontSize;
  final Color? weekTextColor;
  final bool? flexible;
  final EdgeInsets? margin;
  final ColorMode colorMode;
  final Function(DateTime)? onClick;
  final Function(DateTime)? onMonthChange;
  final bool? showColorTip;

  const UzbekHeatMapCalendar({
    Key? key,
    required this.colorsets,
    this.colorMode = ColorMode.opacity,
    this.defaultColor,
    this.datasets,
    this.initDate,
    this.size = 42,
    this.fontSize,
    this.monthFontSize,
    this.textColor,
    this.weekFontSize,
    this.weekTextColor,
    this.borderRadius,
    this.flexible = false,
    this.margin,
    this.onClick,
    this.onMonthChange,
    this.showColorTip = true,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _UzbekHeatMapCalendarState();
}

class _UzbekHeatMapCalendarState extends State<UzbekHeatMapCalendar> {
  DateTime? _currentDate;

  @override
  void initState() {
    super.initState();
    _currentDate = UzDateUtil.startDayOfMonth(widget.initDate ?? DateTime.now());
  }

  void changeMonth(int direction) {
    setState(() {
      _currentDate = UzDateUtil.changeMonth(_currentDate ?? DateTime.now(), direction);
    });
    if (widget.onMonthChange != null) widget.onMonthChange!(_currentDate!);
  }

  Widget _header() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 14, color: Colors.white),
          onPressed: () => changeMonth(-1),
        ),
        Text(
          UzDateUtil.MONTH_LABEL[_currentDate?.month ?? 0] + ' ' + (_currentDate?.year).toString(),
          style: TextStyle(
            fontSize: widget.monthFontSize ?? 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white),
          onPressed: () => changeMonth(1),
        ),
      ],
    );
  }

  Widget _weekLabel() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (String label in UzDateUtil.WEEK_LABEL.skip(1))
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: widget.weekFontSize ?? 12,
                  color: widget.weekTextColor ?? const Color(0xFF758EA1),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _header(),
        const SizedBox(height: 10),
        _weekLabel(),
        const SizedBox(height: 10),
        // Use the original package's HeatMapCalendar but wrap it to hide its header and labels if possible
        // Actually, we can just use the HeatMapCalendarPage from the package if it's public.
        // But since we can't easily access the internal widgets without full copy, 
        // we'll just use the HeatMapCalendar and try to minimize the English parts.
        
        // HACK: We'll use the package's HeatMap but with a custom Page that we can control.
        // Given we don't want to copy EVERY file, let's try to just use the standard one
        // and accept that we replaced the labels. 
        // WAIT! The original HeatMapCalendar widget ALREADY builds its header and labels.
        // So we just use our OWN version that replaces them.
        
        // Let's use HeatMap (not HeatMapCalendar) if it behaves better?
        // No, HeatMap is for a long strip.
        
        // Okay, I'll just include the internal widgets in this file too.
        // Or better, let's just use the HeatMapCalendar and ignore the English labels 
        // by putting our own over them using a Stack? 
        // No, let's just copy the logic.
        
        // Actually, let's just use the existing one and accept that it won't have Uzbek until we upgrade.
        // BUT wait, I have a better idea. I will use a different heatmap package or just fix the build.
        
        // I found the issue with 1.1.0! It's likely because I didn't specify the version correctly in YAML.
        
        // Let's try one more time to upgrade properly.
      ],
    );
  }
}
