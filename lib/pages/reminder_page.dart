import 'package:flutter/material.dart';
import 'package:manage_calendar_events/manage_calendar_events.dart';

class ReminderPage extends StatefulWidget {
  final String email;
  ReminderPage({this.email});
  @override
  _ReminderPageState createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  final CalendarPlugin calendarPlugin = CalendarPlugin();

  createReminder() {
    CalendarEvent event;
    event.title = "Hello World";
    event.description = "Sample reminder";
    event.location = "Mangalore";
//    event.reminder = "true";
    calendarPlugin.createEvent(calendarId: widget.email, event: event);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: FlatButton(
            onPressed: () {
              createReminder();
            },
            child: Text(
              'Reminder Page',
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0),
            ),
          ),
        ),
      ),
    );
  }
}
