import 'package:hive/hive.dart';

part 'prayers_model.g.dart';

@HiveType(typeId: 1)
class Prayer {
  @HiveField(0)
  String name;

  @HiveField(1)
  int total;

  @HiveField(2, defaultValue: 0)
  int finished;

  @HiveField(3)
  String content;

  @HiveField(5)
  int numberOfCompletedPrayers = 0;

  Prayer(this.name, this.total, this.finished, this.content,
      {this.numberOfCompletedPrayers = 0});

  String toString() => "$name - ($total/$finished)";
  void increase() => this.finished += 1;
}
