import 'package:flutter/material.dart';
import 'package:prayers_counters_app/color_schemes.g.dart';
import 'package:prayers_counters_app/main.dart';
import 'package:prayers_counters_app/preferences.dart';
import 'package:provider/provider.dart';

List<ColorScheme> colorSchemes_light = [
  purpleLightColorScheme,
  baigeLightColorScheme,
  redLightColorScheme,
  blueLightColorScheme,
  greyLightColorScheme,
  greenLightColorScheme,
];

List<ColorScheme> colorSchemes_dark = [
  purpleDarkColorScheme,
  baigeDarkColorScheme,
  redDarkColorScheme,
  blueDarkColorScheme,
  greyDarkColorScheme,
  greenDarkColorScheme,
];

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<bool> isSelected = [false, false, false, false, false, false, false];
  getIsSelected(ThemeColorProvider colorChangeProvider) {
    List<bool> isSelected = [];
    for (int i = 0; i < colorSchemes.length; i++) {
      if (colorChangeProvider.colorTheme == i) {
        isSelected.add(true);
      } else {
        isSelected.add(false);
      }
    }
    return isSelected;
  }

  @override
  Widget build(BuildContext context) {
    final themeChangeProvider = Provider.of<TheThemeProvider>(context);
    final colorChangeProvider = Provider.of<ThemeColorProvider>(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close)),
            centerTitle: true,
            title: Text(
              "المظهر",
              // AppLocalizations.of(context)!.appearance,
              style: TextStyle(fontSize: themeChangeProvider.fontSize + 5),
            )),
        // appBar: AppBar(
        //     backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        //     leading: IconButton(
        //         onPressed: () {
        //           Navigator.pop(context);
        //         },
        //         icon: const Icon(Icons.close)),
        //     centerTitle: true,
        //     title: Text(
        //       "الإعدادات",
        //       style: TextStyle(fontSize: 40),
        //     )),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surface,
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    title: Text("الوضع الداكن",
                        style:
                            TextStyle(fontSize: themeChangeProvider.fontSize)),
                    value: themeChangeProvider.darkTheme,
                    onChanged: (bool value) {
                      themeChangeProvider.darkTheme = value;
                    }),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "السمات",
                        style:
                            TextStyle(fontSize: themeChangeProvider.fontSize),
                      ),
                      const SizedBox(height: 16),
                      Builder(
                        builder: (context) {
                          final buttons =
                              List.generate(colorSchemes.length, (index) {
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
                                    foregroundColor:
                                        themeChangeProvider.darkTheme
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
                                      colorChangeProvider.colorTheme =
                                          buttonIndex;
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
                                        ? Theme.of(context).colorScheme.primary
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
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6),
                                        child: b))
                                    .toList(),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: buttons
                                    .sublist(4, 8)
                                    .map((b) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6),
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
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Text(
          //   "حجم الخط",
          //   style: TextStyle(
          //       fontSize: 25),
          //   textAlign: TextAlign.end,
          // ),
          // Center(
          //   child: Slider(
          //     value: themeChangeProvider.fontSize,
          //     max: 36,
          //     min: 20,
          //     divisions: 7,
          //     label: themeChangeProvider.fontSize
          //         .round()
          //         .toString(),
          //     onChanged: (double value) {
          //       setState(() {
          //         themeChangeProvider.fontSize = value;
          //       });
          //     },
          //   ),
          // ),
        ]),
      ),
    );
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
        child: FloatingActionButton.small(
      heroTag: 'themeFab-${lightColorScheme} - ${darkColorScheme}',
      elevation: 0,
      onPressed: null,
      foregroundColor: themeChange.darkTheme
          ? darkColorScheme.onPrimaryContainer
          : lightColorScheme.onPrimaryContainer,
      backgroundColor: themeChange.darkTheme
          ? darkColorScheme.primaryContainer
          : lightColorScheme.primaryContainer,
      child: const Icon(Icons.add),
    ));
  }
}
