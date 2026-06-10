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
import 'package:m3e_core/m3e_core.dart';
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
  late Animation<double> _scaleAnimation;
  double _contentFontSize = 24.0;
  Timer? _sizeTimer;
  CounterViewMode _viewMode = CounterViewMode.bigButton;
  late FixedExtentScrollController _scrollController;
  int _lastSelectedIndex = 50000;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.95).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(controller!);
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
            numberOfCompletedPrayers: widget.prayer.numberOfCompletedPrayers,
            nextCounterName: widget.prayer.nextCounterName,
            misbahColorValue: widget.prayer.misbahColorValue));

    setState(() {});

    final themeChangeProvider =
        Provider.of<TheThemeProvider>(context, listen: false);
    if (isCompletion) {
      if (themeChangeProvider.enableAudio) {
        AudioPlayerHelper.playCompletionSound();
      }
      if (themeChangeProvider.vibrateOnComplete) {
        HapticFeedback.vibrate();
      }
    } else {
      final bool playSound = _viewMode == CounterViewMode.bigButton
          ? themeChangeProvider.enableAudio
          : themeChangeProvider.enableMisbahAudio;
      if (playSound) {
        // Play system click sound (for mobile) and URL sound (for web)
        SystemSound.play(SystemSoundType.click);
        AudioPlayerHelper.playTapSound();
      }
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
          _contentFontSize += 3;
          if (_contentFontSize > 100) _contentFontSize = 100;
        }
      } else {
        if (_contentFontSize > 10) {
          _contentFontSize -= 3;
          if (_contentFontSize < 10) _contentFontSize = 10;
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: "Rubik",
            ),
          ),
          actions: [
            // Font size triggers directly on AppBar
            GestureDetector(
              onTap: () => _changeFontSize(false),
              onLongPressStart: (_) => _startChangingSize(false),
              onLongPressEnd: (_) => _stopChangingSize(),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Icon(Icons.text_decrease_outlined, size: 20),
              ),
            ),
            GestureDetector(
              onTap: () => _changeFontSize(true),
              onLongPressStart: (_) => _startChangingSize(true),
              onLongPressEnd: (_) => _stopChangingSize(),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Icon(Icons.text_increase_outlined, size: 20),
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_outlined,
                  color: theme.colorScheme.primary, size: 22),
              onSelected: (String choice) {
                if (choice == 'edit') {
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
                        // The user might have renamed the prayer, in which case the key changed.
                        // Or they assigned/changed properties. We re-fetch it from Hive or use the result.
                        widget.prayer = Hive.box<Prayer>(boxName).get(result.name) ?? result;
                      });
                    }
                  });
                } else if (choice == 'delete') {
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
                              M3ETextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('لا')),
                              M3EFilledButton.tonal(
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
                } else if (choice == 'color') {
                  _showColorPickerDialog(context, themeChangeProvider);
                } else if (choice == 'view_mode_big') {
                  setState(() {
                    _viewMode = CounterViewMode.bigButton;
                  });
                  _saveViewModePreference(CounterViewMode.bigButton);
                } else if (choice == 'view_mode_vertical') {
                  setState(() {
                    _viewMode = CounterViewMode.verticalMisbah;
                    if (_scrollController.hasClients) {
                      _scrollController.jumpToItem(50000 + widget.prayer.finished);
                      _lastSelectedIndex = 50000 + widget.prayer.finished;
                    }
                  });
                  _saveViewModePreference(CounterViewMode.verticalMisbah);
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: 'view_mode_big',
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
                  value: 'view_mode_vertical',
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
                PopupMenuItem(
                  value: 'color',
                  child: Row(
                    children: [
                      Icon(Icons.palette_outlined,
                          color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(themeChangeProvider.language == 'ar'
                          ? "تغيير لون المسبحة"
                          : "Change Misbah Color"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined,
                          color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(themeChangeProvider.language == 'ar'
                          ? "تعديل العداد"
                          : "Edit Counter"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline,
                          color: theme.colorScheme.error, size: 20),
                      const SizedBox(width: 8),
                      Text(themeChangeProvider.language == 'ar'
                          ? "حذف العداد"
                          : "Delete Counter"),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // 1. CONTENT BOX (Flexible with maximum height limit)
            Flexible(
              fit: FlexFit.tight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 4.0),
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
                  child: SingleChildScrollView(
                    child: Center(
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

            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left Side: Cycles count pill wrapper (Height: 40)
                    SizedBox(
                      height: 40,
                      child: widget.prayer.total > 0
                          ? Tooltip(
                              message: themeChangeProvider.language == 'ar'
                                  ? "الدورات المكتملة"
                                  : "Completed Cycles",
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: theme.colorScheme.secondaryContainer,
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.loop_outlined,
                                        size: 16,
                                        color: theme.colorScheme.onSecondaryContainer,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        widget.prayer.numberOfCompletedPrayers.toString(),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onSecondaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                    // Middle Side: Show Next Counter Button (if configured) in both modes (Height: 40)
                    SizedBox(
                      height: 40,
                      child: widget.prayer.nextCounterName != null && widget.prayer.nextCounterName!.isNotEmpty
                          ? Tooltip(
                              message: themeChangeProvider.language == 'ar'
                                  ? "العداد التالي: ${widget.prayer.nextCounterName}"
                                  : "Next Counter: ${widget.prayer.nextCounterName}",
                              child: M3EFilledButton.tonalIcon(
                                onPressed: _navigateToNextCounter,
                                icon: Icon(
                                  Icons.skip_next_outlined,
                                  size: 18,
                                  color: theme.colorScheme.primary,
                                ),
                                label: Text(
                                  _viewMode != CounterViewMode.bigButton
                                      ? (themeChangeProvider.language == 'ar' 
                                          ? "التالي (${widget.prayer.finished}${widget.prayer.total > 0 ? '/${widget.prayer.total}' : ''})"
                                          : "Next (${widget.prayer.finished}${widget.prayer.total > 0 ? '/${widget.prayer.total}' : ''})")
                                      : (themeChangeProvider.language == 'ar' ? "العداد التالي" : "Next counter"),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                decoration: M3EButtonDecoration.styleFrom(
                                  backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  borderRadius: 12,
                                ),
                              ),
                            )
                          : (_viewMode != CounterViewMode.bigButton
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: theme.colorScheme.primaryContainer,
                                  ),
                                  child: Center(
                                    child: Text(
                                      "${widget.prayer.finished}${widget.prayer.total > 0 ? ' / ${widget.prayer.total}' : ''}",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onPrimaryContainer,
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink()),
                    ),

                    // Right Side: Reset Button wrapper (Height: 40)
                    SizedBox(
                      height: 40,
                      width: 40,
                      child: Tooltip(
                        message: themeChangeProvider.language == 'ar' ? "تصفير" : "Reset",
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: theme.colorScheme.errorContainer.withValues(alpha: 0.15),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            iconSize: 20,
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
                                        numberOfCompletedPrayers: widget
                                            .prayer.numberOfCompletedPrayers,
                                        nextCounterName: widget.prayer.nextCounterName,
                                        misbahColorValue: widget.prayer.misbahColorValue,
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
                                        M3ETextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text("لا"),
                                        ),
                                        M3EFilledButton.tonal(
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
                      ),
                    ),
                  ],
                ),
              ),

              // 3. MAIN COUNTER INCREMENT BUTTON OR MISBAH MODE
              Expanded(
                flex: 2,
                child: _viewMode == CounterViewMode.horizontalMisbah
                    ? _buildHorizontalMisbahView(
                        context, theme, themeChangeProvider)
                    : (_viewMode == CounterViewMode.verticalMisbah
                        ? _buildMisbahView(
                            context, theme, themeChangeProvider)
                        : _buildBigButtonView(
                            context, theme, themeChangeProvider, progress)),
              ),
            ],
        ),
      ),
    );
  }

  void _showColorPickerDialog(BuildContext context, TheThemeProvider themeChangeProvider) {
    final theme = Theme.of(context);
    final List<Map<String, dynamic>> colors = [
      {
        'name': themeChangeProvider.language == 'ar' ? 'الافتراضي' : 'Default',
        'value': null,
      },
      {
        'name': themeChangeProvider.language == 'ar' ? 'غرافيت' : 'Graphite',
        'value': 0xFF383838,
      },
      {
        'name': themeChangeProvider.language == 'ar' ? 'فيروزي' : 'Firuz (Turquoise)',
        'value': 0xFF30D5C8,
      },
      {
        'name': themeChangeProvider.language == 'ar' ? 'رخامي' : 'Marble (White)',
        'value': 0xFFEAEAEA,
      },
      {
        'name': themeChangeProvider.language == 'ar' ? 'كوارتز' : 'Quartz (Pink)',
        'value': 0xFFF7C8DA,
      },
      {
        'name': themeChangeProvider.language == 'ar' ? 'خشبي' : 'Wood',
        'value': 0xFF8B5A2B,
      },
      {
        'name': themeChangeProvider.language == 'ar' ? 'حجري' : 'Stone (Grey)',
        'value': 0xFF8A9A86,
      },
    ];

    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: themeChangeProvider.language == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: AlertDialog(
            icon: const Icon(Icons.palette_outlined),
            title: Text(
              themeChangeProvider.language == 'ar'
                  ? "اختر لون المسبحة"
                  : "Choose Misbah Color",
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: colors.length,
                itemBuilder: (context, index) {
                  final colorItem = colors[index];
                  final int? val = colorItem['value'];
                  final colorObj = val == null ? theme.colorScheme.primary : Color(val);
                  final isSelected = widget.prayer.misbahColorValue == val;

                  return GestureDetector(
                    onTap: () async {
                      widget.prayer.misbahColorValue = val;
                      await Hive.box<Prayer>(boxName).put(widget.prayer.name, widget.prayer);
                      setState(() {});
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorObj,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? theme.colorScheme.onSurface : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              color: ThemeData.estimateBrightnessForColor(colorObj) == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToNextCounter() {
    final nextName = widget.prayer.nextCounterName;
    if (nextName == null || nextName.isEmpty) return;
    final box = Hive.box<Prayer>(boxName);
    final nextPrayer = box.get(nextName);
    if (nextPrayer != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CounterDetailsPage(prayer: nextPrayer),
        ),
      );
    }
  }

  Widget _buildBigButtonView(BuildContext context, ThemeData theme,
      TheThemeProvider themeChangeProvider, double progress) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 16),
      child: Column(
        children: [
          Expanded(
            child: SizedBox(
              width: double.infinity,
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
                          strokeWidth: 6.0,
                          borderRadius: 24.0,
                        ),
                      ),
                    ),
                  // Inner Button (Rounded Square & InkWell with ScaleTransition)
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Material(
                          color: Colors.transparent,
                          child: Ink(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(20.0),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      theme.colorScheme.primary.withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20.0),
                              onTap: () => _incrementCounter(),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      widget.prayer.finished.toString(),
                                      style: TextStyle(
                                        fontSize: 60,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Ubuntu Mono',
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      themeChangeProvider.language == 'ar'
                                          ? (widget.prayer.total <= 0 ? "مفتوح" : "${widget.prayer.total}")
                                          : (widget.prayer.total <= 0 ? "Open" : "${widget.prayer.total}"),
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
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMisbahView(BuildContext context, ThemeData theme,
      TheThemeProvider themeChangeProvider) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Scrollable Beads
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
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
                            gradient: _getStoneGradient(widget.prayer.misbahColorValue, isCenter, theme),
                            border: Border.all(
                              color: _getStoneBorderColor(widget.prayer.misbahColorValue, isCenter, theme),
                              width: 1.5,
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
                                        ? (widget.prayer.misbahColorValue != null
                                            ? Colors.white
                                            : theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8))
                                        : (widget.prayer.misbahColorValue != null
                                            ? Colors.white70
                                            : theme.colorScheme.onSecondaryContainer.withValues(alpha: 0.8)),
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
        // Scrollable Beads (Horizontal Layout)
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
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
                                gradient: _getStoneGradient(widget.prayer.misbahColorValue, isCenter, theme),
                                border: Border.all(
                                  color: _getStoneBorderColor(widget.prayer.misbahColorValue, isCenter, theme),
                                  width: 1.5,
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
                                            ? (widget.prayer.misbahColorValue != null
                                                ? Colors.white
                                                : theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8))
                                            : (widget.prayer.misbahColorValue != null
                                                ? Colors.white70
                                                : theme.colorScheme.onSecondaryContainer.withValues(alpha: 0.8)),
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

Gradient _getStoneGradient(int? colorVal, bool isCenter, ThemeData theme) {
  // 1. Graphite (0xFF383838)
  if (colorVal == 0xFF383838) {
    return RadialGradient(
      center: const Alignment(-0.25, -0.25),
      radius: 0.65,
      colors: [
        const Color(0xFF6B6B6B), // Graphite high highlight
        isCenter ? const Color(0xFF262626) : const Color(0xFF383838),
        isCenter ? const Color(0xFF141414) : const Color(0xFF1E1E1E),
      ],
      stops: const [0.0, 0.7, 1.0],
    );
  }
  // 2. Firuz / Turquoise (0xFF30D5C8)
  if (colorVal == 0xFF30D5C8) {
    return RadialGradient(
      center: const Alignment(-0.3, -0.3),
      radius: 0.7,
      colors: [
        const Color(0xFFE0FFFF), // Pale highlight
        isCenter ? const Color(0xFF30D5C8) : const Color(0xFF25A49A),
        isCenter ? const Color(0xFF1B7D75) : const Color(0xFF165D57),
      ],
      stops: const [0.0, 0.65, 1.0],
    );
  }
  // 3. Marble (0xFFEAEAEA)
  if (colorVal == 0xFFEAEAEA) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFFFFFFF),
        isCenter ? const Color(0xFFE5E5E5) : const Color(0xFFD6D6D6),
        isCenter ? const Color(0xFFC0C0C0) : const Color(0xFFB0B0B0),
      ],
      stops: const [0.0, 0.6, 1.0],
    );
  }
  // 4. Quartz (0xFFF7C8DA)
  if (colorVal == 0xFFF7C8DA) {
    return RadialGradient(
      center: const Alignment(-0.2, -0.2),
      radius: 0.65,
      colors: [
        const Color(0xFFFFF2F6), // soft quartz highlight
        isCenter ? const Color(0xFFF7C8DA) : const Color(0xFFE2B2C3),
        isCenter ? const Color(0xFFC18FA1) : const Color(0xFF9E7181),
      ],
      stops: const [0.0, 0.7, 1.0],
    );
  }
  // 5. Wood (0xFF8B5A2B)
  if (colorVal == 0xFF8B5A2B) {
    return RadialGradient(
      center: const Alignment(-0.25, -0.25),
      radius: 0.7,
      colors: [
        const Color(0xFFCD853F), // Warm wood highlight
        isCenter ? const Color(0xFF8B5A2B) : const Color(0xFF6B4226),
        isCenter ? const Color(0xFF5C3317) : const Color(0xFF3D210F),
      ],
      stops: const [0.0, 0.6, 1.0],
    );
  }
  // 6. Stone (0xFF8A9A86)
  if (colorVal == 0xFF8A9A86) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFFB4C2B0), // lighter grey-green stone highlight
        isCenter ? const Color(0xFF8A9A86) : const Color(0xFF71826D),
        isCenter ? const Color(0xFF566353) : const Color(0xFF434C3F),
      ],
      stops: const [0.0, 0.65, 1.0],
    );
  }

  // Fallback / Default color
  return RadialGradient(
    center: const Alignment(-0.3, -0.3),
    radius: 0.6,
    colors: [
      Colors.white.withValues(alpha: 0.4),
      isCenter ? theme.colorScheme.primary : theme.colorScheme.secondary,
      isCenter ? theme.colorScheme.primaryContainer : theme.colorScheme.secondaryContainer,
    ],
    stops: const [0.0, 0.6, 1.0],
  );
}

Color _getStoneBorderColor(int? colorVal, bool isCenter, ThemeData theme) {
  if (colorVal == 0xFF383838) return Colors.black38;
  if (colorVal == 0xFF30D5C8) return const Color(0xFF1B7D75).withValues(alpha: 0.4);
  if (colorVal == 0xFFEAEAEA) return Colors.black12;
  if (colorVal == 0xFFF7C8DA) return const Color(0xFFC18FA1).withValues(alpha: 0.3);
  if (colorVal == 0xFF8B5A2B) return const Color(0xFF3D210F).withValues(alpha: 0.4);
  if (colorVal == 0xFF8A9A86) return const Color(0xFF434C3F).withValues(alpha: 0.3);
  return Colors.transparent;
}
