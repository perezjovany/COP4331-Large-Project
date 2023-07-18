import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'bottom_bar.dart';
import 'top_bar.dart';

// Data model for Calendar Events
class CalendarEvent {
  final String title;
  final DateTime date;

  CalendarEvent({required this.title, required this.date});
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State_Calendar createState() => State_Calendar();
}

class State_Calendar extends State<CalendarPage> {
  // Default selected index is set to 1
  final int _currentIndex = 1;

  // Initialize the view to display the full month view.
  final CalendarView _calendarView = CalendarView.month;

  // Holds the selected date on the calendar.
  final DateTime _selectedDate = DateTime.now();

  // A list to hold calendar events.
  List<CalendarEvent> _events = [];

  @override
  void initState() {
    super.initState();

    // PLACEHOLDER events, please delete once connected to backend
    _events = [
      CalendarEvent(title: 'Chicken A expired', date: DateTime(2023, 7, 15)),
      CalendarEvent(title: 'Chicken B expired', date: DateTime(2023, 7, 18)),
      CalendarEvent(title: 'Milk expired', date: DateTime(2023, 7, 21)),
      CalendarEvent(title: 'Yogurt expired', date: DateTime(2023, 7, 21)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const topBar(title: 'Calendar'), // Page Title
      body: SfCalendar(
        view: _calendarView,
        initialSelectedDate: _selectedDate,
        dataSource: EventDataSource(_events),
        onTap: (CalendarTapDetails details) {
          if (details.targetElement == CalendarElement.calendarCell) {
            _showEventDetails(details.date!);
          }
        },
      ),

      bottomNavigationBar: bottomBar(selectedIndex: _currentIndex),
    );
  }

  // Dialog pop-up section
  void _showEventDetails(DateTime date) {
    final events = _events.where((event) => event.date == date).toList();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SizedBox(
            width: 300.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Events on ${date.month}/${date.day}/${date.year}',
                    style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                ),

                ListView.builder(
                  shrinkWrap: true,
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return ListTile(
                      title: Text(event.title),
                    );
                  },
                ),

                const SizedBox(height: 16.0),
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),

                const SizedBox(height: 16.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

class EventDataSource extends CalendarDataSource {
  EventDataSource(List<CalendarEvent> events) {
    appointments = events.map((event) => createAppointment(event)).toList();
  }

  Appointment createAppointment(CalendarEvent event) {
    return Appointment(
      startTime: event.date,
      endTime: event.date.add(const Duration(hours: 1)),
      subject: event.title,
    );
  }
}
