import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/artifact.dart';
import '../../providers/artifact_provider.dart';

class ArtifactFormScreen extends StatefulWidget {
  final Artifact? artifact;

  const ArtifactFormScreen({super.key, this.artifact});

  @override
  State<ArtifactFormScreen> createState() => _ArtifactFormScreenState();
}

class _ArtifactFormScreenState extends State<ArtifactFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _categoryController;
  late final TextEditingController _originCountryController;
  late final TextEditingController _estimatedValueController;
  late final TextEditingController _locationController;
  late bool _isOnDisplay;
  DateTime? _dateAcquired;
  bool _isLoading = false;

  bool get _isEditMode => widget.artifact != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.artifact?.name ?? '');
    _descriptionController = TextEditingController(text: widget.artifact?.description ?? '');
    _categoryController = TextEditingController(text: widget.artifact?.category ?? '');
    _originCountryController = TextEditingController(text: widget.artifact?.originCountry ?? '');
    _estimatedValueController = TextEditingController(
      text: widget.artifact?.estimatedValue?.toString() ?? '',
    );
    _locationController = TextEditingController(text: widget.artifact?.locationInMuseum ?? '');
    _isOnDisplay = widget.artifact?.isOnDisplay ?? false;
    _dateAcquired = widget.artifact?.dateAcquired;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _originCountryController.dispose();
    _estimatedValueController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateAcquired ?? DateTime.now(),
      firstDate: DateTime(1800),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _dateAcquired = picked);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final artifact = Artifact(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      category: _categoryController.text.trim(),
      originCountry: _originCountryController.text.trim().isEmpty
          ? null
          : _originCountryController.text.trim(),
      dateAcquired: _dateAcquired,
      estimatedValue: _estimatedValueController.text.trim().isEmpty
          ? null
          : double.tryParse(_estimatedValueController.text.trim()),
      isOnDisplay: _isOnDisplay,
      locationInMuseum: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
    );

    final provider = context.read<ArtifactProvider>();
    bool success;

    if (_isEditMode) {
      success = await provider.updateArtifact(widget.artifact!.id!, artifact);
    } else {
      success = await provider.createArtifact(artifact);
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode ? 'Artifact updated successfully' : 'Artifact created successfully',
          ),
        ),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Operation failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Artifact' : 'Create Artifact'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  hintText: 'Enter artifact name',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spacingMd),

              // Category
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  hintText: 'Enter category',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Category is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spacingMd),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter description',
                ),
                maxLines: 4,
              ),
              const SizedBox(height: AppConstants.spacingMd),

              // Origin Country
              TextFormField(
                controller: _originCountryController,
                decoration: const InputDecoration(
                  labelText: 'Origin Country',
                  hintText: 'Enter origin country',
                ),
              ),
              const SizedBox(height: AppConstants.spacingMd),

              // Date Acquired
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date Acquired',
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _dateAcquired != null
                            ? '${_dateAcquired!.year}-${_dateAcquired!.month.toString().padLeft(2, '0')}-${_dateAcquired!.day.toString().padLeft(2, '0')}'
                            : 'Select date',
                        style: TextStyle(
                          color: _dateAcquired != null
                              ? AppColors.textPrimary
                              : AppColors.textTertiary,
                        ),
                      ),
                      const Icon(Icons.calendar_today, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingMd),

              // Estimated Value
              TextFormField(
                controller: _estimatedValueController,
                decoration: const InputDecoration(
                  labelText: 'Estimated Value',
                  hintText: 'Enter estimated value',
                  prefixText: '\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (double.tryParse(value.trim()) == null) {
                      return 'Please enter a valid number';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spacingMd),

              // Location in Museum
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location in Museum',
                  hintText: 'Enter location (e.g., Wing A, Room 3)',
                ),
              ),
              const SizedBox(height: AppConstants.spacingMd),

              // Is On Display toggle
              SwitchListTile(
                title: const Text('On Display'),
                subtitle: const Text('Is this artifact currently on display?'),
                value: _isOnDisplay,
                activeColor: AppColors.primaryBrown,
                onChanged: (value) {
                  setState(() => _isOnDisplay = value);
                },
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: AppConstants.spacingXl),

              // Submit button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditMode ? 'Update Artifact' : 'Create Artifact'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
