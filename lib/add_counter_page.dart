import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:m3e_core/m3e_core.dart';
import 'package:prayers_counters_app/main.dart';
import 'package:prayers_counters_app/prayers_model.dart';
import 'package:prayers_counters_app/preferences.dart';
import 'package:provider/provider.dart';

class AddCounterPage extends StatefulWidget {
  final Prayer? prayer;
  final bool isEdit;

  const AddCounterPage({
    super.key,
    this.prayer,
    this.isEdit = false,
  });

  @override
  State<AddCounterPage> createState() => _AddCounterPageState();
}

class _AddCounterPageState extends State<AddCounterPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _limitController;
  late TextEditingController _contentController;
  late String _oldName;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _limitController = TextEditingController();
    _contentController = TextEditingController();

    if (widget.isEdit && widget.prayer != null) {
      _titleController.text = widget.prayer!.name;
      _limitController.text = widget.prayer!.total.toString();
      _contentController.text = widget.prayer!.content;
      _oldName = widget.prayer!.name;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _limitController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveCounter() async {
    if (!_formKey.currentState!.validate()) return;

    final box = Hive.box<Prayer>(boxName);
    final String title = _titleController.text.trim();
    final int limit = int.tryParse(_limitController.text.trim()) ?? 100;
    final String content = _contentController.text.trim();

    Prayer savedPrayer;

    if (widget.isEdit) {
      // If we renamed the counter, delete the old entry
      if (_oldName != title) {
        await box.delete(_oldName);
      }
      
      savedPrayer = Prayer(
        title,
        limit,
        widget.prayer!.finished,
        content,
        numberOfCompletedPrayers: widget.prayer!.numberOfCompletedPrayers,
      );
      await box.put(title, savedPrayer);
    } else {
      // Creating a new counter
      savedPrayer = Prayer(title, limit, 0, content, numberOfCompletedPrayers: 0);
      await box.put(title, savedPrayer);
    }

    if (mounted) {
      Navigator.pop(context, savedPrayer);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeChangeProvider = Provider.of<TheThemeProvider>(context);
    final theme = Theme.of(context);

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
            widget.isEdit
                ? (themeChangeProvider.language == 'ar' ? "تعديل العداد" : "Edit Counter")
                : (themeChangeProvider.language == 'ar' ? "اضافة عداد جديد" : "Add New Counter"),
            style: TextStyle(
              fontFamily: "Lateef",
              fontSize: themeChangeProvider.fontSize + 5,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      elevation: 0,
                      color: theme.colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              themeChangeProvider.language == 'ar' ? "معلومات العداد" : "Counter Info",
                              style: TextStyle(
                                fontSize: themeChangeProvider.fontSize * 0.8,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _titleController,
                              style: TextStyle(fontSize: themeChangeProvider.fontSize * 0.7),
                              decoration: InputDecoration(
                                labelText: themeChangeProvider.language == 'ar'
                                    ? "العنوان (مثال: سبحان الله)"
                                    : "Title (e.g. Subhan Allah)",
                                labelStyle: TextStyle(fontSize: themeChangeProvider.fontSize * 0.65),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.title_outlined),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return themeChangeProvider.language == 'ar'
                                      ? "يرجى إدخال العنوان"
                                      : "Please enter a title";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _limitController,
                              style: TextStyle(fontSize: themeChangeProvider.fontSize * 0.7),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: InputDecoration(
                                labelText: themeChangeProvider.language == 'ar'
                                    ? "العدد المستهدف (الحد الأقصى)"
                                    : "Target Limit",
                                labelStyle: TextStyle(fontSize: themeChangeProvider.fontSize * 0.65),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.radar_outlined),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return themeChangeProvider.language == 'ar'
                                      ? "يرجى إدخال العدد المستهدف"
                                      : "Please enter a target limit";
                                }
                                final parsed = int.tryParse(value);
                                if (parsed == null || parsed <= 0) {
                                  return themeChangeProvider.language == 'ar'
                                      ? "يرجى إدخال عدد صحيح أكبر من صفر"
                                      : "Please enter a valid number greater than zero";
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 0,
                      color: theme.colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              themeChangeProvider.language == 'ar'
                                  ? "نص الذكر / الصلاة"
                                  : "Dhikr / Prayer Text",
                              style: TextStyle(
                                  fontSize: themeChangeProvider.fontSize * 0.8,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _contentController,
                              style: TextStyle(
                                  fontSize: themeChangeProvider.fontSize * 0.8,
                                  fontFamily: "Scheherazade"),
                              maxLines: 6,
                              decoration: InputDecoration(
                                labelText: themeChangeProvider.language == 'ar'
                                    ? "اكتب الذكر هنا..."
                                    : "Write the dhikr here...",
                                alignLabelWithHint: true,
                                labelStyle: TextStyle(fontSize: themeChangeProvider.fontSize * 0.65),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return themeChangeProvider.language == 'ar'
                                      ? "يرجى إدخال نص الذكر"
                                      : "Please enter the dhikr text";
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    M3EFilledButton(
                      onPressed: _saveCounter,
                      decoration: M3EButtonDecoration(
                        minimumSize: const Size.fromHeight(55),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(widget.isEdit ? Icons.save_outlined : Icons.add_outlined),
                            const SizedBox(width: 8),
                            Text(
                              widget.isEdit
                                  ? (themeChangeProvider.language == 'ar'
                                      ? "حفظ التعديلات"
                                      : "Save Changes")
                                  : (themeChangeProvider.language == 'ar'
                                      ? "إضافة العداد"
                                      : "Add Counter"),
                              style: TextStyle(
                                fontSize: themeChangeProvider.fontSize * 0.7,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
