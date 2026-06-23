import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TestHelpers {
  /// Fills a login form and taps the sign in button.
  static Future<void> loginUser(WidgetTester tester, String email, String password) async {
    final emailField = find.byType(TextFormField).first;
    final passwordField = find.byType(TextFormField).last;
    final loginButton = find.byType(ElevatedButton);

    await tester.enterText(emailField, email);
    await tester.enterText(passwordField, password);
    await tester.pumpAndSettle();

    await tester.tap(loginButton);
    await tester.pumpAndSettle();
  }

  /// Navigates to the Add Trip screen and creates a basic trip.
  static Future<void> createBasicTrip(WidgetTester tester, String title) async {
    // Assuming we are on the HomeScreen and there's a Fab or Add button
    // Find add button - in HomeScreen it's likely an icon button or fab
    final addButton = find.byIcon(Icons.add);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    // Fill title
    final titleField = find.byType(TextFormField).first;
    await tester.enterText(titleField, title);
    
    // Save trip
    final saveButton = find.byType(ElevatedButton).at(0); // Add Trip button usually first
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
  }

  /// Opens the settings screen from the home screen.
  static Future<void> openSettings(WidgetTester tester) async {
    // Assuming settings is in the bottom nav or app bar
    final settingsNav = find.byIcon(Icons.settings);
    await tester.tap(settingsNav);
    await tester.pumpAndSettle();
  }
}
