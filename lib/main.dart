import 'dart:ui';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:prayers_counters_app/color_schemes.g.dart';
import 'package:prayers_counters_app/prayers_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
                title: 'عداد التسبيح',
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

extension ColorToHex on Color {
  String get toHex {
    return "#${value.toRadixString(16).substring(2)}";
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

  Box<Prayer> mainBox = Hive.box(boxName);

  @override
  Widget build(BuildContext context) {
    final themeChangeProvider = Provider.of<TheThemeProvider>(context);
    final colorChangeProvider = Provider.of<ThemeColorProvider>(context);
    isSelected = getIsSelected(colorChangeProvider);

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.background,
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
                                    fontSize: themeChangeProvider.fontSize + 5),
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
          elevation: 0,
          title: mainBox.isNotEmpty
              ? Text("عداد التسبيح",
                  style: TextStyle(
                      fontFamily: "Lateef",
                      fontSize: themeChangeProvider.fontSize + 5))
              : Container()),
      floatingActionButton: mainBox.isNotEmpty
          ? FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {},
            )
          : null,
      body: ValueListenableBuilder<Box<Prayer>>(
          valueListenable: Hive.box<Prayer>(boxName).listenable(),
          builder: (context, Box<Prayer> box, widget) {
            if (box.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: SvgPicture.string(
                        '''
                        <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
    <svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="1080px" height="1080px" style="shape-rendering:geometricPrecision; text-rendering:geometricPrecision; image-rendering:optimizeQuality; fill-rule:evenodd; clip-rule:evenodd" xmlns:xlink="http://www.w3.org/1999/xlink">
    <g><path style="opacity:1" fill="${Theme.of(context).colorScheme.background.toHex}" d="M -0.5,-0.5 C 359.5,-0.5 719.5,-0.5 1079.5,-0.5C 1079.5,359.5 1079.5,719.5 1079.5,1079.5C 719.5,1079.5 359.5,1079.5 -0.5,1079.5C -0.5,719.5 -0.5,359.5 -0.5,-0.5 Z"/></g>
    <g><path style="opacity:1" fill="#0d0e0d" d="M 796.5,168.5 C 796.171,174.206 796.505,179.872 797.5,185.5C 798.107,185.376 798.44,185.043 798.5,184.5C 815.225,173.471 832.558,172.638 850.5,182C 866.755,194.092 872.755,210.092 868.5,230C 874.128,228.911 879.794,227.578 885.5,226C 908.316,223.653 924.483,232.82 934,253.5C 938.055,267.284 936.888,280.618 930.5,293.5C 931.167,293.833 931.833,294.167 932.5,294.5C 962.391,287.69 982.225,298.69 992,327.5C 994.122,342.347 990.622,355.68 981.5,367.5C 1018.44,370.029 1034.61,389.695 1030,426.5C 1026.15,438.718 1018.65,447.884 1007.5,454C 1017.47,455.881 1026.8,459.548 1035.5,465C 1046.98,476.045 1051.48,489.545 1049,505.5C 1047.05,516.247 1041.88,525.08 1033.5,532C 1029.67,534.337 1026.01,536.837 1022.5,539.5C 1050.38,554.635 1057.88,576.968 1045,606.5C 1037.46,617.204 1027.29,624.371 1014.5,628C 1036.73,644.353 1041.9,665.186 1030,690.5C 1025.28,698.781 1018.45,704.614 1009.5,708C 1004.16,709.892 998.828,711.559 993.5,713C 1013.56,732.975 1015.73,754.808 1000,778.5C 987.771,790.8 972.938,795.967 955.5,794C 970.307,814.63 970.141,835.13 955,855.5C 941.502,867.956 925.836,871.623 908,866.5C 907.5,866.833 907,867.167 906.5,867.5C 918.348,892.775 913.348,913.941 891.5,931C 870.811,940.414 851.811,937.914 834.5,923.5C 833.976,954.188 818.476,970.855 788,973.5C 778.3,972.9 769.8,969.4 762.5,963C 758,957.833 753.5,952.667 749,947.5C 742.5,960.667 732.667,970.5 719.5,977C 702.258,981.291 687.091,977.458 674,965.5C 668.514,959.191 665.18,951.858 664,943.5C 663.667,936.167 663.333,928.833 663,921.5C 647.37,931.195 631.204,932.028 614.5,924C 597.783,912.029 591.616,895.862 596,875.5C 597.541,871.044 599.374,866.711 601.5,862.5C 580.58,867.559 563.08,861.892 549,845.5C 539.406,827.518 539.906,809.685 550.5,792C 516.95,794.936 498.283,779.77 494.5,746.5C 494.948,737.154 497.615,728.488 502.5,720.5C 481.627,724.9 464.46,718.9 451,702.5C 448.726,698.286 446.726,693.953 445,689.5C 444.616,679.737 444.45,670.07 444.5,660.5C 422.089,670.353 402.589,666.353 386,648.5C 378.283,636.625 375.45,623.625 377.5,609.5C 372.687,610.493 368.02,611.993 363.5,614C 341.676,618.95 324.176,612.45 311,594.5C 305.43,583.197 303.096,571.197 304,558.5C 290.6,565.618 276.434,567.451 261.5,564C 241.377,555.618 230.71,540.452 229.5,518.5C 230.706,503.13 237.039,490.297 248.5,480C 232.982,477.994 220.149,471.161 210,459.5C 201.586,445.903 200.252,431.57 206,416.5C 213.35,401.721 225.184,392.554 241.5,389C 223.027,374.577 217.193,356.077 224,333.5C 229.474,320.694 238.807,312.027 252,307.5C 253.257,307.15 253.591,306.483 253,305.5C 247.072,299.576 241.906,293.076 237.5,286C 221.5,275.333 205.5,264.667 189.5,254C 160.4,237.184 129.733,223.851 97.5,214C 77.8671,209.055 58.2005,204.389 38.5,200C 37.1057,198.261 36.4391,196.261 36.5,194C 38.0282,188.447 39.6949,182.947 41.5,177.5C 37.756,177.685 34.0894,178.352 30.5,179.5C 28.9707,179.471 27.804,178.804 27,177.5C 27.6626,161.522 28.3293,145.522 29,129.5C 29.5,128.333 30.3333,127.5 31.5,127C 37.1667,126.667 42.8333,126.333 48.5,126C 49.4162,125.626 50.2496,125.126 51,124.5C 49.8292,115.916 49.4958,107.249 50,98.5C 51.1607,96.3352 52.994,95.3352 55.5,95.5C 86.6371,103.238 116.637,114.071 145.5,128C 173.187,143.009 197.354,162.509 218,186.5C 229.442,200.553 240.275,215.053 250.5,230C 252.5,230.667 254.5,230.667 256.5,230C 280.694,217.811 301.694,221.978 319.5,242.5C 334.816,216.712 355.983,210.378 383,223.5C 380.406,186.434 397.572,167.601 434.5,167C 446.102,169.883 455.935,175.717 464,184.5C 463.911,159.582 476.077,144.415 500.5,139C 518.028,137.345 532.195,143.512 543,157.5C 549.788,129.349 567.621,116.849 596.5,120C 611.146,123.476 621.812,131.976 628.5,145.5C 643.182,116.994 665.182,109.494 694.5,123C 704.189,129.843 710.856,139.01 714.5,150.5C 717.985,147.516 721.318,144.349 724.5,141C 741.588,129.087 759.255,128.421 777.5,139C 788.475,145.77 794.808,155.603 796.5,168.5 Z"/></g>
    <g><path style="opacity:1" fill="#3d4432" d="M 61.5,106.5 C 59.8498,112.938 58.8498,119.605 58.5,126.5C 58.5,119.5 58.5,112.5 58.5,105.5C 59.791,105.263 60.791,105.596 61.5,106.5 Z"/></g>
    <g><path style="opacity:1" fill="${Theme.of(context).colorScheme.primaryContainer.toHex}" d="M 61.5,106.5 C 92.6553,114.163 122.322,125.663 150.5,141C 189.574,166.571 220.907,199.404 244.5,239.5C 241.187,245.131 238.687,251.131 237,257.5C 236.667,263.5 236.333,269.5 236,275.5C 180.521,231.857 117.688,204.69 47.5,194C 46.2916,190.35 46.7916,186.85 49,183.5C 50.2618,179.091 49.4285,175.257 46.5,172C 43.1667,170.667 39.8333,169.333 36.5,168C 35.9186,167.107 35.5852,166.107 35.5,165C 37.0468,155.572 37.8801,146.072 38,136.5C 44.2633,136.016 50.43,134.85 56.5,133C 58.0163,131.103 58.683,128.936 58.5,126.5C 58.8498,119.605 59.8498,112.938 61.5,106.5 Z"/></g>
    <g><path style="opacity:1" fill="${Theme.of(context).colorScheme.secondary.toHex}" d="M 664.5,124.5 C 692.38,124.879 706.213,138.879 706,166.5C 699.155,188.31 684.321,197.477 661.5,194C 642.167,186.843 634,173.009 637,152.5C 641.684,138.65 650.851,129.316 664.5,124.5 Z"/></g>
    <g><path style="opacity:1" fill="${Theme.of(context).colorScheme.primary.toHex}" d="M 577.5,128.5 C 608.296,125.798 622.796,139.798 621,170.5C 614.102,190.874 599.935,199.374 578.5,196C 559.384,188.281 551.218,174.114 554,153.5C 558.318,141.687 566.151,133.354 577.5,128.5 Z"/></g>
    <g><path style="opacity:1" fill="#0e0e0d" d="M 73.5,131.5 C 103.327,139.496 130.161,153.163 154,172.5C 154.664,177.496 152.498,179.33 147.5,178C 125.787,161.475 101.787,149.142 75.5,141C 71.0598,138.632 70.3931,135.466 73.5,131.5 Z"/></g>
    <g><path style="opacity:1" fill="${Theme.of(context).colorScheme.primary.toHex}" d="M 745.5,140.5 C 770.862,139.54 785.195,151.54 788.5,176.5C 785.965,198.035 773.965,210.368 752.5,213.5C 727.197,208.573 715.697,193.24 718,167.5C 723.082,154.25 732.249,145.25 745.5,140.5 Z"/></g>
    <g><path style="opacity:1" fill="${Theme.of(context).colorScheme.secondary.toHex}" d="M 498.5,148.5 C 519.512,145.914 533.345,154.58 540,174.5C 541.61,201.22 529.11,214.72 502.5,215C 487.242,212.41 477.742,203.577 474,188.5C 471.369,168.342 479.536,155.008 498.5,148.5 Z"/></g>
    <g><path style="opacity:1" fill="#555555" d="M 796.5,168.5 C 797.167,173.833 797.833,179.167 798.5,184.5C 798.44,185.043 798.107,185.376 797.5,185.5C 796.505,179.872 796.171,174.206 796.5,168.5 Z"/></g>
    <g><path style="opacity:1" fill="#0e0e0c" d="M 64.5,175.5 C 74.2037,176.117 83.8704,177.284 93.5,179C 96.0799,180.481 96.9132,182.648 96,185.5C 94.3523,187.028 92.3523,187.695 90,187.5C 81.1612,186.362 72.4945,184.695 64,182.5C 63.2967,180.071 63.4634,177.738 64.5,175.5 Z"/></g>
    <g><path style="opacity:1" fill="${Theme.of(context).colorScheme.primary.toHex}" d="M 419.5,175.5 C 440.91,173.949 455.077,183.282 462,203.5C 463.969,226.075 454.136,240.575 432.5,247C 408.432,246.775 394.765,234.609 391.5,210.5C 393.467,192.882 402.8,181.215 419.5,175.5 Z"/></g>
    <g><path style="opacity:1" fill="${Theme.of(context).colorScheme.background.toHex}" d="M 628.5,176.5 C 631.471,179.754 633.971,183.42 636,187.5C 654.765,207.21 675.598,209.71 698.5,195C 701.667,191.833 704.833,188.667 708,185.5C 716.68,211.767 734.847,223.267 762.5,220C 769.337,218.247 775.67,215.414 781.5,211.5C 781.781,229.562 789.114,244.062 803.5,255C 810.214,259.294 817.548,261.461 825.5,261.5C 833.772,261.074 841.772,259.408 849.5,256.5C 844.914,278.269 851.58,295.436 869.5,308C 881.86,314.522 894.693,315.688 908,311.5C 908.5,311.833 909,312.167 909.5,312.5C 898.007,337.805 903.007,358.972 924.5,376C 932.999,380.167 941.999,382.167 951.5,382C 938.554,399.839 937.054,418.672 947,438.5C 956.23,451.203 968.73,458.37 984.5,460C 964.81,474.073 958.976,492.573 967,515.5C 972.225,526.391 980.392,534.225 991.5,539C 966.005,551.157 956.505,570.991 963,598.5C 967.388,608.309 973.888,616.309 982.5,622.5C 951.573,633.019 940.739,654.019 950,685.5C 953.344,693.179 958.511,699.346 965.5,704C 933.495,707.664 918.662,725.497 921,757.5C 922.513,765.858 925.68,773.525 930.5,780.5C 906.289,779.508 889.789,790.174 881,812.5C 878.017,825.077 879.517,837.077 885.5,848.5C 884.667,848.833 883.833,849.167 883,849.5C 851.842,842.403 831.842,854.07 823,884.5C 822.667,889.167 822.333,893.833 822,898.5C 808.058,885.311 791.892,881.811 773.5,888C 759.91,894.002 751.076,904.169 747,918.5C 735.164,896.671 716.997,888.504 692.5,894C 687.288,896.189 682.455,899.023 678,902.5C 683.529,880.087 676.695,862.587 657.5,850C 654.911,848.803 652.244,847.803 649.5,847C 640.145,845.509 630.812,845.009 621.5,845.5C 635.266,818.662 629.6,797.162 604.5,781C 601.226,779.798 597.893,778.798 594.5,778C 587.809,777.831 581.142,777.331 574.5,776.5C 587.276,757.848 587.776,738.848 576,719.5C 562.064,704.264 545.064,699.264 525,704.5C 526.568,698.463 528.568,692.463 531,686.5C 534.284,666.577 527.784,650.743 511.5,639C 496.394,631.004 481.061,630.504 465.5,637.5C 470.342,617.014 465.342,599.514 450.5,585C 433.534,573.835 415.867,572.669 397.5,581.5C 399.46,541.626 380.46,522.459 340.5,524C 334.7,525.545 329.033,527.378 323.5,529.5C 325.64,493.465 308.64,473.965 272.5,471C 289.205,458.062 295.038,441.229 290,420.5C 286.374,409.411 279.541,400.911 269.5,395C 297.01,388.805 310.177,371.638 309,343.5C 306.354,331.871 300.854,321.871 292.5,313.5C 307.556,308.444 318.556,298.777 325.5,284.5C 332.947,290.763 341.281,295.596 350.5,299C 384.913,300.255 401.913,283.588 401.5,249C 405.165,249.984 408.832,251.317 412.5,253C 448.831,259.417 468.664,244.251 472,207.5C 490.716,227.021 511.549,229.521 534.5,215C 542.812,207.214 548.145,197.714 550.5,186.5C 568.696,207.89 590.03,211.39 614.5,197C 621.041,191.409 625.707,184.576 628.5,176.5 Z"/></g>
    <g><path style="opacity:1" fill="${Theme.of(context).colorScheme.secondary.toHex}" d="M 819.5,184.5 C 839.977,182.502 853.477,191.169 860,210.5C 862.54,231.274 854.04,245.107 834.5,252C 814.403,254.532 800.57,246.366 793,227.5C 789.57,212.463 794.07,200.296 806.5,191C 810.647,188.26 814.98,186.093 819.5,184.5 Z"/></g>
    <g><path style="opacity:1" fill="#0d0e0c" d="M 141.5,195.5 C 143.857,195.337 146.19,195.503 148.5,196C 163.854,201.843 178.854,208.51 193.5,216C 197.011,221.383 195.677,224.05 189.5,224C 174.634,216.233 159.3,209.566 143.5,204C 140.395,201.746 139.728,198.913 141.5,195.5 Z"/></g>
    <g><path style="opacity:1" fill="${Theme.of(context).colorScheme.secondary.toHex}" d="M 353.5,225.5 C 371.614,224.788 384.114,232.788 391,249.5C 393.723,270.246 385.223,283.746 365.5,290C 346.22,292.274 333.72,284.107 328,265.5C 325.343,245.001 333.843,231.667 353.5,225.5 Z"/></g>
    <g><path style="opacity:1" fill="${Theme.of(context).colorScheme.primary.toHex}" d="M 275.5,231.5 C 296.687,230.675 310.521,240.341 317,260.5C 319.897,284.887 309.397,299.72 285.5,305C 265.266,305.768 251.766,296.602 245,277.5C 241.947,253.247 252.114,237.913 275.5,231.5 Z"/></g>
    <g><path style="opacity:1" fill="${Theme.of(context).colorScheme.primary.toHex}" d="M 883.5,235.5 C 906.304,232.514 921.138,241.847 928,263.5C 927.986,291.847 913.82,305.68 885.5,305C 859.793,295.082 851.96,277.249 862,251.5C 867.632,244.026 874.798,238.692 883.5,235.5 Z"/></g>
    <g><path style="opacity:1" fill="${Theme.of(context).colorScheme.secondary.toHex}" d="M 943.5,301.5 C 971.468,302.3 984.635,316.633 983,344.5C 973.388,371.394 955.555,379.228 929.5,368C 909.722,354.002 906.222,336.836 919,316.5C 925.804,309.026 933.971,304.026 943.5,301.5 Z"/></g>
    <g><path style="opacity:1" fill="${Theme.of(context).colorScheme.secondary.toHex}" d="M 258.5,314.5 C 280.251,313.79 294.418,323.79 301,344.5C 300.505,372.992 286.005,386.159 257.5,384C 236.96,377.764 227.794,363.931 230,342.5C 234.786,328.212 244.286,318.879 258.5,314.5 Z"/></g>
    <g><path style="opacity:1" fill="${Theme.of(context).colorScheme.primary.toHex}" d="M 979.5,376.5 C 1002.71,375.866 1017.21,386.866 1023,409.5C 1023.59,424.813 1017.43,436.646 1004.5,445C 985.844,454.46 969.678,451.294 956,435.5C 942.203,407.106 950.036,387.439 979.5,376.5 Z"/></g>
    <g><path style="opacity:1" fill="${Theme.of(context).colorScheme.primary.toHex}" d="M 239.5,398.5 C 261.589,396.752 276.089,406.419 283,427.5C 284.161,448.67 274.661,462.503 254.5,469C 233.648,470.986 219.481,462.153 212,442.5C 209.302,420.199 218.469,405.532 239.5,398.5 Z"/></g>
    <g><path style="opacity:1" fill="${Theme.of(context).colorScheme.secondary.toHex}" d="M 996.5,463.5 C 1021.89,461.234 1036.89,472.567 1041.5,497.5C 1038.73,518.605 1026.73,530.272 1005.5,532.5C 985.043,529.541 974.043,517.708 972.5,497C 974.145,481.201 982.145,470.035 996.5,463.5 Z"/></g>
    <g><path style="opacity:1" fill="${Theme.of(context).colorScheme.secondary.toHex}" d="M 270.5,480.5 C 292.906,480.109 307.739,490.442 315,511.5C 316.738,534.437 306.572,549.271 284.5,556C 261.717,558.531 246.55,549.031 239,527.5C 237.033,503.423 247.533,487.757 270.5,480.5 Z"/></g>
    <g><path style="opacity:1" fill="${Theme.of(context).colorScheme.primary.toHex}" d="M 342.5,531.5 C 365.964,529.815 381.13,540.148 388,562.5C 388.832,585.337 378.332,600.171 356.5,607C 333.432,607.709 318.932,596.876 313,574.5C 311.835,559.329 317.335,547.163 329.5,538C 333.925,535.787 338.259,533.621 342.5,531.5 Z"/></g>
    <g><path style="opacity:1" fill="${Theme.of(context).colorScheme.primary.toHex}" d="M 997.5,546.5 C 1013.77,544.564 1026.94,549.897 1037,562.5C 1044.2,576.128 1044.2,589.794 1037,603.5C 1031.31,611.843 1023.48,617.01 1013.5,619C 991.174,621.422 976.674,611.922 970,590.5C 967.8,568.54 976.967,553.873 997.5,546.5 Z"/></g>
    <g><path style="opacity:1" fill="${Theme.of(context).colorScheme.secondary.toHex}" d="M 412.5,584.5 C 433.887,581.601 448.721,589.935 457,609.5C 461.289,631.425 453.122,646.591 432.5,655C 410.142,658.971 394.642,650.471 386,629.5C 383.53,607.764 392.364,592.764 412.5,584.5 Z"/></g>
    <g><path style="opacity:1" fill="${Theme.of(context).colorScheme.secondary.toHex}" d="M 982.5,631.5 C 1004.08,629.202 1018.58,638.202 1026,658.5C 1029.2,679.932 1020.7,694.432 1000.5,702C 979.202,705.437 964.369,697.27 956,677.5C 952.199,654.756 961.033,639.423 982.5,631.5 Z"/></g>
    <g><path style="opacity:1" fill="${Theme.of(context).colorScheme.primary.toHex}" d="M 481.5,641.5 C 502.216,640.727 516.049,650.06 523,669.5C 525.118,684.763 519.952,696.93 507.5,706C 486.545,717.303 469.378,713.136 456,693.5C 447.752,675.25 451.585,660.083 467.5,648C 472.137,645.511 476.804,643.344 481.5,641.5 Z"/></g>
    <g><path style="opacity:1" fill="${Theme.of(context).colorScheme.secondary.toHex}" d="M 533.5,710.5 C 555.512,709.341 569.679,719.341 576,740.5C 577.687,761.648 568.52,775.481 548.5,782C 518.545,784.378 503.711,770.545 504,740.5C 508.024,724.644 517.857,714.644 533.5,710.5 Z"/></g>
    <g><path style="opacity:1" fill="${Theme.of(context).colorScheme.primary.toHex}" d="M 958.5,712.5 C 987.816,712.648 1001.98,727.315 1001,756.5C 993.484,778.848 977.984,788.348 954.5,785C 934.664,775.834 926.497,760.334 930,738.5C 934.952,724.709 944.452,716.043 958.5,712.5 Z"/></g>
    <g><path style="opacity:1" fill="${Theme.of(context).colorScheme.primary.toHex}" d="M 578.5,784.5 C 607.048,784.877 620.548,799.21 619,827.5C 609.422,852.372 592.256,859.872 567.5,850C 548.06,836.34 544.56,819.507 557,799.5C 562.829,792.355 569.996,787.355 578.5,784.5 Z"/></g>
    <g><path style="opacity:1" fill="${Theme.of(context).colorScheme.secondary.toHex}" d="M 914.5,790.5 C 939.809,788.811 954.476,800.478 958.5,825.5C 954.755,849.534 940.755,861.034 916.5,860C 896.786,853.629 887.286,840.129 888,819.5C 892.157,805.511 900.991,795.845 914.5,790.5 Z"/></g>
    <g><path style="opacity:1" fill="${Theme.of(context).colorScheme.secondary.toHex}" d="M 629.5,853.5 C 649.92,852.126 663.42,861.126 670,880.5C 672.009,902.654 662.176,916.154 640.5,921C 620.7,922.165 608.533,912.999 604,893.5C 602.248,873.454 610.748,860.12 629.5,853.5 Z"/></g>
    <g><path style="opacity:1" fill="${Theme.of(context).colorScheme.primary.toHex}" d="M 859.5,855.5 C 881.648,853.831 896.148,863.497 903,884.5C 905.338,905.824 896.505,920.324 876.5,928C 852.742,930.87 837.909,920.703 832,897.5C 830.916,876.757 840.083,862.757 859.5,855.5 Z"/></g>
    <g><path style="opacity:1" fill="${Theme.of(context).colorScheme.secondary.toHex}" d="M 781.5,893.5 C 811.871,892.702 826.037,907.369 824,937.5C 816.795,958.193 802.295,966.693 780.5,963C 757.113,952.395 750.279,935.229 760,911.5C 764.966,902.687 772.132,896.687 781.5,893.5 Z"/></g>
    <g><path style="opacity:1" fill="${Theme.of(context).colorScheme.primary.toHex}" d="M 700.5,900.5 C 720.286,899.782 733.452,908.782 740,927.5C 742.057,948.877 732.891,963.044 712.5,970C 691.917,971.447 678.417,962.28 672,942.5C 670.291,920.735 679.791,906.735 700.5,900.5 Z"/></g>
    </svg>
                          ''',
                        height: 300,
                        width: 500,
                      ),
                    ),
                    // const Image(image: AssetImage('images/kaaba_3d.png')),
                    Text(
                      "عداد التسبيح الإلكتروني",
                      style: TextStyle(
                          letterSpacing: 0,
                          fontSize: themeChangeProvider.fontSize + 20,
                          fontFamily: "Lateef"),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    FilledButton(
                        onPressed: () {
                          // showDialog(context: context, builder: builder)
                        },
                        child: Text(
                          "إضافة عداد",
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
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  width: 40,
                                  child: IconButton(
                                      icon: const Icon(
                                          Icons.remove_circle_outline),
                                      onPressed: () {
                                        if (prayer.finished > 0) {
                                          confirmationAlert(
                                              context, prayer, box, i, false);
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
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .secondary),
                                        child: Text(
                                          "قضيت",
                                          style: TextStyle(
                                              fontSize:
                                                  themeChangeProvider.fontSize -
                                                      5,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .background),
                                        ),
                                        onPressed: () async {
                                          if (prayer.finished < prayer.total) {
                                            confirmationAlert(
                                                context, prayer, box, i, true);
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
                            style:
                                TextStyle(fontSize: 30, fontFamily: "Lateef")),
                      ))),
                ],
              );
            }
          }),
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
                                      await fastingBox.clear();
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
                              await Hive.box<Prayer>(boxName2)
                                  .put('قضاء',
                                      Prayer("قضاء", numberOfFastingDays, 0))
                                  .then((value) => ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          content: Text(
                                            "تمت إضافة عداد صيام القضاء بنجاح",
                                            style: TextStyle(fontSize: 20),
                                          ))));
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
                              await Hive.box<Prayer>(boxName2)
                                  .put('نذر',
                                      Prayer("نذر", numberOfFastingDays2, 0))
                                  .then((value) => ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          content: Text(
                                            "تمت إضافة عداد صيام النذر بنجاح",
                                            style: TextStyle(fontSize: 20),
                                          ))));
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
                              await Hive.box<Prayer>(boxName2)
                                  .put('كفارة',
                                      Prayer("كفارة", numberOfFastingDays3, 0))
                                  .then((value) => ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          content: Text(
                                            "تمت إضافة عداد صيام الكفارة بنجاح",
                                            style: TextStyle(fontSize: 20),
                                          ))));
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
