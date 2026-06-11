import 'package:flutter/material.dart';
import 'package:prayers_counters_app/color_schemes.g.dart';
import 'package:prayers_counters_app/main.dart';
import 'package:prayers_counters_app/prayers_model.dart';
import 'package:prayers_counters_app/preferences.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:m3e_core/m3e_core.dart';

class SettingsPage extends StatefulWidget {
  final bool appearanceOnly;
  const SettingsPage({super.key, this.appearanceOnly = false});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<bool> isSelected = [];
  late int _selectedSettingsSection;
  double _sidebarWidth = 250.0;

  @override
  void initState() {
    super.initState();
    _selectedSettingsSection = widget.appearanceOnly ? 1 : 0;
  }

  final Set<String> _selectedDefaults = {
    "سبحان الله",
    "الحمد لله",
    "الله أكبر",
    "أستغفر الله",
    "لا إله إلا الله",
    "اللهم صل على محمد وآل محمد",
  };

  List<bool> getIsSelected(ThemeColorProvider colorProvider) {
    isSelected = [];
    for (String color in colorSchemes) {
      isSelected
          .add(colorSchemes[colorProvider.colorTheme] == color ? true : false);
    }
    return isSelected;
  }

  Future<void> _addDefaultCounters(BuildContext context) async {
    final themeChangeProvider =
        Provider.of<TheThemeProvider>(context, listen: false);
    final box = Hive.box<Prayer>(boxName);
    final defaults = [
      Prayer("سبحان الله", 33, 0, "سُبْحَانَ اللَّهِ"),
      Prayer("الحمد لله", 33, 0, "الْحَمْدُ لِلَّهِ"),
      Prayer("الله أكبر", 34, 0, "اللَّهُ أَكْبَرُ"),
      Prayer("أستغفر الله", 100, 0, "أَسْتَغْفِرُ اللَّهَ"),
      Prayer("لا إله إلا الله", 100, 0, "لَا إِلَٰهَ إِلَّا اللَّهُ"),
      Prayer("اللهم صل على محمد وآل محمد", 100, 0,
          "اللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ وَآلِ مُحَمَّدٍ"),
    ];

    // Filter by selection
    final selectedDefaults = defaults
        .where((item) => _selectedDefaults.contains(item.name))
        .toList();

    if (selectedDefaults.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              themeChangeProvider.language == 'ar'
                  ? "الرجاء اختيار عداد واحد على الأقل للإضافة."
                  : "Please select at least one counter to add.",
              style: const TextStyle(fontSize: 18)),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: themeChangeProvider.language == 'ar'
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: AlertDialog(
          icon: const Icon(Icons.playlist_add_outlined),
          title: Text(themeChangeProvider.language == 'ar'
              ? "تأكيد إضافة العدادات الافتراضية"
              : "Confirm Adding Default Counters"),
          content: Text(
            themeChangeProvider.language == 'ar'
                ? "هل أنت متأكد من رغبتك في إضافة العدادات المختارة (${selectedDefaults.length})؟"
                : "Are you sure you want to add the selected counters (${selectedDefaults.length})?",
            style: const TextStyle(fontSize: 18),
          ),
          actions: [
            M3ETextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                  themeChangeProvider.language == 'ar' ? "إلغاء" : "Cancel"),
            ),
            M3EFilledButton.tonal(
              onPressed: () => Navigator.pop(context, true),
              child:
                  Text(themeChangeProvider.language == 'ar' ? "إضافة" : "Add"),
            ),
          ],
        ),
      ),
    );

    if (confirm != true) return;

    int addedCount = 0;
    for (var item in selectedDefaults) {
      if (!box.containsKey(item.name)) {
        await box.put(item.name, item);
        addedCount++;
      }
    }

    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            addedCount > 0
                ? (themeChangeProvider.language == 'ar'
                    ? "تم إضافة $addedCount من الأذكار بنجاح."
                    : "Successfully added $addedCount azkar.")
                : (themeChangeProvider.language == 'ar'
                    ? "جميع الأذكار المختارة مضافة بالفعل."
                    : "All selected azkar are already added."),
            style: const TextStyle(fontSize: 18),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeChangeProvider = Provider.of<TheThemeProvider>(context);
    final colorChangeProvider = Provider.of<ThemeColorProvider>(context);
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final theme = Theme.of(context);
    isSelected = getIsSelected(colorChangeProvider);

    final defaultCounters = [
      Prayer("سبحان الله", 33, 0, "سُبْحَانَ اللَّهِ"),
      Prayer("الحمد لله", 33, 0, "الْحَمْدُ لِلَّهِ"),
      Prayer("الله أكبر", 34, 0, "اللَّهُ أَكْبَرُ"),
      Prayer("أستغفر الله", 100, 0, "أَسْتَغْفِرُ اللَّهَ"),
      Prayer("لا إله إلا الله", 100, 0, "لَا إِلَٰهَ إِلَّا اللَّهُ"),
      Prayer("اللهم صل على محمد وآل محمد", 100, 0,
          "اللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ وَآلِ مُحَمَّدٍ"),
    ];
    final box = Hive.box<Prayer>(boxName);

    // 1. DEFAULT COUNTERS CARD
    Widget defaultCountersCard = Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              themeChangeProvider.language == 'ar'
                  ? "العدادات الافتراضية"
                  : "Default Counters",
              style: TextStyle(
                fontSize: themeChangeProvider.fontSize * 0.9,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              themeChangeProvider.language == 'ar'
                  ? "يمكنك إضافة مجموعة من الأذكار والتسبيحات الشائعة إلى قائمتك تلقائياً وبكبسة زر واحدة."
                  : "You can automatically add a collection of common azkar and tasbihs to your list with a single click.",
              style: TextStyle(
                fontSize: themeChangeProvider.fontSize * 0.65,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder(
              valueListenable: box.listenable(),
              builder: (context, Box<Prayer> box, _) {
                return Column(
                  children: defaultCounters.map((item) {
                    final bool alreadyExists = box.containsKey(item.name);
                    final bool isSelected =
                        _selectedDefaults.contains(item.name);

                    return GestureDetector(
                      onTap: alreadyExists
                          ? null
                          : () {
                              setState(() {
                                if (isSelected) {
                                  _selectedDefaults.remove(item.name);
                                } else {
                                  _selectedDefaults.add(item.name);
                                }
                              });
                            },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: alreadyExists
                              ? theme.colorScheme.surfaceContainerLow
                              : (isSelected
                                  ? theme.colorScheme.primaryContainer
                                      .withValues(alpha: 0.15)
                                  : theme.colorScheme.surfaceContainerHighest),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: alreadyExists
                                ? theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.5)
                                : (isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outlineVariant
                                        .withValues(alpha: 0.2)),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    alreadyExists
                                        ? Icons.check_circle
                                        : (isSelected
                                            ? Icons.check_box
                                            : Icons.check_box_outline_blank),
                                    color: alreadyExists
                                        ? theme.colorScheme.primary
                                            .withValues(alpha: 0.6)
                                        : theme.colorScheme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      themeChangeProvider.language == 'ar'
                                          ? item.name
                                          : (item.name == "سبحان الله"
                                              ? "Subhan Allah"
                                              : item.name == "الحمد لله"
                                                  ? "Alhamdulillah"
                                                  : item.name == "الله أكبر"
                                                      ? "Allahu Akbar"
                                                      : item.name ==
                                                              "أستغفر الله"
                                                          ? "Astaghfirullah"
                                                          : item.name ==
                                                                  "لا إله إلا الله"
                                                              ? "La ilaha illallah"
                                                              : "Salawat"),
                                      style: TextStyle(
                                        fontSize:
                                            themeChangeProvider.fontSize * 0.65,
                                        fontWeight: FontWeight.bold,
                                        color: alreadyExists
                                            ? theme.colorScheme.onSurface
                                                .withValues(alpha: 0.6)
                                            : theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              themeChangeProvider.language == 'ar'
                                  ? (item.total <= 0
                                      ? "المقدار: مفتوح"
                                      : "المقدار: ${item.total}")
                                  : (item.total <= 0
                                      ? "Target: Open"
                                      : "Target: ${item.total}"),
                              style: TextStyle(
                                fontSize: themeChangeProvider.fontSize * 0.6,
                                fontWeight: FontWeight.w500,
                                color: alreadyExists
                                    ? theme.colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.6)
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 16),
            M3EElevatedButton.icon(
              onPressed: () => _addDefaultCounters(context),
              decoration: M3EButtonDecoration.styleFrom(
                minimumSize: const Size.fromHeight(55),
                borderRadius: 12,
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
                elevation: 0,
              ),
              icon: const Icon(Icons.playlist_add_outlined),
              label: Text(
                themeChangeProvider.language == 'ar'
                    ? "إضافة الأذكار الافتراضية"
                    : "Add Default Counters",
                style: TextStyle(fontSize: themeChangeProvider.fontSize * 0.65),
              ),
            ),
          ],
        ),
      ),
    );

    // 2. APPEARANCE CARD
    Widget appearanceCard = Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            title: Text(
              themeChangeProvider.language == 'ar'
                  ? "الوضع الداكن"
                  : "Dark Mode",
              style: TextStyle(fontSize: themeChangeProvider.fontSize * 0.75),
            ),
            value: themeChangeProvider.darkTheme,
            onChanged: (bool value) {
              themeChangeProvider.darkTheme = value;
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            title: Text(
              themeChangeProvider.language == 'ar'
                  ? "تفعيل الحركات"
                  : "Enable Animations",
              style: TextStyle(fontSize: themeChangeProvider.fontSize * 0.75),
            ),
            subtitle: Text(
              themeChangeProvider.language == 'ar'
                  ? "إضافة تأثيرات بصرية وحركية عند تحديث العدادات."
                  : "Add visual and motion effects when updating counters.",
              style: TextStyle(
                fontSize: themeChangeProvider.fontSize * 0.55,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            value: themeChangeProvider.enableAnimations,
            onChanged: (bool value) {
              themeChangeProvider.enableAnimations = value;
            },
          ),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            title: Text(
              themeChangeProvider.language == 'ar'
                  ? "تفعيل صوت الاكتمال"
                  : "Enable Completion Sound",
              style: TextStyle(fontSize: themeChangeProvider.fontSize * 0.75),
            ),
            subtitle: Text(
              themeChangeProvider.language == 'ar'
                  ? "تشغيل صوت عند انتهاء العداد."
                  : "Play a sound when a counter is completed.",
              style: TextStyle(
                fontSize: themeChangeProvider.fontSize * 0.55,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            value: themeChangeProvider.enableAudio,
            onChanged: (bool value) {
              themeChangeProvider.enableAudio = value;
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            title: Text(
              themeChangeProvider.language == 'ar'
                  ? "تفعيل صوت المسبحة"
                  : "Enable Misbah Sound",
              style: TextStyle(fontSize: themeChangeProvider.fontSize * 0.75),
            ),
            subtitle: Text(
              themeChangeProvider.language == 'ar'
                  ? "تشغيل صوت التجزئة عند تحريك خرز المسبحة."
                  : "Play tap sound when moving Misbah beads.",
              style: TextStyle(
                fontSize: themeChangeProvider.fontSize * 0.55,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            value: themeChangeProvider.enableMisbahAudio,
            onChanged: (bool value) {
              themeChangeProvider.enableMisbahAudio = value;
            },
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  themeChangeProvider.language == 'ar'
                      ? "السمات"
                      : "Available Themes",
                  style:
                      TextStyle(fontSize: themeChangeProvider.fontSize * 0.75),
                ),
                const SizedBox(height: 16),
                Builder(
                  builder: (context) {
                    final buttons = List.generate(colorSchemes.length, (index) {
                      final bool selected = isSelected[index];
                      Widget childWidget;
                      switch (colorSchemes[index]) {
                        case "Purple":
                          childWidget = themeButton(
                              themeChange: themeChangeProvider,
                              lightColorScheme: purpleLightColorScheme,
                              darkColorScheme: purpleDarkColorScheme);
                          break;
                        case "Baige":
                          childWidget = themeButton(
                              themeChange: themeChangeProvider,
                              lightColorScheme: baigeLightColorScheme,
                              darkColorScheme: baigeDarkColorScheme);
                          break;
                        case "Red":
                          childWidget = themeButton(
                              themeChange: themeChangeProvider,
                              lightColorScheme: redLightColorScheme,
                              darkColorScheme: redDarkColorScheme);
                          break;
                        case "Blue":
                          childWidget = themeButton(
                              themeChange: themeChangeProvider,
                              lightColorScheme: blueLightColorScheme,
                              darkColorScheme: blueDarkColorScheme);
                          break;
                        case "Grey":
                          childWidget = themeButton(
                              themeChange: themeChangeProvider,
                              lightColorScheme: greyLightColorScheme,
                              darkColorScheme: greyDarkColorScheme);
                          break;
                        case "Green":
                          childWidget = themeButton(
                              themeChange: themeChangeProvider,
                              lightColorScheme: greenLightColorScheme,
                              darkColorScheme: greenDarkColorScheme);
                          break;
                        case "Orange":
                          childWidget = themeButton(
                              themeChange: themeChangeProvider,
                              lightColorScheme: orangeLightColorScheme,
                              darkColorScheme: orangeDarkColorScheme);
                          break;
                        case "Device":
                          childWidget = Container(
                            decoration: BoxDecoration(
                              color: themeChangeProvider.darkTheme
                                  ? Colors.grey[800]
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: FloatingActionButton.small(
                              heroTag: "deviceTheme",
                              elevation: 0,
                              onPressed: null,
                              backgroundColor: Colors.transparent,
                              foregroundColor: themeChangeProvider.darkTheme
                                  ? Colors.white
                                  : Colors.black,
                              child: const Icon(Icons.phone_android),
                            ),
                          );
                          break;
                        default:
                          childWidget = const SizedBox();
                      }

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            for (int buttonIndex = 0;
                                buttonIndex < isSelected.length;
                                buttonIndex++) {
                              if (buttonIndex == index) {
                                isSelected[buttonIndex] = true;
                                colorChangeProvider.colorTheme = buttonIndex;
                              } else {
                                isSelected[buttonIndex] = false;
                              }
                            }
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected
                                  ? theme.colorScheme.primary
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          padding: const EdgeInsets.all(2),
                          child: childWidget,
                        ),
                      );
                    });

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: buttons
                              .sublist(0, 4)
                              .map((b) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                  child: b))
                              .toList(),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: buttons
                              .sublist(4, 8)
                              .map((b) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                  child: b))
                              .toList(),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  themeChangeProvider.language == 'ar'
                      ? "حجم الخط"
                      : "Font Size",
                  style:
                      TextStyle(fontSize: themeChangeProvider.fontSize * 0.75),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Slider(
                    value: themeChangeProvider.fontSize,
                    max: 100,
                    min: 20,
                    divisions: 7,
                    label: themeChangeProvider.fontSize.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        themeChangeProvider.fontSize = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "لغة التطبيق / Language",
                  style:
                      TextStyle(fontSize: themeChangeProvider.fontSize * 0.75),
                ),
                const SizedBox(height: 12),
                SafeArea(
                  child: Center(
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: M3EToggleButtonGroup(
                        type: M3EButtonGroupType.connected,
                        selectedIndex:
                            themeChangeProvider.language == 'ar' ? 0 : 1,
                        onSelectedIndexChanged: (index) {
                          setState(() {
                            themeChangeProvider.language =
                                index == 0 ? 'ar' : 'en';
                          });
                        },
                        actions: [
                          M3EToggleButtonGroupAction(
                            label: const Text(
                              'العربية',
                              style: TextStyle(fontSize: 20),
                            ),
                            semanticLabel: 'Arabic',
                          ),
                          M3EToggleButtonGroupAction(
                            label: const Text(
                              'English',
                              style: TextStyle(fontSize: 20),
                            ),
                            semanticLabel: 'English',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // 3. ADVANCED OPTIONS CARD
    Widget advancedCard = Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 8),
            child: Text(
              themeChangeProvider.language == 'ar'
                  ? "خيارات متقدمة"
                  : "Advanced Options",
              style: TextStyle(
                fontSize: themeChangeProvider.fontSize * 0.9,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            title: Text(
              themeChangeProvider.language == 'ar'
                  ? "تأكيد عند تصفير العداد"
                  : "Confirm on Reset",
              style: TextStyle(fontSize: themeChangeProvider.fontSize * 0.75),
            ),
            subtitle: Text(
              themeChangeProvider.language == 'ar'
                  ? "طلب تأكيد قبل إعادة تصفير عداد معين."
                  : "Ask for confirmation before resetting a counter.",
              style: TextStyle(
                fontSize: themeChangeProvider.fontSize * 0.55,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            value: themeChangeProvider.confirmReset,
            onChanged: (bool value) {
              themeChangeProvider.confirmReset = value;
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            title: Text(
              themeChangeProvider.language == 'ar'
                  ? "تأكيد عند الإكمال"
                  : "Confirm on Tasbih",
              style: TextStyle(fontSize: themeChangeProvider.fontSize * 0.75),
            ),
            subtitle: Text(
              themeChangeProvider.language == 'ar'
                  ? "طلب تأكيد من الشاشة الرئيسية عند الضغط على زر التسبيح (تسبيح)."
                  : "Ask for confirmation on the home screen when tapping the tasbih button.",
              style: TextStyle(
                fontSize: themeChangeProvider.fontSize * 0.55,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            value: themeChangeProvider.confirmIncrement,
            onChanged: (bool value) {
              themeChangeProvider.confirmIncrement = value;
            },
          ),
          const Divider(height: 1),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            title: Text(
              themeChangeProvider.language == 'ar'
                  ? "تأكيد عند التراجع"
                  : "Confirm on Undo",
              style: TextStyle(fontSize: themeChangeProvider.fontSize * 0.75),
            ),
            subtitle: Text(
              themeChangeProvider.language == 'ar'
                  ? "طلب تأكيد قبل تقليل العداد عن طريق زر التراجع (-)."
                  : "Ask for confirmation before decrementing a counter using the undo button (-).",
              style: TextStyle(
                fontSize: themeChangeProvider.fontSize * 0.55,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            value: themeChangeProvider.confirmDecrement,
            onChanged: (bool value) {
              themeChangeProvider.confirmDecrement = value;
            },
          ),
        ],
      ),
    );

    // 4. DATA MANAGEMENT CARD
    Widget dataManagementCard = Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              themeChangeProvider.language == 'ar'
                  ? "إدارة البيانات"
                  : "Data Management",
              style: TextStyle(
                fontSize: themeChangeProvider.fontSize * 0.9,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              themeChangeProvider.language == 'ar'
                  ? "يمكنك تصفير قيم العدادات أو حذف جميع بيانات التطبيق تماماً. يرجى الحذر، حيث لا يمكن التراجع عن هذه الإجراءات."
                  : "You can reset counter values or delete all app data entirely. Please be careful, as these actions cannot be undone.",
              style: TextStyle(
                fontSize: themeChangeProvider.fontSize * 0.65,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            M3EElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => Directionality(
                    textDirection: themeChangeProvider.language == 'ar'
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    child: AlertDialog(
                      icon: const Icon(Icons.refresh_outlined),
                      title: Text(themeChangeProvider.language == 'ar'
                          ? "تصفير العدادات؟"
                          : "Reset Counters?"),
                      content: Text(
                        themeChangeProvider.language == 'ar'
                            ? "هل أنت متأكد من تصفير قيم جميع العدادات والبدء من الصفر?"
                            : "Are you sure you want to reset all counters and start from zero?",
                        style: const TextStyle(fontSize: 18),
                      ),
                      actions: [
                        M3ETextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(themeChangeProvider.language == 'ar'
                              ? "إلغاء"
                              : "Cancel"),
                        ),
                        M3EFilledButton.tonal(
                          onPressed: () async {
                            final box = Hive.box<Prayer>(boxName);
                            for (var key in box.keys) {
                              final p = box.get(key);
                              if (p != null) {
                                p.finished = 0;
                                p.numberOfCompletedPrayers = 0;
                                await box.put(key, p);
                              }
                            }
                            if (context.mounted) Navigator.pop(context);
                          },
                          child: Text(themeChangeProvider.language == 'ar'
                              ? "تصفير"
                              : "Reset"),
                        ),
                      ],
                    ),
                  ),
                );
              },
              decoration: M3EButtonDecoration.styleFrom(
                minimumSize: const Size.fromHeight(55),
                borderRadius: 12,
                backgroundColor: theme.colorScheme.secondaryContainer,
                foregroundColor: theme.colorScheme.onSecondaryContainer,
                elevation: 0,
              ),
              icon: const Icon(Icons.refresh_outlined),
              label: Text(
                themeChangeProvider.language == 'ar'
                    ? "تصفير جميع العدادات"
                    : "Reset All Counters",
                style: TextStyle(fontSize: themeChangeProvider.fontSize * 0.65),
              ),
            ),
            const SizedBox(height: 12),
            M3EElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => Directionality(
                    textDirection: themeChangeProvider.language == 'ar'
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    child: AlertDialog(
                      icon: const Icon(Icons.delete_forever_outlined),
                      title: Text(themeChangeProvider.language == 'ar'
                          ? "حذف جميع العدادات؟"
                          : "Delete All Counters?"),
                      content: Text(
                        themeChangeProvider.language == 'ar'
                            ? "هل أنت متأكد من حذف كافة العدادات من التطبيق نهائياً؟"
                            : "Are you sure you want to delete all counters from the app permanently?",
                        style: const TextStyle(fontSize: 18),
                      ),
                      actions: [
                        M3ETextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(themeChangeProvider.language == 'ar'
                              ? "إلغاء"
                              : "Cancel"),
                        ),
                        M3EFilledButton.tonal(
                          onPressed: () async {
                            final box = Hive.box<Prayer>(boxName);
                            await box.clear();
                            if (context.mounted) Navigator.pop(context);
                          },
                          child: Text(themeChangeProvider.language == 'ar'
                              ? "حذف"
                              : "Delete"),
                        ),
                      ],
                    ),
                  ),
                );
              },
              decoration: M3EButtonDecoration.styleFrom(
                minimumSize: const Size.fromHeight(55),
                borderRadius: 12,
                backgroundColor: theme.colorScheme.errorContainer,
                foregroundColor: theme.colorScheme.onErrorContainer,
                elevation: 0,
              ),
              icon: const Icon(Icons.delete_forever_outlined),
              label: Text(
                themeChangeProvider.language == 'ar'
                    ? "حذف جميع العدادات"
                    : "Delete All Counters",
                style: TextStyle(fontSize: themeChangeProvider.fontSize * 0.65),
              ),
            ),
          ],
        ),
      ),
    );

    // 5. FOOTER
    Widget footer = widget.appearanceOnly
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Center(
              child: Opacity(
                opacity: 0.6,
                child: Column(
                  children: [
                    Text(
                      "v1.0.7",
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      themeChangeProvider.language == 'ar'
                          ? "من انتاج كمَّثرى"
                          : "Made by Kumthra",
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );

    // 6. MAIN RESPONSIVE LAYOUT
    return Directionality(
      textDirection: themeChangeProvider.language == 'ar'
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surfaceContainer,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            widget.appearanceOnly
                ? (themeChangeProvider.language == 'ar'
                    ? "المظهر"
                    : "Appearance")
                : (themeChangeProvider.language == 'ar'
                    ? "الإعدادات"
                    : "Settings"),
            style: TextStyle(
              fontFamily: "Lateef",
              fontSize: themeChangeProvider.fontSize + 5,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ),
        body: Builder(builder: (context) {
          if (widget.appearanceOnly) {
            // APPEARANCE ONLY VIEW
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    appearanceCard,
                    const SizedBox(height: 16),
                    footer,
                  ],
                ),
              ),
            );
          }

          if (isDesktop) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SIDEBAR
                SizedBox(
                  width: _sidebarWidth,
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          children: [
                            ListTile(
                              title: Text(
                                themeChangeProvider.language == 'ar'
                                    ? "العدادات الافتراضية"
                                    : "Default Counters",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              selected: _selectedSettingsSection == 0,
                              onTap: () =>
                                  setState(() => _selectedSettingsSection = 0),
                              leading: const Icon(Icons.playlist_add_outlined),
                            ),
                            ListTile(
                              title: Text(
                                themeChangeProvider.language == 'ar'
                                    ? "خيارات متقدمة"
                                    : "Advanced Options",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              selected: _selectedSettingsSection == 2,
                              onTap: () =>
                                  setState(() => _selectedSettingsSection = 2),
                              leading: const Icon(Icons.tune_outlined),
                            ),
                            ListTile(
                              title: Text(
                                themeChangeProvider.language == 'ar'
                                    ? "إدارة البيانات"
                                    : "Data Management",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              selected: _selectedSettingsSection == 3,
                              onTap: () =>
                                  setState(() => _selectedSettingsSection = 3),
                              leading: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ),
                      footer,
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                // SPLIT RESIZER
                MouseRegion(
                  cursor: SystemMouseCursors.resizeColumn,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragUpdate: (details) {
                      setState(() {
                        // In RTL, dragging left increases the right sidebar, dragging right decreases it
                        _sidebarWidth -= details.delta.dx;
                        _sidebarWidth = _sidebarWidth.clamp(150.0, 500.0);
                      });
                    },
                    child: const VerticalDivider(
                      width: 15,
                      thickness: 1,
                    ),
                  ),
                ),
                // CONTENT VIEW
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: ListView(
                          children: [
                            if (_selectedSettingsSection == 0)
                              defaultCountersCard,
                            if (_selectedSettingsSection == 2) advancedCard,
                            if (_selectedSettingsSection == 3)
                              dataManagementCard,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          // MOBILE VIEW (Vertical List of all Cards, excluding appearanceCard)
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              defaultCountersCard,
              const SizedBox(height: 16),
              advancedCard,
              const SizedBox(height: 16),
              dataManagementCard,
              const SizedBox(height: 16),
              footer,
            ],
          );
        }),
      ),
    );
  }
}

// ignore: camel_case_types
class themeButton extends StatelessWidget {
  const themeButton({
    super.key,
    required this.themeChange,
    required this.lightColorScheme,
    required this.darkColorScheme,
  });

  final TheThemeProvider themeChange;
  final ColorScheme lightColorScheme;
  final ColorScheme darkColorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FloatingActionButton.small(
        heroTag: 'themeFab-${lightColorScheme} - ${darkColorScheme}',
        elevation: 0,
        onPressed: null,
        foregroundColor: themeChange.darkTheme
            ? lightColorScheme.onPrimaryContainer
            : darkColorScheme.onPrimaryContainer,
        backgroundColor: themeChange.darkTheme
            ? lightColorScheme.primaryContainer
            : darkColorScheme.primaryContainer,
        child: const Icon(Icons.add),
      ),
    );
  }
}
