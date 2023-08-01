import 'package:flutter_app/components/path.dart' show buildPath;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'bottom_bar.dart';
import 'top_bar.dart';
import 'dart:convert';

// Data model for Calendar Events
class CalendarEvent {
  final String eventId;
  final int userId;
  final String fridgeItemId;
  final DateTime date;
  final String title;

  CalendarEvent(
      {required this.eventId,
      required this.userId,
      required this.fridgeItemId,
      required this.date,
      required this.title});

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      eventId: json['_id'],
      userId: json['userId'],
      fridgeItemId: json['fridgeItemId'],
      date: DateTime.parse(json['expirationDate']),
      title: json['eventLabel'],
    );
  }
}

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  StateCalendar createState() => StateCalendar();
}

class StateCalendar extends State<CalendarPage> {
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
    _fetchEvents();
  }

  Future<String> getToken() async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'auth_token');
    return token ?? '';
  }

  Future<void> _showErrorDialog(String errorMessage) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userData = jsonDecode(prefs.getString('user_data') ?? '{}');
    var userId = userData['userId'];

    try {
      var path = await buildPath('api/get_all_events/$userId');
      var url = Uri.parse(path);
      var token = await getToken();
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      var response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        List<CalendarEvent> events = [];

        // Parse the JSON data and create a list of CalendarEvent objects
        List<dynamic> jsonData = jsonDecode(response.body);
        events = jsonData.map((data) => CalendarEvent.fromJson(data)).toList();

        setState(() {
          _events = events;
        });
      } else {
        _showErrorDialog('Failed to fetch fridge item IDs.');
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const topBar(title: 'Calendar'), // Page Title
      body: SfCalendar(
        view: _calendarView,
        timeZone: 'US Eastern Standard Time',
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
    var day = date.toLocal().day;
    final events = _events.where((event) => event.date.day == day).toList();
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
      startTimeZone: "Eastern Standard Time",
      endTimeZone: "Eastern Standard Time",
      startTime: event.date,
      endTime: event.date.add(const Duration(days: 0)),
      subject: event.title,
    );
  }
}
