import 'dart:ui';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:prayer_counter/color_schemes.g.dart';
import 'package:prayer_counter/prayers_model.dart';
import 'package:provider/provider.dart';

import 'settings.dart';

String boxName = 'prayersBox';
String boxName2 = 'fastingBox';
String settingsBox = 'settings';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter<Prayer>(PrayerAdapter());
  await Hive.openBox<Prayer>(boxName);
  await Hive.openBox<Prayer>(boxName2);
  await Hive.openBox(settingsBox);

  runApp(const MyApp());
}

List<String> colorSchemes = [
  "Purple",
  "Baige",
  "Red",
  "Blue",
  "Grey",
  "Green",
  "Device"
];

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TheThemeProvider themeChangeProvider = TheThemeProvider();
  ThemeColorProvider colorChangeProvider = ThemeColorProvider();

  @override
  void initState() {
    super.initState();
    getCurrentAppTheme();
    getCurrentColorTheme();
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.fontSize =
        await themeChangeProvider.preference.getFontSize();
    themeChangeProvider.darkTheme =
        await themeChangeProvider.preference.getTheme();
  }

  void getCurrentColorTheme() async {
    colorChangeProvider.colorTheme =
        await colorChangeProvider.colorThemePreference.getThemeColor();
  }

  ColorScheme colorSchemeChooser(int color, bool darkMode,
      {ColorScheme? deviceLightColorTheme, ColorScheme? deviceDarkColorTheme}) {
    switch (colorSchemes[color]) {
      case "Purple":
        return darkMode ? purpleDarkColorScheme : purpleLightColorScheme;
      case "Baige":
        return darkMode ? baigeDarkColorScheme : baigeLightColorScheme;
      case "Red":
        return darkMode ? redDarkColorScheme : redLightColorScheme;

      case "Grey":
        return darkMode ? greyDarkColorScheme : greyLightColorScheme;
      case "Green":
        return darkMode ? greenDarkColorScheme : greenLightColorScheme;
      case "Blue":
        return darkMode ? blueDarkColorScheme : blueLightColorScheme;
      case "Device":
        return darkMode
            ? (deviceDarkColorTheme ?? blueDarkColorScheme)
            : (deviceLightColorTheme ?? blueLightColorScheme);
    }
    return darkMode ? blueDarkColorScheme : blueLightColorScheme;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => themeChangeProvider,
      child: Consumer<TheThemeProvider>(
        builder: (BuildContext context, value, _) => DynamicColorBuilder(
          builder: (deviceLightColorScheme, deviceDarkColorScheme) =>
              ChangeNotifierProvider(
            create: (_) => colorChangeProvider,
            child: Consumer<ThemeColorProvider>(
              builder: (BuildContext context, value, change) => MaterialApp(
                title: 'عداد القضاء',
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  textTheme: textTheme,
                  colorScheme: colorSchemeChooser(
                      colorChangeProvider.colorTheme, false,
                      deviceLightColorTheme: deviceLightColorScheme,
                      deviceDarkColorTheme: deviceDarkColorScheme),
                  useMaterial3: true,
                ),
                darkTheme: ThemeData(
                  textTheme: textTheme,
                  colorScheme: colorSchemeChooser(
                      colorChangeProvider.colorTheme, true,
                      deviceLightColorTheme: deviceLightColorScheme,
                      deviceDarkColorTheme: deviceDarkColorScheme),
                  useMaterial3: true,
                ),
                themeMode: themeChangeProvider.darkTheme
                    ? ThemeMode.dark
                    : ThemeMode.light,
                initialRoute: "/",
                routes: {
                  "/": (context) => const Directionality(
                      textDirection: TextDirection.rtl, child: MyHomePage()),
                  "/settings": (context) => const Directionality(
                      textDirection: TextDirection.rtl, child: SettingsPage()),
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<bool> isSelected = [];
  List<bool> getIsSelected(ThemeColorProvider colorProvider) {
    isSelected = [];
    for (String color in colorSchemes) {
      isSelected
          .add(colorSchemes[colorProvider.colorTheme] == color ? true : false);
    }
    return isSelected;
  }

  @override
  Widget build(BuildContext context) {
    final themeChangeProvider = Provider.of<TheThemeProvider>(context);
    final colorChangeProvider = Provider.of<ThemeColorProvider>(context);
    isSelected = getIsSelected(colorChangeProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.background,
            bottom: TabBar(
              tabs: [
                Tab(
                    child: Text("الصلوات",
                        style:
                            TextStyle(fontSize: themeChangeProvider.fontSize))),
                Tab(
                    child: Text("الصيام",
                        style:
                            TextStyle(fontSize: themeChangeProvider.fontSize))),
              ],
            ),
            actions: [
              IconButton(
                  onPressed: () => Navigator.pushNamed(context, "/settings"),
                  icon: const Icon(Icons.settings_outlined))
            ],
            leading: IconButton(
                icon: const Icon(Icons.color_lens_outlined),
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Directionality(
                          textDirection: TextDirection.rtl,
                          child: Scaffold(
                            appBar: AppBar(
                                leading: IconButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    icon: const Icon(Icons.close)),
                                centerTitle: true,
                                title: Text(
                                  "المظهر",
                                  style: TextStyle(
                                      fontSize:
                                          themeChangeProvider.fontSize + 5),
                                )),
                            body: Column(children: [
                              SwitchListTile(
                                  title: Text("الوضع الداكن",
                                      style: TextStyle(
                                          fontSize:
                                              themeChangeProvider.fontSize)),
                                  value: themeChangeProvider.darkTheme,
                                  onChanged: (bool value) {
                                    themeChangeProvider.darkTheme = value;
                                  }),
                              const SizedBox(height: 10),
                              Text(
                                "السمات",
                                style: TextStyle(
                                    fontSize: themeChangeProvider.fontSize),
                                textAlign: TextAlign.end,
                              ),
                              Center(
                                child: ToggleButtons(
                                  selectedBorderColor:
                                      Theme.of(context).colorScheme.primary,
                                  borderWidth: 4,
                                  isSelected: isSelected,
                                  onPressed: (int index) {
                                    setState(() {
                                      for (int buttonIndex = 0;
                                          buttonIndex < isSelected.length;
                                          buttonIndex++) {
                                        if (buttonIndex == index) {
                                          isSelected[buttonIndex] = true;
                                          colorChangeProvider.colorTheme =
                                              buttonIndex;
                                        } else {
                                          isSelected[buttonIndex] = false;
                                        }
                                      }
                                    });
                                  },
                                  children: <Widget>[
                                    themeButton(
                                        themeChange: themeChangeProvider,
                                        lightColorScheme:
                                            purpleLightColorScheme,
                                        darkColorScheme: purpleDarkColorScheme),
                                    themeButton(
                                        themeChange: themeChangeProvider,
                                        lightColorScheme: baigeLightColorScheme,
                                        darkColorScheme: baigeDarkColorScheme),
                                    themeButton(
                                        themeChange: themeChangeProvider,
                                        lightColorScheme: redLightColorScheme,
                                        darkColorScheme: redDarkColorScheme),
                                    themeButton(
                                        themeChange: themeChangeProvider,
                                        lightColorScheme: blueLightColorScheme,
                                        darkColorScheme: blueDarkColorScheme),
                                    themeButton(
                                        themeChange: themeChangeProvider,
                                        lightColorScheme: greyLightColorScheme,
                                        darkColorScheme: greyDarkColorScheme),
                                    themeButton(
                                        themeChange: themeChangeProvider,
                                        lightColorScheme: greenLightColorScheme,
                                        darkColorScheme: greenDarkColorScheme),
                                    const Icon(Icons.phone_android),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "حجم الخط",
                                style: TextStyle(
                                    fontSize: themeChangeProvider.fontSize),
                                textAlign: TextAlign.end,
                              ),
                              Center(
                                child: Slider(
                                  value: themeChangeProvider.fontSize,
                                  max: 36,
                                  min: 20,
                                  divisions: 7,
                                  label: themeChangeProvider.fontSize
                                      .round()
                                      .toString(),
                                  onChanged: (double value) {
                                    setState(() {
                                      themeChangeProvider.fontSize = value;
                                    });
                                  },
                                ),
                              ),
                            ]),
                          ),
                        );
                      });
                }),
            centerTitle: true,
            title: Text("عداد القضاء",
                style: TextStyle(
                    fontFamily: "Lateef",
                    fontSize: themeChangeProvider.fontSize + 5))),
        body: TabBarView(
          children: [
            ValueListenableBuilder<Box<Prayer>>(
                valueListenable: Hive.box<Prayer>(boxName).listenable(),
                builder: (context, Box<Prayer> box, widget) {
                  if (box.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Image(image: AssetImage('images/kaaba_3d.png')),
                          Text(
                            "عداد قضاء الصلوات",
                            style: TextStyle(
                                fontSize: themeChangeProvider.fontSize + 20,
                                fontFamily: "Lateef"),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          FilledButton(
                              onPressed: () {
                                Navigator.pushNamed(context, "/settings");
                              },
                              child: Text(
                                "إعدادات",
                                style: TextStyle(
                                    fontSize: themeChangeProvider.fontSize + 5),
                              ))
                        ],
                      ),
                    );
                  } else {
                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: box.values.length,
                            itemBuilder: (context, i) {
                              var prayer = box.getAt(i)!;
                              return SizedBox(
                                height: MediaQuery.of(context).size.height / 7,
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      SizedBox(
                                        width: 40,
                                        child: IconButton(
                                            icon: const Icon(
                                                Icons.remove_circle_outline),
                                            onPressed: () {
                                              if (prayer.finished > 0) {
                                                confirmationAlert(context,
                                                    prayer, box, i, false);
                                              }
                                            }),
                                      ),
                                      SizedBox(
                                        width: 100,
                                        child: Text(
                                          prayer.name,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      prayer.finished == prayer.total
                                          ? Container()
                                          : FilledButton(
                                              style: FilledButton.styleFrom(
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .secondary),
                                              child: Text(
                                                "قضيت",
                                                style: TextStyle(
                                                    fontSize:
                                                        themeChangeProvider
                                                                .fontSize -
                                                            5,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .background),
                                              ),
                                              onPressed: () async {
                                                if (prayer.finished <
                                                    prayer.total) {
                                                  confirmationAlert(context,
                                                      prayer, box, i, true);
                                                }
                                              }),
                                      CircleAvatar(
                                          maxRadius: 45,
                                          child: prayer.finished == prayer.total
                                              ? Text("تقبل الله")
                                              : Text(
                                                  "${prayer.finished}/${prayer.total}",
                                                  style: const TextStyle(
                                                    fontFamily: 'Ubuntu Mono',
                                                    fontSize: 30,
                                                    fontFeatures: <FontFeature>[
                                                      FontFeature.fractions(),
                                                    ],
                                                  ),
                                                )),
                                    ]),
                              );
                            },
                          ),
                        ),
                        SizedBox(
                            height: 80,
                            child: Center(
                                child: Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Text("تقبل الله أعمالكم",
                                  style: TextStyle(
                                      fontSize: 30, fontFamily: "Lateef")),
                            ))),
                      ],
                    );
                  }
                }),
            ValueListenableBuilder<Box<Prayer>>(
                valueListenable: Hive.box<Prayer>(boxName2).listenable(),
                builder: (context, Box<Prayer> box, widget) {
                  if (box.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image(image: AssetImage('images/moon_3d.png')),
                          Text(
                            "عداد قضاء الصيام",
                            style: TextStyle(
                                fontSize: themeChangeProvider.fontSize + 20,
                                fontFamily: "Lateef"),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          FilledButton(
                              onPressed: () {
                                Navigator.pushNamed(context, "/settings");
                              },
                              child: Text(
                                "إعدادات",
                                style: TextStyle(
                                    fontSize: themeChangeProvider.fontSize + 5),
                              ))
                        ],
                      ),
                    );
                  } else {
                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: box.values.length,
                            itemBuilder: (context, i) {
                              var prayer = box.getAt(i)!;
                              return SizedBox(
                                height: MediaQuery.of(context).size.height / 7,
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      SizedBox(
                                        width: 40,
                                        child: IconButton(
                                            icon: const Icon(
                                                Icons.remove_circle_outline),
                                            onPressed: () {
                                              if (prayer.finished > 0) {
                                                fastingConfirmationAlert(
                                                    context,
                                                    prayer,
                                                    box,
                                                    i,
                                                    false);
                                              }
                                            }),
                                      ),
                                      SizedBox(
                                        width: 100,
                                        child: Text(
                                          prayer.name,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      prayer.finished == prayer.total
                                          ? Container()
                                          : FilledButton(
                                              style: FilledButton.styleFrom(
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .secondary),
                                              child: Text(
                                                "قضيت",
                                                style: TextStyle(
                                                    fontSize:
                                                        themeChangeProvider
                                                                .fontSize -
                                                            5,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .background),
                                              ),
                                              onPressed: () async {
                                                if (prayer.finished <
                                                    prayer.total) {
                                                  fastingConfirmationAlert(
                                                      context,
                                                      prayer,
                                                      box,
                                                      i,
                                                      true);
                                                }
                                              }),
                                      CircleAvatar(
                                          maxRadius: 45,
                                          child: prayer.finished == prayer.total
                                              ? Text("تقبل الله")
                                              : Text(
                                                  "${prayer.finished}/${prayer.total}",
                                                  style: const TextStyle(
                                                    fontFamily: 'Ubuntu Mono',
                                                    fontSize: 30,
                                                    fontFeatures: <FontFeature>[
                                                      FontFeature.fractions(),
                                                    ],
                                                  ),
                                                )),
                                    ]),
                              );
                            },
                          ),
                        ),
                        const SizedBox(
                            height: 80,
                            child: Center(
                                child: Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Text("تقبل الله أعمالكم",
                                  style: TextStyle(
                                      fontSize: 30, fontFamily: "Lateef")),
                            ))),
                      ],
                    );
                  }
                })
          ],
        ),
      ),
    );
  }

  Future<dynamic> confirmationAlert(BuildContext context, Prayer prayer,
      Box<Prayer> box, int i, bool addition) {
    return showDialog(
        context: context,
        builder: (context) => Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                icon: Icon(addition
                    ? Icons.done_outline_outlined
                    : Icons.cancel_outlined),
                title: Text(addition ? "قضيت الصلاة ؟" : "لم تقضي الصلاة ؟"),
                content: Text(
                  addition
                      ? "هل انت متأكد من انك قضيت صلاة ${prayer.name} ؟"
                      : "هل انت متأكد من انك لم تقضي صلاة ${prayer.name} ؟",
                  style: const TextStyle(fontSize: 20),
                ),
                actions: [
                  TextButton(
                      child: const Text(
                        "لا",
                        style: TextStyle(fontSize: 15),
                      ),
                      onPressed: () => Navigator.pop(context)),
                  TextButton(
                      child: const Text(
                        "نعم",
                        style: TextStyle(fontSize: 15),
                      ),
                      onPressed: () async {
                        if (addition) {
                          if (prayer.finished != prayer.total) {
                            prayer.finished += 1;
                          }
                        } else {
                          if (prayer.finished > 0) prayer.finished -= 1;
                        }

                        await box
                            .putAt(i, prayer)
                            .then((e) => Navigator.pop(context));
                      })
                ],
              ),
            ));
  }

  Future<dynamic> fastingConfirmationAlert(BuildContext context, Prayer prayer,
      Box<Prayer> box, int i, bool addition) {
    return showDialog(
        context: context,
        builder: (context) => Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                icon: Icon(addition
                    ? Icons.done_outline_outlined
                    : Icons.cancel_outlined),
                title: Text(addition ? "قضيت الصيام ؟" : "لم تقضي الصيام ؟"),
                content: Text(
                  addition
                      ? "هل انت متأكد من انك قضيت صيام ${prayer.name} ؟"
                      : "هل انت متأكد من انك لم تقضي صيام ${prayer.name} ؟",
                  style: const TextStyle(fontSize: 20),
                ),
                actions: [
                  TextButton(
                      child: const Text(
                        "لا",
                        style: TextStyle(fontSize: 15),
                      ),
                      onPressed: () => Navigator.pop(context)),
                  TextButton(
                      child: const Text(
                        "نعم",
                        style: TextStyle(fontSize: 15),
                      ),
                      onPressed: () async {
                        if (addition) {
                          if (prayer.finished != prayer.total) {
                            prayer.finished += 1;
                          }
                        } else {
                          if (prayer.finished > 0) prayer.finished -= 1;
                        }

                        await box
                            .putAt(i, prayer)
                            .then((e) => Navigator.pop(context));
                      })
                ],
              ),
            ));
  }
}

class themeButton extends StatelessWidget {
  const themeButton(
      {super.key,
      required this.themeChange,
      required this.lightColorScheme,
      required this.darkColorScheme});

  final TheThemeProvider themeChange;
  final ColorScheme lightColorScheme;
  final ColorScheme darkColorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: themeChange.darkTheme
            ? darkColorScheme.background
            : lightColorScheme.background,
        child: FloatingActionButton.small(
          elevation: 0,
          onPressed: null,
          foregroundColor: themeChange.darkTheme
              ? darkColorScheme.background
              : lightColorScheme.background,
          backgroundColor: themeChange.darkTheme
              ? darkColorScheme.secondary
              : lightColorScheme.secondary,
          child: const Icon(Icons.add),
        ));
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _daysController = TextEditingController();
  final TextEditingController _monthsController = TextEditingController();
  final TextEditingController _yearsController = TextEditingController();

  final TextEditingController _fastingDays1Controller = TextEditingController();
  final TextEditingController _fastingMonths1Controller =
      TextEditingController();

  final TextEditingController _fastingDays2Controller = TextEditingController();
  final TextEditingController _fastingMonths2Controller =
      TextEditingController();

  final TextEditingController _fastingDays3Controller = TextEditingController();
  final TextEditingController _fastingMonths3Controller =
      TextEditingController();

  final box = Hive.box<Prayer>(boxName);
  final fastingBox = Hive.box<Prayer>(boxName2);

  final settings = Hive.box(settingsBox);

  @override
  void initState() {
    _daysController.text = settings.get('days') ?? "";
    _monthsController.text = settings.get('months') ?? "";
    _yearsController.text = settings.get('years') ?? "";

    _fastingDays1Controller.text = settings.get('fastingDays') ?? "";
    _fastingMonths1Controller.text = settings.get('fastingMonths') ?? "";
    _fastingDays2Controller.text = settings.get('fastingDays2') ?? "";
    _fastingMonths2Controller.text = settings.get('fastingMonths2') ?? "";
    _fastingDays3Controller.text = settings.get('fastingDays3') ?? "";
    _fastingMonths3Controller.text = settings.get('fastingMonths3') ?? "";

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeChangeProvider = Provider.of<TheThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) => Directionality(
                            textDirection: TextDirection.rtl,
                            child: AlertDialog(
                              icon: Icon(Icons.warning_outlined),
                              title: Text("هل تريد تصفير العدادات؟"),
                              content: Text(
                                "هل انت متأكد انك تبي تصفر العدادات للصلاة والصيام؟",
                                style: const TextStyle(fontSize: 20),
                              ),
                              actions: [
                                TextButton(
                                    child: const Text(
                                      "لا",
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    onPressed: () => Navigator.pop(context)),
                                TextButton(
                                    child: const Text(
                                      "نعم",
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    onPressed: () async {
                                      _daysController.text = "";
                                      _monthsController.text = "";

                                      _fastingDays1Controller.text = "";
                                      _fastingMonths1Controller.text = "";

                                      _fastingDays2Controller.text = "";
                                      _fastingMonths2Controller.text = "";

                                      _fastingDays3Controller.text = "";
                                      _fastingMonths3Controller.text = "";

                                      settings.putAll({
                                        'days': '',
                                        'months': '',
                                        'years': '',
                                        'fastingDays': '',
                                        'fastingMonths': '',
                                        'fastingDays2': '',
                                        'fastingMonths2': '',
                                        'fastingDays3': '',
                                        'fastingMonths3': '',
                                      });

                                      await box
                                          .clear()
                                          .then((e) => Navigator.pop(context));
                                    })
                              ],
                            ),
                          ));
                },
                icon: Icon(Icons.delete_forever_outlined))
          ],
          title: Text(
            "الإعدادات",
            style: TextStyle(
                fontFamily: "Lateef",
                fontSize: themeChangeProvider.fontSize + 5),
          )),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ValueListenableBuilder<Box>(
          valueListenable: Hive.box(settingsBox).listenable(),
          builder: (context, box, _) {
            return ListView(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("الصلوات",
                      style:
                          TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  TextField(
                      style: TextStyle(fontSize: 20),
                      controller: _daysController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _daysController.text = "";
                            },
                          ),
                          label: Text(
                            "عدد الأيام",
                            style: TextStyle(
                                fontSize: themeChangeProvider.fontSize - 5),
                          ),
                          border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  TextField(
                      style: TextStyle(fontSize: 20),
                      controller: _monthsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _monthsController.text = "";
                            },
                          ),
                          label: Text(
                            "عدد الشهور",
                            style: TextStyle(
                                fontSize: themeChangeProvider.fontSize - 5),
                          ),
                          border: OutlineInputBorder())),
                  const SizedBox(height: 10),
                  TextField(
                      style: TextStyle(fontSize: 20),
                      controller: _yearsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              _yearsController.text = "";
                            },
                          ),
                          label: Text(
                            "عدد السنين",
                            style: TextStyle(
                                fontSize: themeChangeProvider.fontSize - 5),
                          ),
                          border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                      onPressed: () async {
                        int days = int.parse(_daysController.text.isEmpty
                            ? "0"
                            : _daysController.text);
                        int months = int.parse(_monthsController.text.isEmpty
                            ? "0"
                            : _monthsController.text);
                        int years = int.parse(_yearsController.text.isEmpty
                            ? "0"
                            : _yearsController.text);
                        int numberOfPrayers =
                            days + (months * 30) + (years * 345);
                        settings.putAll({
                          'days': _daysController.text,
                          'months': _monthsController.text,
                          'years': _yearsController.text
                        });
                        await Hive.box<Prayer>(boxName).clear();
                        if (numberOfPrayers > 0) {
                          await Hive.box<Prayer>(boxName).addAll([
                            Prayer("الصبح", numberOfPrayers, 0),
                            Prayer("الظهر", numberOfPrayers, 0),
                            Prayer("العصر", numberOfPrayers, 0),
                            Prayer("المغرب", numberOfPrayers, 0),
                            Prayer("العشاء", numberOfPrayers, 0),
                          ]).then((value) => ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.secondary,
                                  content: Text(
                                    "تمت إضافة العدادات للصلاة بنجاح",
                                    style: TextStyle(fontSize: 20),
                                  ))));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40),
                      ),
                      icon: const Icon(Icons.calculate),
                      label: Text("حساب (الصلوات)",
                          style: TextStyle(
                              fontSize: themeChangeProvider.fontSize - 8))),
                  const SizedBox(height: 40),
                  const Text("الصيام",
                      style:
                          TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const SizedBox(height: 12),
                  ExpansionTile(
                    title: Text("صيام القضاء",
                        style: TextStyle(
                            fontSize: themeChangeProvider.fontSize + 5)),
                    children: [
                      const SizedBox(height: 15),
                      TextField(
                          style: TextStyle(fontSize: 20),
                          controller: _fastingDays1Controller,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  _fastingDays1Controller.text = "";
                                },
                              ),
                              label: Text(
                                "عدد الأيام",
                                style: TextStyle(
                                    fontSize: themeChangeProvider.fontSize - 5),
                              ),
                              border: OutlineInputBorder())),
                      const SizedBox(height: 10),
                      TextField(
                          style: TextStyle(fontSize: 20),
                          controller: _fastingMonths1Controller,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  _fastingMonths1Controller.text = "";
                                },
                              ),
                              label: Text(
                                "عدد الشهور",
                                style: TextStyle(
                                    fontSize: themeChangeProvider.fontSize - 5),
                              ),
                              border: OutlineInputBorder())),
                      const SizedBox(height: 10),
                      FilledButton.icon(
                          onPressed: () async {
                            int fastingDays = int.parse(
                                _fastingDays1Controller.text.isEmpty
                                    ? "0"
                                    : _fastingDays1Controller.text);
                            int fastingMonths = int.parse(
                                _fastingMonths1Controller.text.isEmpty
                                    ? "0"
                                    : _fastingMonths1Controller.text);

                            int numberOfFastingDays =
                                fastingDays + (fastingMonths * 30);
                            settings.putAll({
                              'fastingDays': _fastingDays1Controller.text,
                              'fastingMonths': _fastingMonths1Controller.text,
                            });
                            if (numberOfFastingDays > 0) {
                              await Hive.box<Prayer>(boxName2).put('قضاء',
                                  Prayer("قضاء", numberOfFastingDays, 0));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(40),
                          ),
                          icon: const Icon(Icons.calculate),
                          label: Text("حساب صيام (القضاء)",
                              style: TextStyle(
                                  fontSize: themeChangeProvider.fontSize - 8))),
                    ],
                  ),
                  ExpansionTile(
                    title: Text("صيام النذر",
                        style: TextStyle(
                            fontSize: themeChangeProvider.fontSize + 5)),
                    children: [
                      const SizedBox(height: 15),
                      TextField(
                          style: TextStyle(fontSize: 20),
                          controller: _fastingDays2Controller,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  _fastingDays2Controller.text = "";
                                },
                              ),
                              label: Text(
                                "عدد الأيام",
                                style: TextStyle(
                                    fontSize: themeChangeProvider.fontSize - 5),
                              ),
                              border: OutlineInputBorder())),
                      const SizedBox(height: 10),
                      TextField(
                          style: TextStyle(fontSize: 20),
                          controller: _fastingMonths2Controller,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  _fastingMonths2Controller.text = "";
                                },
                              ),
                              label: Text(
                                "عدد الشهور",
                                style: TextStyle(
                                    fontSize: themeChangeProvider.fontSize - 5),
                              ),
                              border: OutlineInputBorder())),
                      const SizedBox(height: 10),
                      FilledButton.icon(
                          onPressed: () async {
                            int fastingDays2 = int.parse(
                                _fastingDays2Controller.text.isEmpty
                                    ? "0"
                                    : _fastingDays2Controller.text);
                            int fastingMonths2 = int.parse(
                                _fastingMonths2Controller.text.isEmpty
                                    ? "0"
                                    : _fastingMonths2Controller.text);

                            int numberOfFastingDays2 =
                                fastingDays2 + (fastingMonths2 * 30);
                            settings.putAll({
                              'fastingDays2': _fastingDays2Controller.text,
                              'fastingMonths2': _fastingMonths2Controller.text,
                            });
                            if (numberOfFastingDays2 > 0) {
                              await Hive.box<Prayer>(boxName2).put('نذر',
                                  Prayer("نذر", numberOfFastingDays2, 0));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(40),
                          ),
                          icon: const Icon(Icons.calculate),
                          label: Text("حساب صيام (النذر)",
                              style: TextStyle(
                                  fontSize: themeChangeProvider.fontSize - 8))),
                    ],
                  ),
                  ExpansionTile(
                    title: Text("صيام الكفارة",
                        style: TextStyle(
                            fontSize: themeChangeProvider.fontSize + 5)),
                    children: [
                      const SizedBox(height: 15),
                      TextField(
                          style: TextStyle(fontSize: 20),
                          controller: _fastingDays3Controller,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  _fastingDays3Controller.text = "";
                                },
                              ),
                              label: Text(
                                "عدد الأيام",
                                style: TextStyle(
                                    fontSize: themeChangeProvider.fontSize - 5),
                              ),
                              border: OutlineInputBorder())),
                      const SizedBox(height: 10),
                      TextField(
                          style: TextStyle(fontSize: 20),
                          controller: _fastingMonths3Controller,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              suffixIcon: IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  _fastingMonths3Controller.text = "";
                                },
                              ),
                              label: Text(
                                "عدد الشهور",
                                style: TextStyle(
                                    fontSize: themeChangeProvider.fontSize - 5),
                              ),
                              border: OutlineInputBorder())),
                      const SizedBox(height: 10),
                      FilledButton.icon(
                          onPressed: () async {
                            int fastingDays3 = int.parse(
                                _fastingDays3Controller.text.isEmpty
                                    ? "0"
                                    : _fastingDays3Controller.text);
                            int fastingMonths3 = int.parse(
                                _fastingMonths3Controller.text.isEmpty
                                    ? "0"
                                    : _fastingMonths3Controller.text);

                            int numberOfFastingDays3 =
                                fastingDays3 + (fastingMonths3 * 30);
                            settings.putAll({
                              'fastingDays3': _fastingDays3Controller.text,
                              'fastingMonths3': _fastingMonths3Controller.text,
                            });
                            if (numberOfFastingDays3 > 0) {
                              await Hive.box<Prayer>(boxName2).put('كفارة',
                                  Prayer("كفارة", numberOfFastingDays3, 0));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(40),
                          ),
                          icon: const Icon(Icons.calculate),
                          label: Text("حساب صيام (الكفارة)",
                              style: TextStyle(
                                  fontSize: themeChangeProvider.fontSize - 8))),
                    ],
                  ),
                  const SizedBox(height: 20)
                ]);
          },
        ),
      ),
    );
  }
}
