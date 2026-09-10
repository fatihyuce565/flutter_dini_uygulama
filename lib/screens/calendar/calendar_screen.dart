import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../app/providers/app_providers.dart';

class IslamicCalendarScreen extends ConsumerWidget {
  const IslamicCalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final islamicDateAsync = ref.watch(islamicDateProvider);
    final holidaysAsync = ref.watch(islamicHolidaysProvider(1445));
    final moonPhasesAsync = ref.watch(moonPhasesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('İslami Takvim'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bugünün Hicri Tarihi
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bugün',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  islamicDateAsync.when(
                    data: (calendar) {
                      if (calendar == null) {
                        return const Text('Tarih bulunamadı');
                      }
                      return _buildTodayCard(calendar);
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => const Text('Hata oluştu'),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Takvim Widget'ı
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Takvim',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildCalendarWidget(),
                ],
              ),
            ),
            const Divider(),
            // Özel Günler
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'İslami Bayramlar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  holidaysAsync.when(
                    data: (holidays) {
                      if (holidays.isEmpty) {
                        return const Text('Bayram bulunamadı');
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: holidays.length,
                        itemBuilder: (context, index) {
                          final holiday = holidays[index];
                          return _buildHolidayCard(
                            holiday['name'],
                            holiday['hijriDate'],
                          );
                        },
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => const Text('Hata oluştu'),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Ay Fazları
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ay Fazları',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  moonPhasesAsync.when(
                    data: (phases) {
                      if (phases.isEmpty) {
                        return const Text('Ay fazı bulunamadı');
                      }
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.5,
                        ),
                        itemCount: phases.length,
                        itemBuilder: (context, index) {
                          final phase = phases[index];
                          return _buildMoonPhaseCard(
                            phase['phase'],
                            phase['description'],
                          );
                        },
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => const Text('Hata oluştu'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayCard(dynamic calendar) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDateBox('Miladi', '${calendar.gregorianDay}/${calendar.gregorianMonth}/${calendar.gregorianYear}'),
                _buildDateBox('Hicri', calendar.hijriDateString),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              calendar.monthNameTranslation,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (calendar.isRamadan)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Chip(
                  label: Text('🌙 Ramazan Ayı'),
                  backgroundColor: Colors.orange,
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateBox(String label, String date) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          date,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarWidget() {
    return Card(
      child: TableCalendar(
        firstDay: DateTime.utc(2024, 1, 1),
        lastDay: DateTime.utc(2025, 12, 31),
        focusedDay: DateTime.now(),
        calendarFormat: CalendarFormat.month,
        onDaySelected: (selectedDay, focusedDay) {},
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
      ),
    );
  }

  Widget _buildHolidayCard(String name, String date) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.celebration, color: Colors.amber),
        title: Text(name),
        subtitle: Text(date),
        trailing: const Icon(Icons.arrow_forward),
      ),
    );
  }

  Widget _buildMoonPhaseCard(String phase, String description) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🌙',
              style: TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              phase,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
