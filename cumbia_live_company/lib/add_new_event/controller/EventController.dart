import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../model/Event.dart';

class EventsController extends GetxController {
  final events = <Event>[].obs;
  final isLoading = true.obs;
  final currentPage = 0.obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    isLoading.value = true;
    try {
      final snapshot = await _firestore
          .collection('events')
          .orderBy('eventDateTime')
          .get();

      final list = snapshot.docs.map((doc) => Event.fromDoc(doc)).toList();
      events.assignAll(list);
    } catch (e, stack) {
      print('[EventsController] Error fetching events: $e');
      print(stack);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateEventDate(Event event, DateTime newDate) async {
    try {
      await _firestore
          .collection('events')
          .doc(event.id)
          .update({'eventDateTime': newDate.toIso8601String()});
      fetchEvents();
      Get.snackbar('Success', 'Event updated');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update event: $e');
    }
  }

  Future<void> deleteEvent(Event event) async {
    try {
      await _firestore.collection('events').doc(event.id).delete();
      events.remove(event);
      Get.snackbar('Success', 'Evento eliminado');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo eliminar el evento: $e');
    }
  }

  void setCurrentPage(int index) {
    currentPage.value = index;
  }
}
