import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final DateTime? eventDateTime;

  Event({
    required this.id,
    required this.title,
    this.eventDateTime,
  });

  factory Event.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      title: data['title'] ?? '',
      eventDateTime: data['eventDateTime'] != null
          ? DateTime.tryParse(data['eventDateTime'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'eventDateTime': eventDateTime?.toIso8601String(),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
