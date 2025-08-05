import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cumbia_live_company/add_new_event/model/Event.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class EventService {
  static final _eventsCollection = FirebaseFirestore.instance.collection('events');

  /// Add a new event with optional streamLink, bannerUrl, and selectedProductIds
  static Future<void> addNewEvent(
      BuildContext context,
      DateTime pickedDate, {
        String? streamLink,
        String? bannerUrl,
        List<String> selectedProductIds = const [],
      }) async {
    final newEvent = Event(
      id: Uuid().v4(),
      title: _getFormattedEventTitle(),
      eventDateTime: pickedDate,
      streamLink: streamLink,
      bannerUrl: bannerUrl,
      selectedProductIds: selectedProductIds,
    );

    try {
      await _eventsCollection.doc(newEvent.id).set(newEvent.toMap());
      _showSnackBar(context, 'Event added');
    } catch (e) {
      debugPrint('Error adding event: $e');
      _showSnackBar(context, 'Failed to add event: $e');
    }
  }

  /// Edit event date only
  static Future<void> editEventDate(BuildContext context, Event event, DateTime newDate) async {
    try {
      await _eventsCollection
          .doc(event.id)
          .update({'eventDateTime': newDate.toIso8601String()});
      _showSnackBar(context, 'Event updated');
    } catch (e) {
      debugPrint('Error updating event: $e');
      _showSnackBar(context, 'Failed to update event: $e');
    }
  }

  /// Delete event
  static Future<void> deleteEvent(BuildContext context, Event event) async {
    try {
      await _eventsCollection.doc(event.id).delete();
      _showSnackBar(context, 'Event deleted');
    } catch (e) {
      debugPrint('Error deleting event: $e');
      _showSnackBar(context, 'Failed to delete event: $e');
    }
  }

  static String _getFormattedEventTitle() {
    final now = DateTime.now();
    final day = now.day;
    final month = DateFormat.MMMM('es_ES').format(now);
    return '$month $day - lanzamiento';
  }

  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
