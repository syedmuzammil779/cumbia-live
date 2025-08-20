import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cumbia_live_company/add_new_event/model/Event.dart';
import 'package:cumbia_live_company/common/utils.dart';
import 'package:cumbia_live_company/homeScreen.dart';
import 'package:cumbia_live_company/theme/FontSizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  Event? _selectedEvent;

  Future<DateTime?> _pickDateTime({DateTime? initialDate}) async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return null;

    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate ?? DateTime.now()),
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }


  String getFormattedEventTitle() {
    final now = DateTime.now();
    final day = now.day;
    final month = DateFormat.MMMM('es_ES').format(now);
    return '$month $day - lanzamiento';
  }

  Future<void> _addNewEvent(BuildContext context) async {

    final pickedDate = await _pickDateTime();
    if (pickedDate == null) return;

    final newEvent = Event(
      id: Uuid().v4(),
      title: 'New Event ${getFormattedEventTitle()}',
      eventDateTime: pickedDate,
    );

    try {
      await FirebaseFirestore.instance.collection('events').add(newEvent.toMap());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event added')),
      );
    } catch (e) {
      debugPrint('Error adding event: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add event: $e')),
      );
    }
  }

  Future<void> _editEventDate(Event event) async {
    final pickedDate = await _pickDateTime(initialDate: event.eventDateTime);
    if (pickedDate == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(event.id)
          .update({'eventDateTime': pickedDate.toIso8601String()});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event updated')),
      );

      setState(() {});
    } catch (e) {
      debugPrint('Error updating event: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update event: $e')),
      );
    }
  }

  Widget _buildEventTile(Event event, FontSizes fontSizes) {
    final isSelected = event.id == _selectedEvent?.id;

    String formattedTitle;
    if (event.eventDateTime != null) {
      final day = event.eventDateTime!.day;
      final month = DateFormat.MMMM('es_ES').format(event.eventDateTime!);
      formattedTitle = '$month $day - lanzamiento';
    } else {
      formattedTitle = event.title; // fallback if no date
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF102d54),
        borderRadius: BorderRadius.circular(10),
        border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formattedTitle,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (event.eventDateTime != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat('yyyy-MM-dd – HH:mm').format(event.eventDateTime!),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: "Start the live stream",
            icon: const Icon(Icons.live_tv, color: Colors.white),
            onPressed: () {
              showToast(context, 'Live stream started');
            },
          ),
          IconButton(
            tooltip: "Settings",
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              _showEventOptionsDialog(context, event);
            },
          ),
          IconButton(
            tooltip: "Copy URL",
            icon: const Icon(Icons.copy_sharp, color: Colors.white),
            onPressed: () {
              final fakeUrl = 'https://cumbiaLive.com/events/${event.id}';
              Clipboard.setData(ClipboardData(text: fakeUrl));
              debugPrint('Copy URL for ${event.title}');
              showToast(context, 'URL copied to clipboard');
            },
          ),
        ],
      ),
    );
  }

  void _showEventOptionsDialog(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Opciones de eventos"),
        content: const Text("Elija una acción para este evento"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              _editEventDate(event);  // call your edit function
            },
            child: const Text("Editar fecha"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              _confirmDeleteEvent(context, event); // confirm deletion
            },
            child: const Text("Eliminar evento", style: TextStyle(color: Colors.red),),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteEvent(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Eliminar evento"),
        content: const Text("¿Estás seguro que deseas eliminar este evento?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteEvent(event);
            },
            child: const Text("Borrar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEvent(Event event) async {
    try {
      await FirebaseFirestore.instance.collection('events').doc(event.id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete event: $e')),
      );
    }
  }

  Widget _buildEventList(AsyncSnapshot<QuerySnapshot> snapshot, FontSizes fontSizes) {
    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return Center(
        child: Text(
          "No events available",

          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    final events = snapshot.data!.docs
        .map((doc) => Event.fromDoc(doc))
        .toList();

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) => _buildEventTile(events[index], fontSizes),
    );
  }

  Widget _buildNewEventButton(FontSizes fontSizes) {
    var screenSizeHeight = MediaQuery.of(context).size.height;
    var screenSizeWidth = MediaQuery.of(context).size.width;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: screenSizeHeight * 0.15,
          width: screenSizeWidth * 0.2,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                      'assets/img/logowhite.png'),
                  fit: BoxFit.contain)),
        ),
        SizedBox(height: 50),
        Container(
          child: ElevatedButton(
            onPressed: () {
              _addNewEvent(context);
              // HomeScreenState homeScreenState = HomeScreenState();
              // homeScreenState.getData();
              // homeScreenState.dialogToStartProducts(screenSizeHeight, screenSizeWidth, context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF102d54),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(
              "Start new event",
              style: TextStyle(fontSize: fontSizes.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        SizedBox(height: 20),
        Container(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // HomeScreenState homeScreenState = HomeScreenState();
              // homeScreenState.getData();
              // homeScreenState.dialogToStartProducts(screenSizeHeight, screenSizeWidth, context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF102d54),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: Text(
              "Go back",
              style: TextStyle(fontSize: fontSizes.small, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSizeHeight = MediaQuery.of(context).size.height;
    final screenSizeWidth = MediaQuery.of(context).size.width;
    final isMobile = screenSizeWidth < 600;

    final fontSizes = FontSizes(screenSizeHeight, screenSizeWidth);

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).focusColor,
            Theme.of(context).focusColor,
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor,
          ],
        ),
      ),
      child: isMobile
          ? Column(
        children: [
          const SizedBox(height: 40),
          Container(
            height: screenSizeHeight * 0.12,
            width: screenSizeWidth * 0.5,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/img/logowhite.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('events')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return _buildEventList(snapshot, fontSizes);
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: ElevatedButton(
              onPressed: () {
                _addNewEvent(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF102d54),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                "Start new event",
                style: TextStyle(
                  fontSize: fontSizes.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      )
          : Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.all(16),
              child: Center(child: _buildNewEventButton(fontSizes)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(top: 100, bottom: 100, right: 50, left: 0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('events')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return _buildEventList(snapshot, fontSizes);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }


}
