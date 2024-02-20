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

  Prayer(this.name, this.total, this.finished);

  String toString() => "$name - ($total/$finished)";
}
