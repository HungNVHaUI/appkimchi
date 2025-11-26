import 'package:flutter/material.dart';
import 'package:ghi_no/create_note/widgets/create_note_form.dart';
import '../theme/constants/sizes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/constants/text_strings.dart';

class CreateNoteScreen extends StatelessWidget {
  const CreateNoteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(TTexts.createNoteTitle, style: Theme.of(context).textTheme.headlineMedium),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Nền trong suốt
        elevation: 0,
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: TSizes.spaceBtwItems),
              ///Form
              CreateNoteForm(),
            ],
          ),
        ),
      ),
    );
  }
}


