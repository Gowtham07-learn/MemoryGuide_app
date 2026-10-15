import 'dart:ui';
import 'package:flutter/material.dart';

import 'core/services/caregiver_service_locator.dart';
import 'core/theme/liquid_glass.dart';
import 'features/authentication/caregiver_login_screen.dart';
import 'features/safety/caregiver_safety_view.dart';
import 'medications_screen.dart';

const _forest = Color(0xFF174D43);
const _forestLight = Color(0xFF286B5D);
const _mint = Color(0xFFE7F3EC);
const _ink = Color(0xFF1D2C27);
const _muted = Color(0xFF78847E);
const _line = Color(0xFFE9EDE8);
const _demoMedicationName = 'Donepezil';
const _demoMedicationDosage = '5 mg · 1 tablet';
const _demoMedicationTime = '9:00 AM';

class CaregiverDashboard extends StatefulWidget {
  const CaregiverDashboard({super.key});

  @override
  State<CaregiverDashboard> createState() => _CaregiverDashboardState();
}

class _CaregiverDashboardState extends State<CaregiverDashboard> {
  int _selectedTab = 0;
  late final List<_DemoAppointment> _appointments = [
    _DemoAppointment(
      title: 'Doctor’s visit',
      description: 'Dr. Patel',
      dateTime: _nextFridayAt(10, 30),
      isCompleted: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassAtmosphere(
        isDark: false,
        child: SafeArea(
          child: IndexedStack(
            index: _selectedTab,
            children: [
              _DashboardHome(
                onOpenMedications: () => _selectTab(2),
                onOpenSchedule: () => _selectTab(1),
                onOpenProfile: () => _selectTab(3),
                appointment: _nextAppointment,
              ),
              _SchedulePage(
                appointments: _appointments,
                onChanged: () => setState(() {}),
              ),
              const MedicationsScreen(),
              const _ProfilePage(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.88),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.9),
                  width: 1.2,
                ),
              ),
            ),
            child: NavigationBar(
              selectedIndex: _selectedTab,
              onDestinationSelected: _selectTab,
              backgroundColor: Colors.transparent,
              indicatorColor: _mint,
              elevation: 0,
              height: 72,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.grid_view_rounded),
                  selectedIcon: Icon(Icons.grid_view_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month_rounded),
                  label: 'Schedule',
                ),
                NavigationDestination(
                  icon: Icon(Icons.medication_outlined),
                  selectedIcon: Icon(Icons.medication_rounded),
                  label: 'Medicine',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectTab(int index) {
    setState(() => _selectedTab = index);
  }

  _DemoAppointment? get _nextAppointment {
    final appointments =
        _appointments
            .where(
              (appointment) =>
                  !appointment.isCompleted &&
                  appointment.dateTime.isAfter(DateTime.now()),
            )
            .toList()
          ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return appointments.isEmpty ? null : appointments.first;
  }
}

DateTime _nextFridayAt(int hour, int minute) {
  final today = DateTime.now();
  final daysUntilFriday = (DateTime.friday - today.weekday) % 7;
  final daysToAdd = daysUntilFriday == 0 ? 7 : daysUntilFriday;
  final friday = DateTime(today.year, today.month, today.day + daysToAdd);
  return DateTime(friday.year, friday.month, friday.day, hour, minute);
}

DateTime _nextAvailableHour() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day, now.hour + 1);
}

String _weekdayName(int weekday) => const [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
][weekday - 1];

String _monthName(int month) => const [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
][month - 1];

String _formatTime(DateTime dateTime) {
  final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final period = dateTime.hour < 12 ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

String _formatLongDate(DateTime dateTime) =>
    '${_weekdayName(dateTime.weekday)}, ${_monthName(dateTime.month)} ${dateTime.day}';

class _DemoAppointment {
  _DemoAppointment({
    required this.title,
    required this.description,
    required this.dateTime,
    required this.isCompleted,
  });

  String title;
  String description;
  DateTime dateTime;
  bool isCompleted;
}

class _DashboardHome extends StatefulWidget {
  const _DashboardHome({
    required this.onOpenMedications,
    required this.onOpenSchedule,
    required this.onOpenProfile,
    required this.appointment,
  });

  final VoidCallback onOpenMedications;
  final VoidCallback onOpenSchedule;
  final VoidCallback onOpenProfile;
  final _DemoAppointment? appointment;

  @override
  State<_DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<_DashboardHome> {
  late final DateTime _monday;
  late int _selectedDay;
  final Map<int, Set<int>> _completedTasksByDay = {};
  bool _morningDoseTaken = false;

  static const _tasks = [
    _CareTask(
      title: 'Morning walk',
      detail: 'A little fresh air in the garden',
      time: '9:00 AM',
      icon: Icons.directions_walk_rounded,
      color: Color(0xFF4C9078),
      tint: Color(0xFFE9F4EE),
    ),
    _CareTask(
      title: 'Breakfast',
      detail: 'Oatmeal, berries & green tea',
      time: '9:30 AM',
      icon: Icons.restaurant_rounded,
      color: Color(0xFFC28545),
      tint: Color(0xFFFAF0E4),
    ),
    _CareTask(
      title: 'Memory moments',
      detail: 'Look through the family album',
      time: '11:00 AM',
      icon: Icons.photo_library_rounded,
      color: Color(0xFF7D76B1),
      tint: Color(0xFFF0EEFA),
    ),
  ];

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _monday = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(Duration(days: today.weekday - 1));
    _selectedDay = today.weekday - 1;
    _completedTasksByDay[_selectedDay] = {0};
  }

  @override
  Widget build(BuildContext context) {
    final completedTasks = _completedTasksByDay[_selectedDay] ?? const <int>{};
    final completed = completedTasks.length;
    final progress = completed / _tasks.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 850;
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: wide ? 36 : 20,
            vertical: 18,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TopBar(
                    onOpenSchedule: widget.onOpenSchedule,
                    onOpenProfile: widget.onOpenProfile,
                    appointment: widget.appointment,
                    morningDoseTaken: _morningDoseTaken,
                  ),
                  const SizedBox(height: 28),
                  const _Greeting(),
                  const SizedBox(height: 22),
                  _PatientCard(progress: progress, completed: completed),
                  const SizedBox(height: 24),
                  const CaregiverSafetySection(),
                  const SizedBox(height: 30),
                  _SectionHeading(
                    title: 'Your week',
                    subtitle: 'A little structure, a lot of peace of mind.',
                  ),
                  const SizedBox(height: 16),
                  _WeekPicker(
                    monday: _monday,
                    selectedDay: _selectedDay,
                    onSelect: (day) => setState(() => _selectedDay = day),
                  ),
                  const SizedBox(height: 30),
                  if (wide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: _buildTasksColumn(completed, completedTasks),
                        ),
                        const SizedBox(width: 22),
                        Expanded(flex: 4, child: _buildCareColumn()),
                      ],
                    )
                  else ...[
                    _buildCareColumn(),
                    const SizedBox(height: 28),
                    _buildTasksColumn(completed, completedTasks),
                  ],
                  const SizedBox(height: 30),
                  const _FooterNote(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTasksColumn(int completed, Set<int> completedTasks) {
    final date = _monday.add(Duration(days: _selectedDay));
    final today = DateTime.now();
    final isToday =
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
    const weekdayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          title: isToday
              ? 'Today’s rhythm'
              : '${weekdayNames[_selectedDay]}’s plan',
          subtitle: isToday
              ? '$completed of ${_tasks.length} moments completed'
              : '${monthNames[date.month - 1]} ${date.day} · $completed of ${_tasks.length} complete',
          trailing: _TextAction(
            label: 'View schedule',
            onTap: widget.onOpenSchedule,
          ),
        ),
        const SizedBox(height: 16),
        _TasksCard(
          tasks: _tasks,
          completedTasks: completedTasks,
          onToggle: (index) {
            setState(() {
              final tasks = _completedTasksByDay.putIfAbsent(
                _selectedDay,
                () => <int>{},
              );
              if (!tasks.add(index)) {
                tasks.remove(index);
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildCareColumn() {
    return Column(
      children: [
        _MedicationCard(
          isTaken: _morningDoseTaken,
          onMarkTaken: () {
            setState(() => _morningDoseTaken = !_morningDoseTaken);
            _showMessage(
              _morningDoseTaken
                  ? 'Morning medication marked as taken.'
                  : 'Medication marked as not taken.',
            );
          },
          onOpenMedications: widget.onOpenMedications,
        ),
        const SizedBox(height: 16),
        _AppointmentCard(
          appointment: widget.appointment,
          onOpenSchedule: widget.onOpenSchedule,
        ),
        const SizedBox(height: 16),
        const _CareTipCard(),
      ],
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.onOpenSchedule,
    required this.onOpenProfile,
    required this.appointment,
    required this.morningDoseTaken,
  });

  final VoidCallback onOpenSchedule;
  final VoidCallback onOpenProfile;
  final _DemoAppointment? appointment;
  final bool morningDoseTaken;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _forest,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(Icons.spa_rounded, size: 25, color: Colors.white),
        ),
        const SizedBox(width: 11),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MemoryGuide',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              Text(
                'CAREGIVER SPACE',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _muted,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.25,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'View care reminders',
          onPressed: () {
            final appointmentReminder = appointment == null
                ? 'No upcoming appointments.'
                : 'Next appointment: ${appointment!.title} on '
                      '${_formatLongDate(appointment!.dateTime)} at '
                      '${_formatTime(appointment!.dateTime)}.'
                      '${appointment!.description.isEmpty ? '' : '\n${appointment!.description}'}';
            showDialog<void>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                icon: const Icon(Icons.notifications_active_outlined),
                title: const Text('Care reminders'),
                content: Text(
                  'Morning medication: $_demoMedicationName '
                  '($_demoMedicationDosage) at $_demoMedicationTime'
                  '${morningDoseTaken ? ' · marked as taken' : ''}.\n'
                  '$appointmentReminder',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Got it'),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      onOpenSchedule();
                    },
                    child: const Text('Open schedule'),
                  ),
                ],
              ),
            );
          },
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: _forest,
            side: const BorderSide(color: _line),
          ),
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        const SizedBox(width: 8),
        Tooltip(
          message: 'View profile',
          child: InkWell(
            onTap: onOpenProfile,
            customBorder: const CircleBorder(),
            child: const CircleAvatar(
              radius: 21,
              backgroundColor: Color(0xFFE9D8C7),
              child: Text(
                'S',
                style: TextStyle(
                  color: Color(0xFF77553E),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
        ? 'Good afternoon'
        : 'Good evening';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting, Sarah',
          style: const TextStyle(
            color: _ink,
            fontSize: 30,
            height: 1.15,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.1,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'You’re doing a wonderful job. Here’s your care overview.',
          style: TextStyle(color: _muted, fontSize: 14, height: 1.45),
        ),
      ],
    );
  }
}

class _PatientCard extends StatelessWidget {
  const _PatientCard({required this.progress, required this.completed});

  final double progress;
  final int completed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [_forest, Color(0xFF286B5D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.28),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF174D43).withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 400;
          final person = Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0x33FFFFFF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0x55FFFFFF)),
                ),
                child: const Icon(
                  Icons.face_3_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(width: 14),
              const Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CARING FOR',
                      style: TextStyle(
                        color: Color(0xBFFFFFFF),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Elaine Brooks',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Your mom · Doing well today',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Color(0xDFFFFFFF), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          );

          final progressWidget = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 54,
                height: 54,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 5,
                      backgroundColor: const Color(0x44FFFFFF),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                    Center(
                      child: Text(
                        '${(progress * 100).round()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DAILY CARE',
                    style: TextStyle(
                      color: Color(0xBFFFFFFF),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$completed of ${_DashboardHomeState._tasks.length} done',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          );

          return compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    person,
                    const SizedBox(height: 22),
                    progressWidget,
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: person),
                    const SizedBox(width: 12),
                    progressWidget,
                  ],
                );
        },
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: _muted, fontSize: 12),
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class _TextAction extends StatelessWidget {
  const _TextAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: _forest,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _WeekPicker extends StatelessWidget {
  const _WeekPicker({
    required this.monday,
    required this.selectedDay,
    required this.onSelect,
  });

  final DateTime monday;
  final int selectedDay;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    const weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Row(
      children: List.generate(7, (index) {
        final date = monday.add(Duration(days: index));
        final selected = selectedDay == index;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == 6 ? 0 : 8),
            child: InkWell(
              onTap: () => onSelect(index),
              borderRadius: BorderRadius.circular(18),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: selected ? _forest : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: selected ? _forest : _line),
                ),
                child: Column(
                  children: [
                    Text(
                      weekdays[index],
                      style: TextStyle(
                        color: selected ? Colors.white70 : _muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        color: selected ? Colors.white : _ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected
                            ? Colors.white
                            : index == 2 || index == 4
                            ? _forestLight
                            : Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _TasksCard extends StatelessWidget {
  const _TasksCard({
    required this.tasks,
    required this.completedTasks,
    required this.onToggle,
  });

  final List<_CareTask> tasks;
  final Set<int> completedTasks;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: List.generate(tasks.length, (index) {
          final task = tasks[index];
          return Column(
            children: [
              _TaskRow(
                task: task,
                isComplete: completedTasks.contains(index),
                onTap: () => onToggle(index),
              ),
              if (index != tasks.length - 1)
                const Divider(height: 1, indent: 68, endIndent: 18),
            ],
          );
        }),
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.task,
    required this.isComplete,
    required this.onTap,
  });

  final _CareTask task;
  final bool isComplete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: task.tint,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(task.icon, color: task.color, size: 21),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      color: isComplete ? _muted : _ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      decoration: isComplete
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task.detail,
                    style: const TextStyle(color: _muted, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              task.time,
              style: const TextStyle(
                color: _muted,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Checkbox(
              value: isComplete,
              onChanged: (_) => onTap(),
              activeColor: _forest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicationCard extends StatelessWidget {
  const _MedicationCard({
    required this.isTaken,
    required this.onMarkTaken,
    required this.onOpenMedications,
  });

  final bool isTaken;
  final VoidCallback onMarkTaken;
  final VoidCallback onOpenMedications;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Next medication',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    _demoMedicationTime,
                    style: TextStyle(
                      color: Color(0xFF9D692C),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _mint,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.medication_rounded,
                    color: _forest,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _demoMedicationName,
                        style: TextStyle(
                          color: _ink,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _demoMedicationDosage,
                        style: TextStyle(color: _muted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onMarkTaken,
                style: FilledButton.styleFrom(
                  backgroundColor: isTaken ? _mint : _forest,
                  foregroundColor: isTaken ? _forest : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                icon: Icon(
                  isTaken ? Icons.check_circle_rounded : Icons.check_rounded,
                  size: 18,
                ),
                label: Text(isTaken ? 'Taken' : 'Mark as taken'),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: onOpenMedications,
                style: TextButton.styleFrom(
                  foregroundColor: _muted,
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text(
                  'Manage medications',
                  style: TextStyle(fontSize: 11),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({
    required this.appointment,
    required this.onOpenSchedule,
  });

  final _DemoAppointment? appointment;
  final VoidCallback onOpenSchedule;

  @override
  Widget build(BuildContext context) {
    final currentAppointment = appointment;
    if (currentAppointment == null) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.event_available_outlined, color: _forest),
          title: const Text('No upcoming appointments'),
          trailing: const Icon(Icons.chevron_right_rounded, color: _muted),
          onTap: onOpenSchedule,
        ),
      );
    }

    final date = currentAppointment.dateTime;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _showDemoDetailsDialog(
          context,
          title: currentAppointment.title,
          details: [
            '${_weekdayName(date.weekday)}, ${date.day} ${_monthName(date.month)} · ${_formatTime(date)}',
            if (currentAppointment.description.isNotEmpty)
              currentAppointment.description,
            if (currentAppointment.isCompleted) 'Completed',
          ].join('\n'),
          icon: Icons.event_rounded,
        ),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2EEFA),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _weekdayName(date.weekday).substring(0, 3).toUpperCase(),
                      style: TextStyle(
                        color: Color(0xFF776BA8),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        color: Color(0xFF514779),
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentAppointment.title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: currentAppointment.isCompleted ? _muted : _ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        decoration: currentAppointment.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${currentAppointment.description.isEmpty ? '' : '${currentAppointment.description} · '}${_formatTime(date)}',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: _muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: _muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _CareTipCard extends StatelessWidget {
  const _CareTipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5E9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF4E8D7)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.wb_sunny_rounded, color: Color(0xFFC4883F), size: 21),
          SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A gentle reminder',
                  style: TextStyle(
                    color: Color(0xFF745126),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Small familiar routines can make the day feel more comfortable.',
                  style: TextStyle(
                    color: Color(0xFF876E50),
                    fontSize: 11,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterNote extends StatelessWidget {
  const _FooterNote();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: 6),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 7,
          children: [
            Icon(Icons.favorite_rounded, size: 13, color: _forestLight),
            Text(
              'Care for them. Remember to care for you, too.',
              style: TextStyle(color: _muted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _CareTask {
  const _CareTask({
    required this.title,
    required this.detail,
    required this.time,
    required this.icon,
    required this.color,
    required this.tint,
  });

  final String title;
  final String detail;
  final String time;
  final IconData icon;
  final Color color;
  final Color tint;
}

class _SchedulePage extends StatefulWidget {
  const _SchedulePage({required this.appointments, required this.onChanged});

  final List<_DemoAppointment> appointments;
  final VoidCallback onChanged;

  @override
  State<_SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<_SchedulePage> {
  Future<void> _editAppointment({_DemoAppointment? appointment}) async {
    var title = appointment?.title ?? '';
    var description = appointment?.description ?? '';
    final initialDateTime = appointment?.dateTime ?? _nextAvailableHour();
    final formKey = GlobalKey<FormState>();
    var selectedDate = DateTime(
      initialDateTime.year,
      initialDateTime.month,
      initialDateTime.day,
    );
    var selectedTime = TimeOfDay.fromDateTime(initialDateTime);

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            appointment == null ? 'Add appointment' : 'Edit appointment',
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: title,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (value) => title = value?.trim() ?? '',
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter an appointment title.'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: description,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    onSaved: (value) => description = value?.trim() ?? '',
                  ),
                  const SizedBox(height: 12),
                  FormField<DateTime>(
                    initialValue: selectedDate,
                    validator: (value) =>
                        value == null ? 'Choose an appointment date.' : null,
                    builder: (field) => InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Date',
                        errorText: field.errorText,
                        border: const OutlineInputBorder(),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: dialogContext,
                              initialDate: field.value ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              selectedDate = date;
                              field.didChange(date);
                              setDialogState(() {});
                            }
                          },
                          icon: const Icon(Icons.calendar_month_outlined),
                          label: Text(
                            _formatLongDate(field.value ?? selectedDate),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FormField<TimeOfDay>(
                    initialValue: selectedTime,
                    validator: (value) =>
                        value == null ? 'Choose an appointment time.' : null,
                    builder: (field) => InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Time',
                        errorText: field.errorText,
                        border: const OutlineInputBorder(),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: dialogContext,
                              initialTime: field.value ?? selectedTime,
                            );
                            if (time != null) {
                              selectedTime = time;
                              field.didChange(time);
                              setDialogState(() {});
                            }
                          },
                          icon: const Icon(Icons.schedule_rounded),
                          label: Text(
                            (field.value ?? selectedTime).format(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  Navigator.pop(dialogContext, true);
                }
              },
              child: Text(appointment == null ? 'Add' : 'Save changes'),
            ),
          ],
        ),
      ),
    );

    if (saved == true && mounted) {
      final dateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );
      setState(() {
        if (appointment == null) {
          widget.appointments.add(
            _DemoAppointment(
              title: title,
              description: description,
              dateTime: dateTime,
              isCompleted: false,
            ),
          );
        } else {
          appointment
            ..title = title
            ..description = description
            ..dateTime = dateTime;
        }
      });
      widget.onChanged();
    }
  }

  void _toggleCompleted(_DemoAppointment appointment) {
    setState(() {
      appointment.isCompleted = !appointment.isCompleted;
    });
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final appointments = [...widget.appointments]
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return _SimplePage(
      eyebrow: 'YOUR PLAN',
      title: 'Daily schedule',
      description: 'A calm, familiar rhythm for Elaine’s day.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 8,
            children: [
              const Text(
                'Appointments',
                style: TextStyle(
                  color: _ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              FilledButton.icon(
                onPressed: () => _editAppointment(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add appointment'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (appointments.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'No appointments yet. Add one to get started.',
                    style: TextStyle(color: _muted),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          else
            ...appointments.map(
              (appointment) => _AppointmentScheduleLine(
                appointment: appointment,
                onEdit: () => _editAppointment(appointment: appointment),
                onToggleCompleted: () => _toggleCompleted(appointment),
              ),
            ),
          const SizedBox(height: 18),
          const Text(
            'Daily routine',
            style: TextStyle(
              color: _ink,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          const _ScheduleLine(
            time: '9:00 AM',
            title: 'Morning medication',
            detail: 'Donepezil · 5 mg',
            icon: Icons.medication_rounded,
            tint: _mint,
            color: _forest,
          ),
          const _ScheduleLine(
            time: '9:00 AM',
            title: 'Morning walk',
            detail: 'A little fresh air in the garden',
            icon: Icons.directions_walk_rounded,
            tint: Color(0xFFE9F4EE),
            color: Color(0xFF4C9078),
          ),
          const _ScheduleLine(
            time: '9:30 AM',
            title: 'Breakfast',
            detail: 'Oatmeal, berries & green tea',
            icon: Icons.restaurant_rounded,
            tint: Color(0xFFFAF0E4),
            color: Color(0xFFC28545),
          ),
          const _ScheduleLine(
            time: '11:00 AM',
            title: 'Memory moments',
            detail: 'Look through the family album',
            icon: Icons.photo_library_rounded,
            tint: Color(0xFFF0EEFA),
            color: Color(0xFF7D76B1),
          ),
        ],
      ),
    );
  }
}

class _AppointmentScheduleLine extends StatelessWidget {
  const _AppointmentScheduleLine({
    required this.appointment,
    required this.onEdit,
    required this.onToggleCompleted,
  });

  final _DemoAppointment appointment;
  final VoidCallback onEdit;
  final VoidCallback onToggleCompleted;

  @override
  Widget build(BuildContext context) {
    final date = appointment.dateTime;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Row(
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: appointment.isCompleted
                        ? const Color(0xFFF0F1EF)
                        : const Color(0xFFF2EEFA),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    appointment.isCompleted
                        ? Icons.event_available_rounded
                        : Icons.event_rounded,
                    color: appointment.isCompleted ? _muted : _forestLight,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.title,
                        style: TextStyle(
                          color: appointment.isCompleted ? _muted : _ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          decoration: appointment.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatLongDate(date)} · ${_formatTime(date)}'
                        '${appointment.description.isEmpty ? '' : ' · ${appointment.description}'}',
                        style: const TextStyle(color: _muted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: appointment.isCompleted
                      ? 'Mark appointment as not completed'
                      : 'Mark appointment as completed',
                  onPressed: onToggleCompleted,
                  icon: Icon(
                    appointment.isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.check_circle_outline_rounded,
                    color: appointment.isCompleted ? _forest : _muted,
                  ),
                ),
                IconButton(
                  tooltip: 'Edit appointment',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, color: _muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScheduleLine extends StatelessWidget {
  const _ScheduleLine({
    required this.time,
    required this.title,
    required this.detail,
    required this.icon,
    required this.tint,
    required this.color,
  });

  final String time;
  final String title;
  final String detail;
  final IconData icon;
  final Color tint;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => _showDemoDetailsDialog(
            context,
            title: title,
            details: '$time\n$detail',
            icon: icon,
          ),
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Row(
              children: [
                SizedBox(
                  width: 62,
                  child: Text(
                    time,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: tint,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 21),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        detail,
                        style: const TextStyle(color: _muted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: _muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  @override
  Widget build(BuildContext context) {
    final user = CaregiverServiceLocator.instance.authRepository.currentUser;

    return _SimplePage(
      eyebrow: 'YOUR CARE CIRCLE',
      title: 'A little about Elaine',
      description: 'Keep the details that make care feel personal close by.',
      child: Column(
        children: [
          if (user != null) ...[
            _ProfileDetail(
              icon: Icons.badge_outlined,
              title: 'Caregiver Account',
              value: '${user.fullName} (${user.email})',
            ),
            const _ProfileDetail(
              icon: Icons.verified_user_outlined,
              title: 'Account Role',
              value: 'Authorized Caregiver (Active)',
            ),
          ],
          const _ProfileDetail(
            icon: Icons.person_rounded,
            title: 'Patient',
            value: 'Elaine Brooks',
          ),
          const _ProfileDetail(
            icon: Icons.favorite_rounded,
            title: 'Relationship',
            value: 'Mom',
          ),
          const _ProfileDetail(
            icon: Icons.shield_rounded,
            title: 'Care partner',
            value: 'Sarah Brooks',
          ),
          const _ProfileDetail(
            icon: Icons.info_outline_rounded,
            title: 'Care notes',
            value: 'Familiar routines help Elaine feel at ease.',
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                side: const BorderSide(color: Color(0xFFFECACA), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text(
                'Sign Out',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () async {
                await CaregiverServiceLocator.instance.authRepository.logout();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const CaregiverLoginScreen()),
                  (route) => false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileDetail extends StatelessWidget {
  const _ProfileDetail({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: ListTile(
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _mint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: _forest, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: _muted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            value,
            style: const TextStyle(
              color: _ink,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _SimplePage extends StatelessWidget {
  const _SimplePage({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.child,
  });

  final String eyebrow;
  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 26),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: const TextStyle(
                    color: _forestLight,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  description,
                  style: const TextStyle(color: _muted, fontSize: 13),
                ),
                const SizedBox(height: 24),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _showDemoDetailsDialog(
  BuildContext context, {
  required String title,
  required String details,
  required IconData icon,
}) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: Icon(icon, color: _forest),
      title: Text(title),
      content: Text(details),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}
