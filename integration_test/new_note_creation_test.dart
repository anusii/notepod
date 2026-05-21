import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:notepod/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('user with cached credentials can create and save a new note',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Tap on the FAB to add a new note (if it exists)
      final addNoteButton = find.byIcon(Icons.add);
      if (addNoteButton.evaluate().isNotEmpty) {
        await tester.tap(addNoteButton);
        await tester.pumpAndSettle();
      } else {
        // Alternatively it might be an 'Add Note' text button
        final addNoteText = find.text('Add Note');
        if (addNoteText.evaluate().isNotEmpty) {
          await tester.tap(addNoteText);
          await tester.pumpAndSettle();
        }
      }

      // We expect to find text fields for the title and content
      expect(find.byType(TextFormField), findsWidgets);

      // Enter a title
      final titleField = find.byType(TextFormField).first;
      await tester.enterText(titleField, 'Automated Test Note');

      // The content field is typically the second or last text field
      final contentField = find.byType(TextFormField).last;
      await tester.enterText(contentField, 'This is a test note created by an integration test.');

      // Tap on the save button
      final saveButton = find.byIcon(Icons.save);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Verify that the note is now displayed in the list
      expect(find.text('Automated Test Note'), findsWidgets);
    });
  });
}
