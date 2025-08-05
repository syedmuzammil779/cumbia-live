import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cumbia_live_company/add_new_event/model/Event.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class EventController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Reactive state
  Rxn<DateTime> selectedDateTime = Rxn<DateTime>();
  RxString? bannerUrl = RxString('');
  RxString? streamLink = RxString('');
  RxList<String> selectedProductIds = <String>[].obs;

  /// Create a new event in Firestore
  Future<void> createEvent(BuildContext context) async {
    if (selectedDateTime.value == null) {
      _showSnackBar(context, 'Por favor selecciona una fecha y hora');
      return;
    }

    final newEvent = Event(
      id: Uuid().v4(),
      title: _getFormattedEventTitle(),
      eventDateTime: selectedDateTime.value!,
      streamLink: streamLink?.value,
      bannerUrl: bannerUrl?.value,
      selectedProductIds: selectedProductIds.toList(),
    );

    try {
      await _firestore.collection('events').doc(newEvent.id).set(newEvent.toMap());
      _showSnackBar(context, 'Evento creado exitosamente');
      clearInputs();
    } catch (e) {
      debugPrint('Error al crear el evento: $e');
      _showSnackBar(context, 'Fallo al crear el evento');
    }
  }

  /// Edit event date only
  Future<void> editEventDate(BuildContext context, String eventId, DateTime newDate) async {
    try {
      await _firestore.collection('events').doc(eventId).update({
        'eventDateTime': newDate.toIso8601String(),
      });
      _showSnackBar(context, 'Fecha del evento actualizada');
    } catch (e) {
      debugPrint('Error updating event: $e');
      _showSnackBar(context, 'Error al actualizar fecha del evento');
    }
  }

  /// Delete an event
  Future<void> deleteEvent(BuildContext context, String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
      _showSnackBar(context, 'Evento eliminado');
    } catch (e) {
      debugPrint('Error deleting event: $e');
      _showSnackBar(context, 'Fallo al eliminar el evento');
    }
  }

  /// Reset controller inputs
  void clearInputs() {
    selectedDateTime.value = null;
    bannerUrl?.value = '';
    streamLink?.value = '';
    selectedProductIds.clear();
  }

  /// Generate title like "julio 28 - lanzamiento"
  String _getFormattedEventTitle() {
    final now = DateTime.now();
    final day = now.day;
    final month = DateFormat.MMMM('es_ES').format(now);
    return '$month $day - lanzamiento';
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
