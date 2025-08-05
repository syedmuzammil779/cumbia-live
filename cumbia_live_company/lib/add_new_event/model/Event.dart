import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String title;
  final DateTime? eventDateTime;
  final String? streamLink;
  final List<String> selectedProductIds;
  final String? bannerUrl;

  Event({
    required this.id,
    required this.title,
    this.eventDateTime,
    this.streamLink,
    this.selectedProductIds = const [],
    this.bannerUrl,
  });

  factory Event.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Event(
      id: doc.id,
      title: data['title'] ?? '',
      eventDateTime: data['eventDateTime'] != null
          ? DateTime.tryParse(data['eventDateTime'])
          : null,
      streamLink: data['streamLink'],
      selectedProductIds: List<String>.from(data['selectedProductIds'] ?? []),
      bannerUrl: data['bannerUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'eventDateTime': eventDateTime?.toIso8601String(),
      'streamLink': streamLink,
      'selectedProductIds': selectedProductIds,
      'bannerUrl': bannerUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
