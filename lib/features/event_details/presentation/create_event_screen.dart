import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:event_management_system/app/constants/app_colors.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _detailController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  XFile? _selectedImage;

  final ImagePicker _picker = ImagePicker();

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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Logic to emit event state or call API provider
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event Created Successfully')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Event',
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
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Create Event',
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
                child: Image.file(
                  File(_selectedImage!.path),
                  fit: BoxFit.cover,
                ),
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
