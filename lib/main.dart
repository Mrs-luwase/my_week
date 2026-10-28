import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'quote.dart';

void main() {
  runApp(const MyWeekApp());
}

const Color sage = Color(0xFF6F9A7E);
const Color sageDark = Color(0xFF3F6B52);
const Color pageBg = Color(0xFFE9F0E7);
const List<Color> accents = [
  Color(0xFF8DB59A),
  Color(0xFFB7D3A8),
  Color(0xFFD5E39A),
  Color(0xFF9CC2BE),
];

class MyWeekApp extends StatelessWidget {
  const MyWeekApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Week',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: sage),
        scaffoldBackgroundColor: pageBg,
        appBarTheme: const AppBarTheme(
          backgroundColor: pageBg,
          foregroundColor: sageDark,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
              color: sageDark, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: sageDark,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: sage,
          foregroundColor: Colors.white,
          shape: CircleBorder(),
        ),
      ),
      home: const WeekScreen(),
    );
  }
}

const List<String> days = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday',
];

const List<String> months = [
  'January', 'February', 'March', 'April', 'May', 'June', 'July',
  'August', 'September', 'October', 'November', 'December',
];

// The Monday of the current week, used for the date numbers on the day cards.
DateTime mondayOfThisWeek() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day)
      .subtract(Duration(days: now.weekday - 1));
}

String formatTime(int minutes) {
  final h = (minutes ~/ 60).toString().padLeft(2, '0');
  final m = (minutes % 60).toString().padLeft(2, '0');
  return '$h:$m';
}

String formatDuration(int minutes) {
  final m = (minutes % 60).toString().padLeft(2, '0');
  return '${minutes ~/ 60}h ${m}m';
}

// Turns "08:30" into 510. Returns null if the text is not a valid time.
int? parseTime(String text) {
  final parts = text.trim().split(':');
  if (parts.length != 2) return null;
  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null) return null;
  if (h < 0 || h > 23 || m < 0 || m > 59) return null;
  return h * 60 + m;
}

// Returns EVERY other course that overlaps with [c] (empty list = no clash).
List<Course> findClashes(Course c) {
  return sampleCourses.where((other) {
    return !identical(other, c) &&
        other.day == c.day &&
        c.startMinutes < other.endMinutes &&
        other.startMinutes < c.endMinutes;
  }).toList();
}

class WeekScreen extends StatefulWidget {
  const WeekScreen({super.key});

  @override
  State<WeekScreen> createState() => _WeekScreenState();
}

class _WeekScreenState extends State<WeekScreen> {
  String selectedDay = 'Monday';

  @override
  void initState() {
    super.initState();
    start();
  }

  Future<void> start() async {
    await loadCourses();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> addCourse() async {
    final newCourse = await Navigator.push<Course>(
      context,
      MaterialPageRoute(builder: (_) => const AddCourseScreen()),
    );
    if (newCourse != null) {
      setState(() {
        sampleCourses.add(newCourse);
        selectedDay = newCourse.day;
      });
      saveCourses();
    }


  }

  Future<void> editCourse(Course c) async {
    final updated = await Navigator.push<Course>(
      context,
      MaterialPageRoute(builder: (_) => AddCourseScreen(existing: c)),
    );
    if (updated != null) {
      setState(() {
        sampleCourses[sampleCourses.indexOf(c)] = updated;
        selectedDay = updated.day;
      });
      saveCourses();
    }
  }

  Future<void> deleteCourse(Course c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Are you sure?'),
        content: Text('Delete ${c.name} from your week?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true) return;

    final index = sampleCourses.indexOf(c);
    setState(() => sampleCourses.remove(c));
    saveCourses();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${c.name} deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() => sampleCourses.insert(index, c));
            saveCourses();
          },
        ),
      ),
    );
  }

  Widget dayCard(int i, DateTime weekStart) {
    final d = days[i];
    final selected = d == selectedDay;
    final date = weekStart.add(Duration(days: i));
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedDay = d),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? sageDark : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 3)),
            ],
          ),
          child: Column(
            children: [
              Text(d.substring(0, 3),
                  style: TextStyle(
                      fontSize: 12,
                      color: selected ? Colors.white70 : Colors.black54)),
              const SizedBox(height: 4),
              Text('${date.day}',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: selected ? Colors.white : sageDark)),
            ],
          ),
        ),
      ),
    );
  }

  Widget courseRow(Course c, int i) {
    final clashes = findClashes(c);
    final hasClash = clashes.isNotEmpty;
    final accent = hasClash ? Colors.red.shade400 : accents[i % accents.length];
    final roomText = c.room.isEmpty ? '' : ' · ${c.room}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 56,
            child: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Text(formatTime(c.startMinutes),
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: sageDark)),
            ),
          ),
          Expanded(
            child: Material(
              color: hasClash ? Colors.red.shade50 : Colors.white,
              borderRadius: BorderRadius.circular(14),
              clipBehavior: Clip.antiAlias,
              elevation: 1,
              child: InkWell(
                onTap: () => editCourse(c),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(width: 6, color: accent),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.name,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: hasClash
                                          ? Colors.red.shade800
                                          : Colors.black87)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.access_time,
                                      size: 14, color: Colors.black45),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                        '${formatTime(c.startMinutes)} - ${formatTime(c.endMinutes)}$roomText',
                                        style: const TextStyle(
                                            fontSize: 12.5,
                                            color: Colors.black54)),
                                  ),
                                ],
                              ),
                              if (hasClash)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                      'Clashes with ${clashes.map((x) => x.name).join(', ')}',
                                      style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red.shade800)),
                                ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => deleteCourse(c),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todaysCourses =
    sampleCourses.where((c) => c.day == selectedDay).toList();
    todaysCourses.sort((a, b) => a.startMinutes.compareTo(b.startMinutes));

    final dayMinutes = todaysCourses.fold<int>(
        0, (sum, c) => sum + (c.endMinutes - c.startMinutes));
    final weekMinutes = sampleCourses.fold<int>(
        0, (sum, c) => sum + (c.endMinutes - c.startMinutes));
    final weekStart = mondayOfThisWeek();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_month),
            SizedBox(width: 8),
            Text('My Week'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addCourse,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          const QuoteBanner(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(months[weekStart.month - 1].toUpperCase(),
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: sageDark)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                for (var i = 0; i < days.length; i++) dayCard(i, weekStart),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    '${selectedDay.toUpperCase()} · ${formatDuration(dayMinutes)}',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5)),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Week: ${formatDuration(weekMinutes)}',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: sageDark)),
                ),
              ],
            ),
          ),
          Expanded(
            child: todaysCourses.isEmpty
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.event_available,
                      size: 48, color: sage),
                  const SizedBox(height: 8),
                  Text('No classes on $selectedDay'),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
              itemCount: todaysCourses.length,
              itemBuilder: (context, i) =>
                  courseRow(todaysCourses[i], i),
            ),
          ),
        ],
      ),
    );
  }
}

class AddCourseScreen extends StatefulWidget {
  final Course? existing;
  const AddCourseScreen({super.key, this.existing});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  late final TextEditingController nameController;
  late final TextEditingController startController;
  late final TextEditingController endController;
  late final TextEditingController roomController;
  String day = 'Monday';
  String? error;

  @override
  void initState() {
    super.initState();
    final c = widget.existing;
    nameController = TextEditingController(text: c?.name ?? '');
    startController =
        TextEditingController(text: c == null ? '' : formatTime(c.startMinutes));
    endController =
        TextEditingController(text: c == null ? '' : formatTime(c.endMinutes));
    roomController = TextEditingController(text: c?.room ?? '');
    day = c?.day ?? 'Monday';
  }

  @override
  void dispose() {
    nameController.dispose();
    startController.dispose();
    endController.dispose();
    roomController.dispose();
    super.dispose();
  }

  void save() {
    final name = nameController.text.trim();
    final start = parseTime(startController.text);
    final end = parseTime(endController.text);

    if (name.isEmpty) {
      setState(() => error = 'Please enter a course name');
      return;
    }
    if (start == null || end == null) {
      setState(() => error = 'Times must look like 08:30 (00:00 to 23:59)');
      return;
    }
    if (end <= start) {
      setState(() => error = 'End time must be after start time');
      return;
    }

    Navigator.pop(
      context,
      Course(
        name: name,
        day: day,
        startMinutes: start,
        endMinutes: end,
        room: roomController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.existing == null ? 'Add course' : 'Edit course')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Course name'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: day,
            decoration: const InputDecoration(labelText: 'Day'),
            items: days
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            onChanged: (v) => setState(() => day = v!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: startController,
            decoration: const InputDecoration(labelText: 'Start time (HH:MM)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: endController,
            decoration: const InputDecoration(labelText: 'End time (HH:MM)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: roomController,
            decoration: const InputDecoration(labelText: 'Room'),
          ),
          const SizedBox(height: 12),
          if (error != null)
            Text(error!, style: TextStyle(color: Colors.red.shade700)),
          const SizedBox(height: 12),
          FilledButton(onPressed: save, child: const Text('Save')),
        ],
      ),
    );
  }
}
class Course {
  final String name;
  final String day;
  final int startMinutes;
  final int endMinutes;
  final String room;

  const Course({
    required this.name,
    required this.day,
    required this.startMinutes,
    required this.endMinutes,
    required this.room,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'day': day,
      'start': startMinutes,
      'end': endMinutes,
      'room': room,
    };
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      name: json['name'] as String,
      day: json['day'] as String,
      startMinutes: json['start'] as int,
      endMinutes: json['end'] as int,
      room: json['room'] as String,
    );
  }
}

final List<Course> sampleCourses = [
  const Course(name: 'System Analysis and Design', day: 'Monday', startMinutes: 510, endMinutes: 630, room: 'A101'),
  const Course(name: 'Linux', day: 'Monday', startMinutes: 600, endMinutes: 720, room: 'Lab 2'),
  const Course(name: 'Mobile Programming', day: 'Tuesday', startMinutes: 840, endMinutes: 960, room: 'Lab 1'),
];

Future<void> saveCourses() async {
  final prefs = await SharedPreferences.getInstance();
  final list = sampleCourses.map((c) => c.toJson()).toList();
  await prefs.setString('courses', jsonEncode(list));
}

Future<void> loadCourses() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString('courses');
  if (saved != null) {
    final list = jsonDecode(saved) as List;
    sampleCourses
      ..clear()
      ..addAll(list.map((x) => Course.fromJson(x as Map<String, dynamic>)));
  }
}
class QuoteBanner extends StatefulWidget {
  const QuoteBanner({super.key});

  @override
  State<QuoteBanner> createState() => _QuoteBannerState();
}

class _QuoteBannerState extends State<QuoteBanner> {
  Quote? quote;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final result = await fetchQuote();
      if (!mounted) return;
      setState(() {
        quote = result;
        loading = false;
        error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = 'Could not load the quote. Check your internet connection.';
      });
    }
  }

  void retry() {
    setState(() {
      loading = true;
      error = null;
    });
    load();
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (loading) {
      content = const Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          SizedBox(width: 12),
          Text('Loading your quote of the day...'),
        ],
      );
    } else if (error != null) {
      content = Row(
        children: [
          const Icon(Icons.wifi_off, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(child: Text(error!)),
          TextButton(onPressed: retry, child: const Text('Retry')),
        ],
      );
    } else {
      final q = quote!;
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.format_quote, color: sageDark, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  q.text,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 4),
                Text(
                  '- ${q.author}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: sageDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: content,
    );
  }
}