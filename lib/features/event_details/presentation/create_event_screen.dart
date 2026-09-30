import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:event_management_system/features/home/providers/event_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:event_management_system/app/constants/app_colors.dart';
import 'package:event_management_system/core/services/image_upload_service.dart';
import 'package:event_management_system/features/home/models/event_dto.dart';
import 'package:intl/intl.dart';

class CreateEventScreen extends ConsumerStatefulWidget {
  final String? eventId; // null = create, non-null = edit

  const CreateEventScreen({super.key, this.eventId});

  bool get isEditMode => eventId != null;

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final id = widget.eventId;
    if (id != null) {
      // Load the event from the current stream snapshot (already fetched).
      final existing = ref
          .read(eventsWithFavoriteProvider)
          .value
          ?.where((e) => e.id == id)
          .firstOrNull;
      if (existing != null) {
        _titleController.text = existing.title;
        _locationController.text = existing.location;
        _detailController.text = existing.description;
        _dateController.text =
            "${existing.dateTime.day.toString().padLeft(2, '0')}/${existing.dateTime.month.toString().padLeft(2, '0')}/${existing.dateTime.year}";
        _timeController.text = DateFormat('h:mm a').format(existing.dateTime);
        _selectedDate = existing.dateTime;
        _selectedTime = TimeOfDay.fromDateTime(existing.dateTime);
        _selectedCity = existing.city;
        _selectedState = existing.state;
        _selectedCategory = existing.category;
        _selectedGroupId = existing.group;
      }
    }
  }

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  XFile? _selectedImage;
  bool _isLoading = false; // Added state declaration

  final ImagePicker _picker = ImagePicker();

  String? _selectedCity;
  String? _selectedState;
  String? _selectedCategory;
  String _selectedGroupId = 'grp_1';

  static const _cities = [
    'New York',
    'Mesa',
    'Los Angeles',
    'San Francisco',
    'Austin',
  ];
  static const _states = ['New Jersey', 'New York', 'California'];
  static const _categories = [
    'Religious',
    'Business',
    'Sports',
    'Education',
    'Community',
  ];
  static const _groups = [
    {'id': 'grp_1', 'name': 'Business group'},
    {'id': 'grp_2', 'name': 'Sports Club'},
    {'id': 'grp_3', 'name': 'Tech Community'},
    {'id': 'grp_4', 'name': 'Book Club'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (!mounted) return;
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valid date and time')),
      );
      return;
    }
    if (_selectedCity == null ||
        _selectedState == null ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select city, state, and category'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final DateTime eventDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    try {
      // 1. Upload image (if any) to Cloudinary via the service.
      final imageUrl = await ref
          .read(imageUploadServiceProvider)
          .uploadOrKeep(file: _selectedImage, bucket: ImageBucket.event);

      // 2. Create/edit event doc in Firestore.
      if (widget.isEditMode) {
        final req = UpdateEventRequest(
          title: _titleController.text.trim(),
          description: _detailController.text.trim(),
          dateTime: eventDateTime,
          location: _locationController.text.trim(),
          city: _selectedCity,
          state: _selectedState,
          category: _selectedCategory,
          groupId: _selectedGroupId,
          imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
        );
        await ref.read(eventActionsProvider).update(widget.eventId!, req);
      } else {
        final req = CreateEventRequest(
          title: _titleController.text.trim(),
          description: _detailController.text.trim(),
          dateTime: eventDateTime,
          location: _locationController.text.trim(),
          city: _selectedCity ?? 'Unknown',
          state: _selectedState ?? 'Unknown',
          category: _selectedCategory ?? 'Business',
          groupId: _selectedGroupId,
        );
        await ref
            .read(eventActionsProvider)
            .create(req, imageUrl: imageUrl.isNotEmpty ? imageUrl : null);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditMode
                  ? 'Event updated successfully'
                  : 'Event created successfully',
            ),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to create event: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditMode ? 'Edit Event' : 'Create Event',
          style: const TextStyle(fontWeight: FontWeight.bold),
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
              _buildLabel('Title'),
              _buildTextField(
                controller: _titleController,
                hint: 'Made in Melanin! Black History Month Social',
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Title is required'
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Date'),
                        _buildTextField(
                          controller: _dateController,
                          hint: '24/02/2024',
                          suffixIcon: Icons.calendar_today,
                          readOnly: true,
                          onTap: () => _selectDate(context),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Select date'
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Time'),
                        _buildTextField(
                          controller: _timeController,
                          hint: '12:00 PM',
                          suffixIcon: Icons.access_time,
                          readOnly: true,
                          onTap: () => _selectTime(context),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Select time'
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildLabel('Location'),
              _buildTextField(
                controller: _locationController,
                hint: '1901 Thornridge Cir. Shiloh, Hawaii 81063',
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Location is required'
                    : null,
              ),
              const SizedBox(height: 16),
              _buildLabel('City'),
              _buildDropdown<String>(
                value: _selectedCity,
                hint: 'Select city',
                items: _cities
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCity = v),
              ),
              const SizedBox(height: 16),
              _buildLabel('State'),
              _buildDropdown<String>(
                value: _selectedState,
                hint: 'Select state',
                items: _states
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedState = v),
              ),
              const SizedBox(height: 16),
              _buildLabel('Category'),
              _buildDropdown<String>(
                value: _selectedCategory,
                hint: 'Select category',
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
              ),
              const SizedBox(height: 16),
              _buildLabel('Group'),
              _buildDropdown<String>(
                value: _selectedGroupId,
                hint: 'Select group',
                items: _groups
                    .map(
                      (g) => DropdownMenuItem(
                        value: g['id'],
                        child: Text(g['name']!),
                      ),
                    )
                    .toList(),
                onChanged: (v) =>
                    setState(() => _selectedGroupId = v ?? 'grp_1'),
              ),

              const SizedBox(height: 16),
              _buildLabel('Event Detail'),
              _buildTextField(
                controller: _detailController,
                hint: 'Event description details...',
                maxLines: 5,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Detail is required'
                    : null,
              ),
              const SizedBox(height: 16),
              _buildLabel('Upload Image'),
              _buildImagePickerBox(),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
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
                      : Text(
                          widget.isEditMode ? 'Save Changes' : 'Create Event',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
    ),
  );

  Widget _buildTextField({
    required String hint,
    TextEditingController? controller,
    int maxLines = 1,
    IconData? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textVote, fontSize: 13),
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: Icon(suffixIcon, size: 18, color: AppColors.textSubtle),
                onPressed: onTap,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderInput),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      hint: Text(
        hint,
        style: const TextStyle(color: AppColors.textVote, fontSize: 13),
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderInput),
        ),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildImagePickerBox() {
    return GestureDetector(
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
                    ? Image.network(_selectedImage!.path, fit: BoxFit.cover)
                    : Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.upload_outlined, color: AppColors.textSubtle),
                  SizedBox(height: 4),
                  Text(
                    'Upload',
                    style: TextStyle(color: AppColors.textSubtle, fontSize: 12),
                  ),
                ],
              ),
      ),
    );
  }
}
