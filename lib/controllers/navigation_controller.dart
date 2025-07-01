// lib/controllers/navigation_controller.dart
import 'package:get/get.dart';

class NavigationController extends GetxController {
  // .obs makes this variable reactive.
  // It holds the index of the currently selected tab.
  var selectedIndex = 0.obs;

  // Method to update the selected index when a tab is tapped.
  void changePage(int index) {
    selectedIndex.value = index;
  }
}