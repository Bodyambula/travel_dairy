import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/trips_provider.dart';

class AddTripScreen extends StatefulWidget {
  final Trip? tripToEdit;

  const AddTripScreen({super.key, this.tripToEdit});

  @override
  State<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final user = FirebaseAuth.instance.currentUser;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  DateTimeRange? _selectedDateRange;
  // List of images. Each item is a Base64 string.
  List<String> _base64Images = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final trip = widget.tripToEdit;

    _titleController = TextEditingController(text: trip?.title ?? '');
    _descriptionController = TextEditingController(
      text: trip?.description ?? '',
    );

    if (trip != null && trip.dates.isNotEmpty && trip.dates.length >= 2) {
      try {
        final dateFormat = DateFormat('dd.MM.yyyy');
        final start = dateFormat.parse(trip.dates.first);
        final end = dateFormat.parse(trip.dates.last);
        _selectedDateRange = DateTimeRange(start: start, end: end);
      } catch (e) {
        print("Error parsing dates: $e");
      }
    }

    if (trip != null) {
      _base64Images = List.from(trip.imagesBase64);
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    // Use selectMultiImage for selecting multiple photos
    final List<XFile> images = await picker.pickMultiImage(imageQuality: 50);

    if (images.isNotEmpty) {
      final newBase64Images = <String>[];
      for (var image in images) {
        final file = File(image.path);
        final bytes = await file.readAsBytes();
        final base64String = base64Encode(bytes);
        newBase64Images.add(base64String);
      }

      setState(() {
        _base64Images.addAll(newBase64Images);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _base64Images.removeAt(index);
    });
  }

  Future<void> _pickDateRange() async {
    final initialDateRange =
        _selectedDateRange ??
        DateTimeRange(
          start: DateTime.now(),
          end: DateTime.now().add(const Duration(days: 3)),
        );

    final newDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: initialDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1A3D8F),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (newDateRange != null) {
      setState(() {
        _selectedDateRange = newDateRange;
      });
    }
  }

  Future<void> _saveTrip() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Будь ласка, оберіть дати подорожі')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final dateFormat = DateFormat('dd.MM.yyyy');
      final datesList = [
        dateFormat.format(_selectedDateRange!.start),
        dateFormat.format(_selectedDateRange!.end),
      ];

      final tripData = Trip(
        id: widget.tripToEdit?.id,
        userId: user?.uid ?? '',
        title: _titleController.text,
        cities: widget.tripToEdit?.cities ?? [],
        dates: datesList,
        photosCount: _base64Images.length,
        imagesBase64: _base64Images,
        description: _descriptionController.text,
      );

      final provider = Provider.of<TripsProvider>(context, listen: false);

      if (widget.tripToEdit == null) {
        await provider.addTrip(tripData);
      } else {
        await provider.updateTrip(tripData);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Помилка: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF333333),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required String? value,
    required VoidCallback onTap,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!, width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value ?? hint ?? 'дд. мм. рррр',
                    style: TextStyle(
                      color: value == null ? Colors.grey[500] : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.black87,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1A3D8F);

    return Scaffold(
      backgroundColor: primaryBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check, color: Colors.white, size: 28),
              onPressed: _saveTrip,
            ),
        ],
      ),
      body: Column(
        children: [
          // Header Texts
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                Text(
                  "Нова подорож",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Заповніть деталі",
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ),

          // White Container
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Trip Name
                      _buildLabel("Назва подорожі"),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: "Наприклад: Літо в Греції",
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: primaryBlue,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 1.5,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        validator: (v) => v!.isEmpty ? 'Введіть назву' : null,
                      ),
                      const SizedBox(height: 20),

                      // Dates
                      _buildDateField(
                        label: "Дата початку",
                        value: _selectedDateRange == null
                            ? null
                            : DateFormat(
                                'dd.MM.yyyy',
                              ).format(_selectedDateRange!.start),
                        onTap: _pickDateRange,
                        hint: "дд. мм. рррр",
                      ),
                      const SizedBox(height: 20),

                      _buildDateField(
                        label: "Дата завершення",
                        value: _selectedDateRange == null
                            ? null
                            : DateFormat(
                                'dd.MM.yyyy',
                              ).format(_selectedDateRange!.end),
                        onTap: _pickDateRange,
                        hint: "дд. мм. рррр",
                      ),
                      const SizedBox(height: 20),

                      // Description
                      _buildLabel("Опис"),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: "Розкажіть про вашу подорож...",
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: primaryBlue,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Image List Horizontal
                      if (_base64Images.isNotEmpty) ...[
                        _buildLabel("Обрані фото (${_base64Images.length})"),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _base64Images.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 12),
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                      ),
                                      image: DecorationImage(
                                        image: MemoryImage(
                                          base64Decode(_base64Images[index]),
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 4,
                                    top: 4,
                                    child: InkWell(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Buttons
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _pickImages,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            "Додати фото",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Функція 'Побудувати маршрут' скоро з'явиться!",
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            "Побудувати маршрут",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      // Extra space for bottom safe area
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
