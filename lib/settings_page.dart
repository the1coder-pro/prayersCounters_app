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
            backgroundColor: Theme.of(context).colorScheme.surface,
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.close)),
            centerTitle: true,
            title: Text(
              "الإعدادات",
              style: TextStyle(fontSize: 40),
            )),
        body: Column(children: [
          SwitchListTile(
              title: Text("الوضع الداكن", style: TextStyle(fontSize: 25)),
              value: themeChangeProvider.darkTheme,
              onChanged: (bool value) {
                themeChangeProvider.darkTheme = value;
              }),
          const SizedBox(height: 10),

          ExpansionTile(
            title: Text("الألوان", style: TextStyle(fontSize: 25)),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: ToggleButtons(
                    selectedBorderColor: Theme.of(context).colorScheme.primary,
                    borderWidth: 2,
                    isSelected: isSelected,
                    onPressed: (int index) {
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
                    children: <Widget>[
                      themeButton(
                          themeChange: themeChangeProvider,
                          lightColorScheme: purpleLightColorScheme,
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
              ),
              const SizedBox(height: 10),
            ],
          ),
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
