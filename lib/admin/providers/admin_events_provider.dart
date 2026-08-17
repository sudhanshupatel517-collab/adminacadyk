import 'package:flutter/material.dart';
import '../data/admin_models.dart';
import '../data/admin_service.dart';
import '../data/admin_mock_data.dart';

class AdminEventsProvider extends ChangeNotifier {
  List<ManagedEvent> _events = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _statusFilter;
  String? _orgFilter;

  List<ManagedEvent> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  Future<void> loadEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _events = await AdminService.getEvents(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        statusFilter: _statusFilter,
        orgFilter: _orgFilter,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to load events: $e';
      notifyListeners();
    }
  }

  void setSearch(String query) { _searchQuery = query; loadEvents(); }
  void setStatusFilter(String? status) { _statusFilter = (status == null || status.isEmpty) ? null : status; loadEvents(); }
  void setOrgFilter(String? orgId) { _orgFilter = (orgId == null || orgId.isEmpty) ? null : orgId; loadEvents(); }

  Future<bool> createEvent({
    required String title,
    required String description,
    String? venue,
    String? organizer,
    String? organizationId,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? registrationDeadline,
    String? contactInfo,
    String status = 'draft',
    String? createdBy,
  }) async {
    try {
      final event = ManagedEvent(
        id: AdminMockData.nextEventId(),
        title: title,
        description: description,
        venue: venue ?? '',
        organizer: organizer ?? '',
        organizationId: organizationId,
        startDate: startDate,
        endDate: endDate,
        registrationDeadline: registrationDeadline,
        contactInfo: contactInfo,
        status: status,
        createdAt: DateTime.now(),
        createdBy: createdBy,
      );
      await AdminService.createEvent(event);
      await loadEvents();
      return true;
    } catch (e) {
      _error = 'Failed to create event: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateEvent(String eventId, {String? title, String? description, String? venue, String? organizer, String? organizationId, DateTime? startDate, DateTime? endDate, DateTime? registrationDeadline, String? contactInfo, String? status, String? visibility}) async {
    try {
      await AdminService.updateEvent(eventId, title: title, description: description, venue: venue, organizer: organizer, organizationId: organizationId, startDate: startDate, endDate: endDate, registrationDeadline: registrationDeadline, contactInfo: contactInfo, status: status, visibility: visibility);
      await loadEvents();
      return true;
    } catch (e) {
      _error = 'Failed to update event: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateEventStatus(String eventId, String newStatus) async {
    try {
      await AdminService.updateEventStatus(eventId, newStatus);
      await loadEvents();
      return true;
    } catch (e) {
      _error = 'Failed to update event status: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteEvent(String eventId) async {
    try {
      await AdminService.deleteEvent(eventId);
      await loadEvents();
      return true;
    } catch (e) {
      _error = 'Failed to delete event: $e';
      notifyListeners();
      return false;
    }
  }
}
