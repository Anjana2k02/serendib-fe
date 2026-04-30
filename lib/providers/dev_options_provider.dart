import 'package:flutter/material.dart';

class DevOptionsProvider extends ChangeNotifier {
  bool _developerOptionsEnabled = false;
  String _selectedLocation = 'Location A';
  String _selectedActivity = 'Standing';

  static const List<String> locations = [
    'Location A',
    'Location B',
    'Location C',
    'Location D',
    'Location E',
    'Location F',
    'Location G',
  ];

  static const List<String> activities = [
    'Standing',
    'Sitting',
    'Walking',
    'Not Found',
  ];

  bool get developerOptionsEnabled => _developerOptionsEnabled;
  String get selectedLocation => _selectedLocation;
  String get selectedActivity => _selectedActivity;

  void setDeveloperOptions(bool value) {
    _developerOptionsEnabled = value;
    notifyListeners();
  }

  void setSelectedLocation(String location) {
    _selectedLocation = location;
    notifyListeners();
  }

  void setSelectedActivity(String activity) {
    _selectedActivity = activity;
    notifyListeners();
  }
}
