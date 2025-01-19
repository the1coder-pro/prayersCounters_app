// ignore: must_be_immutable
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive/hive.dart';
import 'package:prayers_counters_app/main.dart';
import 'package:prayers_counters_app/prayers_model.dart';
import 'package:prayers_counters_app/preferences.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    controller = AnimationController(vsync: this);
    reloadController = AnimationController(vsync: this);
    super.initState();
  }

  int fontSize = 20;

  @override
  Widget build(BuildContext context) {
    final themeChangeProvider = Provider.of<TheThemeProvider>(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(widget.prayer.name, style: TextStyle(fontSize: 40)),
          centerTitle: true,
          // add buttons to increase and decrease the font
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {
                    themeChangeProvider.fontSize -= 1;
                  });
                },
                icon: const Icon(Icons.text_decrease_outlined)),
            IconButton(
                onPressed: () {
                  themeChangeProvider.fontSize += 1;
                },
                icon: const Icon(Icons.text_increase_outlined)),
            // menu
            PopupMenuButton(
              itemBuilder: (context) => [
                PopupMenuItem(
                    child: ListTile(
                        leading: Icon(Icons.delete_outline),
                        title: Text('حذف', style: TextStyle(fontSize: 20))),
                    value: 1),
                PopupMenuItem(
                    child: ListTile(
                        leading: Icon(Icons.edit_outlined),
                        title: Text('تعديل', style: TextStyle(fontSize: 20))),
                    value: 2),
              ],
              onSelected: (value) {
                // dont use the links

                if (value == 1) {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return Directionality(
                          textDirection: TextDirection.rtl,
                          child: AlertDialog(
                            title: Text('حذف العداد',
                                style: TextStyle(fontSize: 30)),
                            content: Text('هل تريد حذف هذا العداد؟',
                                style: TextStyle(fontSize: 20)),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('لا',
                                      style: TextStyle(fontSize: 20))),
                              OutlinedButton(
                                  onPressed: () async {
                                    await Hive.box<Prayer>(boxName)
                                        .delete(widget.prayer.name);
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: Text('نعم',
                                      style: TextStyle(fontSize: 20))),
                            ],
                          ),
                        );
                      });
                } else if (value == 2) {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return Directionality(
                          textDirection: TextDirection.rtl,
                          child: AlertDialog(
                            title: Text('تعديل العداد',
                                style: TextStyle(fontSize: 30)),
                            content: TextField(
                              style: TextStyle(fontSize: 20),
                              controller: TextEditingController()
                                ..text = widget.prayer.content,
                              onChanged: (value) {
                                widget.prayer.content = value;
                              },
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('إلغاء',
                                      style: TextStyle(fontSize: 20))),
                              OutlinedButton(
                                  onPressed: () async {
                                    await Hive.box<Prayer>(boxName)
                                        .put(widget.prayer.name, widget.prayer);
                                    Navigator.pop(context);
                                    setState(() {});
                                  },
                                  child: Text('حفظ',
                                      style: TextStyle(fontSize: 20))),
                            ],
                          ),
                        );
                      });
                }
              },
            )
          ],
        ),
        body: Center(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card.outlined(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      elevation: 0.5,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            Text(widget.prayer.content,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: "Scheherazade",
                                    fontSize: themeChangeProvider.fontSize - 7))
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 40, top: 10, right: 40),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          child: FloatingActionButton.small(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryFixedDim,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimaryFixed,
                            heroTag: 'reloadFAB',
                            elevation: 0.4,
                            onPressed: () async {
                              widget.prayer.finished = 0;
                              await Hive.box<Prayer>(boxName).put(
                                  widget.prayer.name,
                                  Prayer(
                                    widget.prayer.name,
                                    widget.prayer.total,
                                    widget.prayer.finished,
                                    widget.prayer.content,
                                  ));
                              setState(() {});
                              reloadController!.forward(from: 0);
                            },
                            child: Animate(
                                controller: reloadController,
                                effects: [
                                  RotateEffect(
                                    duration: 200.milliseconds,
                                  )
                                ],
                                child: Icon(Icons.replay_outlined)),
                          ),
                        ),
                        Container(
                          height: 60,
                          width: 60,
                          child: FloatingActionButton.small(
                            heroTag: 'completedFAB',
                            elevation: 0.4,
                            onPressed: null,
                            child: Text(
                              widget.prayer.numberOfCompletedPrayers.toString(),
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        )
                      ]),
                ),
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 40, right: 40, top: 20, bottom: 20),
                      child: Container(
                        height: 300,
                        width: 300,
                        child: FloatingActionButton.large(
                          elevation: 0.4,
                          heroTag: 'IncreaseFAB',
                          onPressed: () async {
                            if (widget.prayer.finished != widget.prayer.total) {
                              widget.prayer.finished += 1;
                              await Hive.box<Prayer>(boxName)
                                  .put(
                                      widget.prayer.name,
                                      Prayer(
                                          widget.prayer.name,
                                          widget.prayer.total,
                                          widget.prayer.finished,
                                          widget.prayer.content,
                                          numberOfCompletedPrayers: widget
                                              .prayer.numberOfCompletedPrayers))
                                  .then((value) => setState(() {}));
                            } else {
                              widget.prayer.finished = 0;
                              widget.prayer.numberOfCompletedPrayers++;
                              await Hive.box<Prayer>(boxName).put(
                                  widget.prayer.name,
                                  Prayer(
                                      widget.prayer.name,
                                      10,
                                      widget.prayer.finished,
                                      widget.prayer.content,
                                      numberOfCompletedPrayers: widget
                                          .prayer.numberOfCompletedPrayers));
                              setState(() {});
                            }
                            controller!.forward(from: 0);
                          },
                          child: Animate(
                            controller: controller,
                            effects: [
                              ScaleEffect(duration: 200.milliseconds),
                              // RotateEffect(duration: 200.milliseconds)
                            ],
                            child: Text(
                              widget.prayer.finished.toString(),
                              style: TextStyle(fontSize: 40),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ]),
        ),
      ),
    );
  }
}
