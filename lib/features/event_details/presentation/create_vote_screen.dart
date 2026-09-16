import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:event_management_system/features/community/models/community_poll_model.dart';
import 'package:event_management_system/features/community/providers/community_polls_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:event_management_system/app/constants/app_colors.dart';

class CreateVoteScreen extends ConsumerStatefulWidget {
  const CreateVoteScreen({super.key});

  @override
  ConsumerState<CreateVoteScreen> createState() => _CreateVoteScreenState();
}

class _CreateVoteScreenState extends ConsumerState<CreateVoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false; // Added state declaration

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addOption() {
    if (_optionControllers.length < 6) {
      setState(() {
        _optionControllers.add(TextEditingController());
      });
    }
  }

  void _removeOption(int index) {
    if (_optionControllers.length > 2) {
      final controller = _optionControllers.removeAt(index);
      controller.dispose();
      setState(() {});
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  Future<void> _submitVote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final newPoll = PollModel(
        id: 'poll_${DateTime.now().millisecondsSinceEpoch}',
        question: _questionController.text.trim(),
        imageUrl: _selectedImage?.path,
        options: _optionControllers
            .asMap()
            .entries
            .map(
              (e) => PollOption(
                id: 'opt_${e.key}_${DateTime.now().millisecondsSinceEpoch}',
                text: e.value.text.trim(),
                votes: 0,
              ),
            )
            .toList(),
      );

      await ref.read(communityPollsProvider.notifier).addPoll(newPoll);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Poll Created Successfully')),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error creating poll: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Vote',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Question',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _questionController,
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Enter poll question'
                    : null,
                decoration: InputDecoration(
                  hintText: 'What topic should we cover next?',
                  hintStyle: const TextStyle(
                    color: AppColors.textVote,
                    fontSize: 13,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Options',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  if (_optionControllers.length < 6)
                    TextButton.icon(
                      onPressed: _addOption,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text(
                        'Add Option',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _optionControllers.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return TextFormField(
                    key: ObjectKey(_optionControllers[index]),
                    controller: _optionControllers[index],
                    validator: (val) => val == null || val.trim().isEmpty
                        ? 'Option cannot be empty'
                        : null,
                    decoration: InputDecoration(
                      hintText: 'Option ${index + 1}',
                      hintStyle: const TextStyle(
                        color: AppColors.textVote,
                        fontSize: 13,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      suffixIcon: _optionControllers.length > 2
                          ? IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: Colors.red,
                                size: 18,
                              ),
                              onPressed: () => _removeOption(index),
                            )
                          : null,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Upload Image',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.borderTechCard),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: kIsWeb
                              ? Image.network(
                                  _selectedImage!.path,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(_selectedImage!.path),
                                  fit: BoxFit.cover,
                                ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.upload_outlined,
                              color: AppColors.textSubtle,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Upload',
                              style: TextStyle(
                                color: AppColors.textSubtle,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitVote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Create Vote',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
