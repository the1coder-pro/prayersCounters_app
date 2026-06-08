// ignore: must_be_immutable
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive/hive.dart';
import 'package:prayers_counters_app/add_counter_page.dart';
import 'package:prayers_counters_app/main.dart';
import 'package:prayers_counters_app/prayers_model.dart';
import 'package:prayers_counters_app/preferences.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class CounterDetailsPage extends StatefulWidget {
  CounterDetailsPage({super.key, required this.prayer});
  Prayer prayer;

  @override
  State<CounterDetailsPage> createState() => _CounterDetailsPageState();
}

class _CounterDetailsPageState extends State<CounterDetailsPage>
    with TickerProviderStateMixin {
  AnimationController? controller;
  AnimationController? reloadController;
  double _contentFontSize = 24.0;
  Timer? _sizeTimer;

  @override
  void initState() {
    controller = AnimationController(vsync: this);
    reloadController = AnimationController(vsync: this);
    super.initState();
    _loadFontSize();
  }

  void _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _contentFontSize = prefs.getDouble("font_size_${widget.prayer.name}") ?? 24.0;
    });
  }

  void _changeFontSize(bool increase) async {
    setState(() {
      if (increase) {
        if (_contentFontSize < 100) {
          _contentFontSize += 1;
        }
      } else {
        if (_contentFontSize > 10) {
          _contentFontSize -= 1;
        }
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble("font_size_${widget.prayer.name}", _contentFontSize);
  }

  void _startChangingSize(bool increase) {
    _sizeTimer?.cancel();
    _sizeTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _changeFontSize(increase);
    });
  }

  void _stopChangingSize() {
    _sizeTimer?.cancel();
    _sizeTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    final themeChangeProvider = Provider.of<TheThemeProvider>(context);
    final theme = Theme.of(context);
    final double progress = widget.prayer.total > 0
        ? (widget.prayer.finished / widget.prayer.total).clamp(0.0, 1.0)
        : 0.0;

    return Directionality(
      textDirection: themeChangeProvider.language == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surfaceContainer,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            widget.prayer.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: "Rubik",
            ),
          ),
          centerTitle: true,
          actions: [
            // Decrease Font
            GestureDetector(
              onTap: () => _changeFontSize(false),
              onLongPressStart: (_) => _startChangingSize(false),
              onLongPressEnd: (_) => _stopChangingSize(),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Icon(Icons.text_decrease_outlined, size: 22),
              ),
            ),
            // Increase Font
            GestureDetector(
              onTap: () => _changeFontSize(true),
              onLongPressStart: (_) => _startChangingSize(true),
              onLongPressEnd: (_) => _stopChangingSize(),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Icon(Icons.text_increase_outlined, size: 22),
              ),
            ),
            const SizedBox(width: 4),
            // Edit Button
            IconButton(
              icon: Icon(Icons.edit_outlined, color: theme.colorScheme.primary, size: 22),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddCounterPage(
                      prayer: widget.prayer,
                      isEdit: true,
                    ),
                  ),
                ).then((result) {
                  if (result is Prayer) {
                    setState(() {
                      widget.prayer = result;
                    });
                  }
                });
              },
            ),
            // Delete Button
            IconButton(
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error, size: 22),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return Directionality(
                        textDirection: themeChangeProvider.language == 'ar'
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        child: AlertDialog(
                          icon: const Icon(Icons.delete_forever_outlined),
                          title: const Text('حذف العداد'),
                          content: const Text('هل تريد حذف هذا العداد؟'),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('لا')),
                            TextButton(
                                onPressed: () async {
                                  await Hive.box<Prayer>(boxName)
                                      .delete(widget.prayer.name);
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                child: const Text('نعم')),
                          ],
                        ),
                      );
                    });
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. CONTENT BOX
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Text(
                          widget.prayer.content,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: "Scheherazade",
                            fontSize: _contentFontSize,
                            height: 1.6,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // 2. AUXILIARY BUTTONS (Reset and Cycles as Rounded Squares)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Reset Column
                    Column(
                      children: [
                        Container(
                          height: 55,
                          width: 55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: theme.colorScheme.errorContainer.withValues(alpha: 0.15),
                          ),
                          child: IconButton(
                            icon: Animate(
                              controller: reloadController,
                              effects: [RotateEffect(duration: 200.milliseconds)],
                              child: Icon(
                                Icons.replay_outlined,
                                color: theme.colorScheme.error,
                              ),
                            ),
                            onPressed: () async {
                              final performReset = () async {
                                widget.prayer.finished = 0;
                                await Hive.box<Prayer>(boxName).put(
                                    widget.prayer.name,
                                    Prayer(
                                      widget.prayer.name,
                                      widget.prayer.total,
                                      widget.prayer.finished,
                                      widget.prayer.content,
                                      numberOfCompletedPrayers: widget.prayer.numberOfCompletedPrayers,
                                    ));
                                setState(() {});
                                reloadController!.forward(from: 0);
                              };

                              if (themeChangeProvider.confirmReset) {
                                showDialog(
                                  context: context,
                                  builder: (context) => Directionality(
                                    textDirection: themeChangeProvider.language == 'ar'
                                        ? TextDirection.rtl
                                        : TextDirection.ltr,
                                    child: AlertDialog(
                                      icon: const Icon(Icons.refresh_outlined),
                                      title: const Text("تأكيد التصفير"),
                                      content: Text("هل أنت متأكد من تصفير عداد \"${widget.prayer.name}\"؟"),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text("لا"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            performReset();
                                            Navigator.pop(context);
                                          },
                                          child: const Text("نعم"),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                await performReset();
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "تصفير",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                    
                    // Cycles Column
                    Column(
                      children: [
                        Container(
                          height: 55,
                          width: 55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: theme.colorScheme.secondaryContainer,
                          ),
                          child: Center(
                            child: Text(
                              widget.prayer.numberOfCompletedPrayers.toString(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "الدورات",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 3. MAIN COUNTER INCREMENT BUTTON (Rounded Square Outline Loading & Hero Rounded Square Button)
              Expanded(
                flex: 2,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 40, right: 40, top: 12, bottom: 24),
                    child: GestureDetector(
                      onTap: () async {
                        bool isCompletion = false;
                        if (widget.prayer.finished != widget.prayer.total) {
                          widget.prayer.finished += 1;
                          if (widget.prayer.finished == widget.prayer.total) {
                            isCompletion = true;
                          }
                          await Hive.box<Prayer>(boxName)
                              .put(
                                  widget.prayer.name,
                                  Prayer(
                                      widget.prayer.name,
                                      widget.prayer.total,
                                      widget.prayer.finished,
                                      widget.prayer.content,
                                      numberOfCompletedPrayers: widget.prayer.numberOfCompletedPrayers))
                              .then((value) => setState(() {}));
                        } else {
                          widget.prayer.finished = 0;
                          widget.prayer.numberOfCompletedPrayers++;
                          await Hive.box<Prayer>(boxName).put(
                              widget.prayer.name,
                              Prayer(
                                  widget.prayer.name,
                                  widget.prayer.total,
                                  widget.prayer.finished,
                                  widget.prayer.content,
                                  numberOfCompletedPrayers: widget.prayer.numberOfCompletedPrayers));
                          setState(() {});
                        }

                        if (isCompletion) {
                          if (themeChangeProvider.vibrateOnComplete) {
                            HapticFeedback.vibrate();
                          }
                        } else {
                          if (themeChangeProvider.vibrateOnTap) {
                            HapticFeedback.lightImpact();
                          }
                        }

                        controller!.forward(from: 0);
                      },
                      child: Container(
                        width: 240,
                        height: 240,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Rounded Square Progress Outline
                            Positioned.fill(
                              child: CustomPaint(
                                painter: RoundedSquareProgressPainter(
                                  progress: progress,
                                  color: theme.colorScheme.primary,
                                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                                  strokeWidth: 8.0,
                                  borderRadius: 36.0,
                                ),
                              ),
                            ),
                            // Inner Button (Rounded Square & Hero)
                            Hero(
                              tag: 'IncreaseFAB',
                              child: Material(
                                type: MaterialType.transparency,
                                child: Container(
                                  width: 204,
                                  height: 204,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(28.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.colorScheme.primary.withValues(alpha: 0.08),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Animate(
                                          controller: controller,
                                          effects: [
                                            ScaleEffect(duration: 150.milliseconds, curve: Curves.easeOut),
                                          ],
                                          child: Text(
                                            widget.prayer.finished.toString(),
                                            style: TextStyle(
                                              fontSize: 64,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Ubuntu Mono',
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "الهدف: ${widget.prayer.total}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                          ),
                                        ),
                                      ],
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    reloadController?.dispose();
    _sizeTimer?.cancel();
    super.dispose();
  }
}

class RoundedSquareProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;
  final double borderRadius;

  RoundedSquareProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintBg = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final paintProgress = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    canvas.drawRRect(rrect, paintBg);

    final path = Path()..addRRect(rrect);
    final pms = path.computeMetrics();
    for (final pm in pms) {
      final extractPath = pm.extractPath(0, pm.length * progress);
      canvas.drawPath(extractPath, paintProgress);
    }
  }

  @override
  bool shouldRepaint(covariant RoundedSquareProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
