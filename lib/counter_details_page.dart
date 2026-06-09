// ignore: must_be_immutable
import 'dart:async';
import 'dart:math' as math;
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
import 'package:prayers_counters_app/audio_player_helper.dart';

enum CounterViewMode {
  bigButton,
  verticalMisbah,
  horizontalMisbah,
}

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
  CounterViewMode _viewMode = CounterViewMode.bigButton;
  late FixedExtentScrollController _scrollController;
  int _lastSelectedIndex = 50000;

  @override
  void initState() {
    controller = AnimationController(vsync: this);
    reloadController = AnimationController(vsync: this);
    _scrollController = FixedExtentScrollController(
      initialItem: 50000 + widget.prayer.finished,
    );
    _lastSelectedIndex = 50000 + widget.prayer.finished;
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final modeStr = prefs.getString("view_mode_${widget.prayer.name}");
    setState(() {
      _contentFontSize =
          prefs.getDouble("font_size_${widget.prayer.name}") ?? 24.0;
      if (modeStr != null) {
        _viewMode = CounterViewMode.values.firstWhere(
          (e) => e.name == modeStr,
          orElse: () => CounterViewMode.bigButton,
        );
      } else {
        // Fallback to old boolean use_misbah_mode to prevent breaking changes
        final oldBool =
            prefs.getBool("use_misbah_mode_${widget.prayer.name}") ?? false;
        _viewMode = oldBool
            ? CounterViewMode.verticalMisbah
            : CounterViewMode.bigButton;
      }
    });
  }

  void _saveViewModePreference(CounterViewMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("view_mode_${widget.prayer.name}", mode.name);
  }

  Future<void> _incrementCounter({int amount = 1}) async {
    bool isCompletion = false;
    final total = widget.prayer.total;
    if (total <= 0) {
      widget.prayer.finished += amount;
    } else {
      for (int k = 0; k < amount; k++) {
        if (widget.prayer.finished != total) {
          widget.prayer.finished += 1;
          if (widget.prayer.finished == total) {
            isCompletion = true;
          }
        } else {
          widget.prayer.finished = 0;
          widget.prayer.numberOfCompletedPrayers++;
        }
      }
    }

    await Hive.box<Prayer>(boxName).put(
        widget.prayer.name,
        Prayer(widget.prayer.name, widget.prayer.total, widget.prayer.finished,
            widget.prayer.content,
            numberOfCompletedPrayers: widget.prayer.numberOfCompletedPrayers));

    setState(() {});

    final themeChangeProvider =
        Provider.of<TheThemeProvider>(context, listen: false);
    if (isCompletion) {
      AudioPlayerHelper.playCompletionSound();
      if (themeChangeProvider.vibrateOnComplete) {
        HapticFeedback.vibrate();
      }
    } else {
      if (themeChangeProvider.vibrateOnTap) {
        HapticFeedback.lightImpact();
      }
    }

    controller?.forward(from: 0);
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
            PopupMenuButton<CounterViewMode>(
              icon: Icon(Icons.display_settings_outlined,
                  color: theme.colorScheme.primary, size: 22),
              tooltip: themeChangeProvider.language == 'ar'
                  ? "خيارات العرض"
                  : "View Options",
              onSelected: (CounterViewMode mode) {
                setState(() {
                  _viewMode = mode;
                  if (_viewMode != CounterViewMode.bigButton &&
                      _scrollController.hasClients) {
                    _scrollController
                        .jumpToItem(50000 + widget.prayer.finished);
                    _lastSelectedIndex = 50000 + widget.prayer.finished;
                  }
                });
                _saveViewModePreference(mode);
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: CounterViewMode.bigButton,
                  child: Row(
                    children: [
                      Icon(Icons.touch_app_outlined,
                          color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(themeChangeProvider.language == 'ar'
                          ? "زر الضغط الكبير"
                          : "Big Button"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: CounterViewMode.verticalMisbah,
                  child: Row(
                    children: [
                      Icon(Icons.swipe_vertical_outlined,
                          color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(themeChangeProvider.language == 'ar'
                          ? "المسبحة العمودية"
                          : "Vertical Misbah"),
                    ],
                  ),
                ),
                // PopupMenuItem(
                //   value: CounterViewMode.horizontalMisbah,
                //   child: Row(
                //     children: [
                //       Icon(Icons.swipe_left_outlined, color: theme.colorScheme.primary, size: 20),
                //       const SizedBox(width: 8),
                //       Text(themeChangeProvider.language == 'ar' ? "المسبحة الأفقية" : "Horizontal Misbah"),
                //     ],
                //   ),
                // ),
              ],
            ),
            const SizedBox(width: 4),
            // Edit Button
            IconButton(
              icon: Icon(Icons.edit_outlined,
                  color: theme.colorScheme.primary, size: 22),
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
              icon: Icon(Icons.delete_outline,
                  color: theme.colorScheme.error, size: 22),
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
                        color: theme.colorScheme.outlineVariant
                            .withValues(alpha: 0.3),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                child: Row(
                  mainAxisAlignment: widget.prayer.total > 0
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.center,
                  children: [
                    // Reset Column
                    Column(
                      children: [
                        Container(
                          height: 55,
                          width: 55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: theme.colorScheme.errorContainer
                                .withValues(alpha: 0.15),
                          ),
                          child: IconButton(
                            icon: Animate(
                              controller: reloadController,
                              effects: [
                                RotateEffect(duration: 200.milliseconds)
                              ],
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
                                      numberOfCompletedPrayers: widget
                                          .prayer.numberOfCompletedPrayers,
                                    ));
                                if (_scrollController.hasClients) {
                                  _scrollController.jumpToItem(50000);
                                  _lastSelectedIndex = 50000;
                                }
                                setState(() {});
                                reloadController!.forward(from: 0);
                              };

                              if (themeChangeProvider.confirmReset) {
                                showDialog(
                                  context: context,
                                  builder: (context) => Directionality(
                                    textDirection:
                                        themeChangeProvider.language == 'ar'
                                            ? TextDirection.rtl
                                            : TextDirection.ltr,
                                    child: AlertDialog(
                                      icon: const Icon(Icons.refresh_outlined),
                                      title: const Text("تأكيد التصفير"),
                                      content: Text(
                                          "هل أنت متأكد من تصفير عداد \"${widget.prayer.name}\"؟"),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
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
                    if (widget.prayer.total > 0)
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

              // 3. MAIN COUNTER INCREMENT BUTTON OR MISBAH MODE
              Expanded(
                flex: 2,
                child: Center(
                  child: _viewMode == CounterViewMode.horizontalMisbah
                      ? _buildHorizontalMisbahView(
                          context, theme, themeChangeProvider)
                      : (_viewMode == CounterViewMode.verticalMisbah
                          ? _buildMisbahView(
                              context, theme, themeChangeProvider)
                          : _buildBigButtonView(
                              context, theme, themeChangeProvider, progress)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBigButtonView(BuildContext context, ThemeData theme,
      TheThemeProvider themeChangeProvider, double progress) {
    return Padding(
      padding: const EdgeInsets.only(left: 40, right: 40, top: 12, bottom: 24),
      child: GestureDetector(
        onTap: () => _incrementCounter(),
        child: Container(
          width: 240,
          height: 240,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Rounded Square Progress Outline
              if (widget.prayer.total > 0)
                Positioned.fill(
                  child: CustomPaint(
                    painter: RoundedSquareProgressPainter(
                      progress: progress,
                      color: theme.colorScheme.primary,
                      backgroundColor:
                          theme.colorScheme.primary.withValues(alpha: 0.1),
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
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.08),
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
                              ScaleEffect(
                                  duration: 150.milliseconds,
                                  curve: Curves.easeOut),
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
                            themeChangeProvider.language == 'ar'
                                ? (widget.prayer.total <= 0 ? "المقدار: مفتوح" : "المقدار: ${widget.prayer.total}")
                                : (widget.prayer.total <= 0 ? "Target: Open" : "Target: ${widget.prayer.total}"),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.7),
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
    );
  }

  Widget _buildMisbahView(BuildContext context, ThemeData theme,
      TheThemeProvider themeChangeProvider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Large Counter Display
        Text(
          widget.prayer.finished.toString(),
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            fontFamily: 'Ubuntu Mono',
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          themeChangeProvider.language == 'ar'
              ? (widget.prayer.total <= 0 ? "المقدار: مفتوح" : "المقدار: ${widget.prayer.total}")
              : (widget.prayer.total <= 0 ? "Target: Open" : "Target: ${widget.prayer.total}"),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 12),
        // Scrollable Beads
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Vertical Thread
                Container(
                  width: 3,
                  height: double.infinity,
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
                // Center Marker indicator
                Positioned(
                  left: 12,
                  right: 12,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                  ),
                ),
                // ListWheelScrollView
                ListWheelScrollView.useDelegate(
                  controller: _scrollController,
                  itemExtent: 60,
                  diameterRatio: 1.5,
                  physics: const FixedExtentScrollPhysics(),
                  onSelectedItemChanged: (index) {
                    int diff = (index - _lastSelectedIndex).abs();
                    if (diff > 0) {
                      _incrementCounter(amount: diff);
                      _lastSelectedIndex = index;
                    }
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) {
                      final isCenter = index == _lastSelectedIndex;
                      return Center(
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.shadow
                                    .withValues(alpha: 0.15),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            gradient: RadialGradient(
                              center: const Alignment(-0.3, -0.3),
                              radius: 0.6,
                              colors: [
                                Colors.white.withValues(alpha: 0.4),
                                isCenter
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.secondary,
                                isCenter
                                    ? theme.colorScheme.primaryContainer
                                    : theme.colorScheme.secondaryContainer,
                              ],
                              stops: const [0.0, 0.6, 1.0],
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                top: 6,
                                left: 6,
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  ((index - 50000) % 33 + 1).toString(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isCenter
                                        ? theme.colorScheme.onPrimaryContainer
                                            .withValues(alpha: 0.8)
                                        : theme.colorScheme.onSecondaryContainer
                                            .withValues(alpha: 0.8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalMisbahView(BuildContext context, ThemeData theme,
      TheThemeProvider themeChangeProvider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Large Counter Display
        Text(
          widget.prayer.finished.toString(),
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            fontFamily: 'Ubuntu Mono',
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          themeChangeProvider.language == 'ar'
              ? (widget.prayer.total <= 0 ? "المقدار: مفتوح" : "المقدار: ${widget.prayer.total}")
              : (widget.prayer.total <= 0 ? "Target: Open" : "Target: ${widget.prayer.total}"),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 12),
        // Scrollable Beads (Horizontal Layout)
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Horizontal Thread
                Container(
                  height: 3,
                  width: double.infinity,
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
                // Center Marker indicator (Vertical brackets/border at the center)
                Positioned(
                  top: 12,
                  bottom: 12,
                  child: Container(
                    width: 60,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                  ),
                ),
                // Rotated ListWheelScrollView for horizontal scroll direction
                RotatedBox(
                  quarterTurns:
                      3, // Rotate ListWheelScrollView to scroll horizontally
                  child: ListWheelScrollView.useDelegate(
                    controller: _scrollController,
                    itemExtent: 60,
                    diameterRatio: 1.5,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (index) {
                      int diff = (index - _lastSelectedIndex).abs();
                      if (diff > 0) {
                        _incrementCounter(amount: diff);
                        _lastSelectedIndex = index;
                      }
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      builder: (context, index) {
                        final isCenter = index == _lastSelectedIndex;
                        return Center(
                          child: RotatedBox(
                            quarterTurns:
                                1, // Rotate item content back to keep it upright
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.shadow
                                        .withValues(alpha: 0.15),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                                gradient: RadialGradient(
                                  center: const Alignment(-0.3, -0.3),
                                  radius: 0.6,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.4),
                                    isCenter
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.secondary,
                                    isCenter
                                        ? theme.colorScheme.primaryContainer
                                        : theme.colorScheme.secondaryContainer,
                                  ],
                                  stops: const [0.0, 0.6, 1.0],
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 6,
                                    left: 6,
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      ((index - 50000) % 33 + 1).toString(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isCenter
                                            ? theme
                                                .colorScheme.onPrimaryContainer
                                                .withValues(alpha: 0.8)
                                            : theme.colorScheme
                                                .onSecondaryContainer
                                                .withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    reloadController?.dispose();
    _scrollController.dispose();
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
