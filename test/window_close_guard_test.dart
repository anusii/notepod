// Widget tests for the desktop window-close save prompt as wired up by
// NoteEditScrollView — the editor shared by NewNote and EditNote.
//
// Runs without a live Pod: the Pod write is supplied through the editor's
// onSave callback, so only rendering / state behaviour is exercised.

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solidui/solidui.dart';

import 'package:notepod/constants/app.dart';
import 'package:notepod/widgets/note_edit_scroll_view.dart';

late SolidScaffoldController controller;
late TextEditingController textController;

/// Build the note editor holding an existing note titled `Old title` with
/// `Old body` as its content, so that nothing is unsaved to begin with.

Widget wrap({required Future<bool> Function() onSave}) {
  textController = TextEditingController(text: 'Old body');

  return MaterialApp(
    home: Scaffold(
      body: NoteEditScrollView(
        formKey: GlobalKey<FormBuilderState>(),
        textController: textController,
        scaffoldController: controller,
        focusTitle: FocusNode(),
        focusContent: FocusNode(),
        childPage: const SizedBox(),
        data: 'Old body',
        onSave: onSave,
        noteTitle: 'Old title',
        isExisting: true,
      ),
    ),
  );
}

/// Type a new title, which is what makes the editor dirty.

Future<void> editTitle(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField).first, 'New title');
  await tester.pump();
}

void main() {
  setUp(() => controller = SolidScaffoldController());

  tearDown(() {
    controller.dispose();
    textController.dispose();
  });

  testWidgets('resolveAll succeeds with no prompt when nothing changed', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(onSave: () async => true));
    await tester.pumpAndSettle();

    expect(await SolidWindowCloseGuard.resolveAll(), isTrue);
    expect(find.text('Unsaved changes'), findsNothing);
  });

  testWidgets('resolveAll prompts and resolves true on Discard', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(onSave: () async => true));
    await tester.pumpAndSettle();
    await editTitle(tester);

    final future = SolidWindowCloseGuard.resolveAll();
    await tester.pumpAndSettle();
    expect(find.text('Unsaved changes'), findsOneWidget);

    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(await future, isTrue);
  });

  testWidgets('resolveAll prompts and resolves false on Keep editing', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(onSave: () async => true));
    await tester.pumpAndSettle();
    await editTitle(tester);

    final future = SolidWindowCloseGuard.resolveAll();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();
    expect(await future, isFalse);
    // The editor is still open with the unsaved title intact.
    expect(find.text('New title'), findsOneWidget);
  });

  // Regression: the Save button used to build the Pod write itself, so the
  // window-close path had nothing to await. resolveAll() returned at once,
  // the window was destroyed mid-write, and the edit was lost despite the
  // user tapping Save.

  testWidgets('window-close Save waits for the Pod write to finish', (
    tester,
  ) async {
    final podWrite = Completer<void>();
    var written = false;

    await tester.pumpWidget(
      wrap(
        onSave: () async {
          await podWrite.future;
          written = true;

          return true;
        },
      ),
    );
    await tester.pumpAndSettle();
    await editTitle(tester);

    var resolved = false;
    final future = SolidWindowCloseGuard.resolveAll()
      ..then((_) => resolved = true);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // The Pod write is still in flight, so the guard must NOT have resolved
    // — otherwise the caller would destroy the window and lose the note.

    expect(resolved, isFalse);
    expect(written, isFalse);

    podWrite.complete();
    await tester.pumpAndSettle();

    expect(await future, isTrue);
    expect(written, isTrue);
  });

  // Regression: a failed Pod write was swallowed, so the guard resolved true
  // and the window was destroyed over the top of a note that never reached
  // the Pod — the exact loss the prompt exists to prevent.

  testWidgets('window-close Save aborts the close when the write fails', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(onSave: () async => false));
    await tester.pumpAndSettle();
    await editTitle(tester);

    final future = SolidWindowCloseGuard.resolveAll();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(await future, isFalse);
    // The editor is still open with the unsaved title intact.
    expect(find.text('New title'), findsOneWidget);
  });

  testWidgets('window-close Save aborts the close and reports a throw', (
    tester,
  ) async {
    SolidWriteFailures.clear();
    addTearDown(SolidWriteFailures.clear);

    await tester.pumpWidget(
      wrap(onSave: () async => throw Exception('Pod unreachable')),
    );
    await tester.pumpAndSettle();
    await editTitle(tester);

    final future = SolidWindowCloseGuard.resolveAll();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(await future, isFalse);
    expect(find.text('New title'), findsOneWidget);
    // Reported with notepod's own wording, not a generic message.
    expect(SolidWriteFailures.latest.value, contains(ErrMsg.saveFailed));
  });

  testWidgets('editor unregisters its resolver on dispose', (tester) async {
    await tester.pumpWidget(wrap(onSave: () async => true));
    await tester.pumpAndSettle();

    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pumpAndSettle();

    // No editor left registered, so nothing to resolve.

    expect(await SolidWindowCloseGuard.resolveAll(), isTrue);
  });
}
