import 'package:flutter/material.dart';
import '../../create_note/model/note_model.dart';
import '../../theme/constants/sizes.dart';
import 'note_item_card.dart';

class NotesListView extends StatelessWidget {
  final List<NoteModel> notes;
  const NotesListView({super.key, required this.notes});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: notes.length,
      separatorBuilder: (_, __) => const SizedBox(height: TSizes.defaultSpace),
      itemBuilder: (context, index) {
        final note = notes[index];
        // Chỉ cần truyền NoteModel vào item con
        return NoteItemCard(note: note);
      },
    );
  }
}