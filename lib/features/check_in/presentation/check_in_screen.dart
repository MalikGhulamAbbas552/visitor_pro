import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/router.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/presentation/widgets/auth_text_field.dart';
import '../../visitors/data/visitor_service.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _companyController = TextEditingController();
  final _purposeController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  XFile? _selectedPhoto;
  Uint8List? _selectedPhotoBytes;

  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _loading = true);

    try {
      final visitor = await VisitorService.instance.checkInVisitor(
        fullName: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        company: _companyController.text,
        purpose: _purposeController.text,
      );

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _SuccessDialog(
          visitorName: visitor.fullName,
        ),
      );

      if (!mounted) return;

      context.go(AppRoutes.dashboard);
    } on PostgrestException catch (error) {
      if (!mounted) return;
      _showError(error.message);
    } catch (_) {
      if (!mounted) return;

      _showError(
        'Unable to check in visitor. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _pickPhoto(
      ImageSource source,
      ) async {
    try {
      final photo = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (photo == null) {
        return;
      }

      final bytes = await photo.readAsBytes();

      const maxSize = 5 * 1024 * 1024;

      if (bytes.length > maxSize) {
        if (!mounted) return;

        _showError(
          'Please select an image smaller than 5 MB.',
        );

        return;
      }

      if (!mounted) return;

      setState(() {
        _selectedPhoto = photo;
        _selectedPhotoBytes = bytes;
      });
    } catch (_) {
      if (!mounted) return;

      _showError(
        'Unable to select photo.',
      );
    }
  }

  Future<void> _showPhotoOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              5,
              20,
              25,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Visitor Photo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 20),

                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(
                      Icons.camera_alt_outlined,
                    ),
                  ),
                  title: const Text('Take Photo'),
                  subtitle: const Text(
                    'Use device camera',
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);

                    _pickPhoto(
                      ImageSource.camera,
                    );
                  },
                ),

                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(
                      Icons.photo_library_outlined,
                    ),
                  ),
                  title: const Text(
                    'Choose from Gallery',
                  ),
                  subtitle: const Text(
                    'Select an existing photo',
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);

                    _pickPhoto(
                      ImageSource.gallery,
                    );
                  },
                ),

                if (_selectedPhoto != null)
                  ListTile(
                    leading: const CircleAvatar(
                      child: Icon(
                        Icons.delete_outline_rounded,
                      ),
                    ),
                    title: const Text(
                      'Remove Photo',
                    ),
                    onTap: () {
                      Navigator.pop(sheetContext);

                      setState(() {
                        _selectedPhoto = null;
                        _selectedPhotoBytes = null;
                      });
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhotoPicker() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _showPhotoOptions,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration:
                  const Duration(milliseconds: 300),
                  width: 112,
                  height: 112,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: _selectedPhotoBytes == null
                          ? AppColors.primary.withValues(
                        alpha: .18,
                      )
                          : AppColors.primary,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(
                          alpha: .10,
                        ),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _selectedPhotoBytes == null
                        ? Container(
                      color: AppColors.lightBlue,
                      child:  Icon(
                        Icons.person_rounded,
                        size: 55,
                        color: AppColors.primary,
                      ),
                    )
                        : Image.memory(
                      _selectedPhotoBytes!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                Positioned(
                  right: -2,
                  bottom: 3,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 17,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          TextButton.icon(
            onPressed: _showPhotoOptions,
            icon: Icon(
              _selectedPhotoBytes == null
                  ? Icons.add_a_photo_outlined
                  : Icons.edit_outlined,
              size: 18,
            ),
            label: Text(
              _selectedPhotoBytes == null
                  ? 'Add visitor photo'
                  : 'Change photo',
            ),
          ),

          const Text(
            'Optional • Maximum 5 MB',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Check In Visitor',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            keyboardDismissBehavior:
            ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(
              20,
              10,
              20,
              35,
            ),
            children: [
              _buildHeader(),

              const SizedBox(height: 25),

              _buildPhotoPicker(),

              const SizedBox(height: 30),

              const _Label(
                title: 'Full Name',
                requiredField: true,
              ),

              const SizedBox(height: 8),

              AuthTextField(
                controller: _nameController,
                hintText: 'Enter visitor name',
                prefixIcon: Icons.person_outline_rounded,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  final name = value?.trim() ?? '';

                  if (name.length < 3) {
                    return 'Please enter visitor full name';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              const _Label(
                title: 'Phone Number',
                requiredField: true,
              ),

              const SizedBox(height: 8),

              AuthTextField(
                controller: _phoneController,
                hintText: 'e.g. +92 300 1234567',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  final phone = value
                      ?.replaceAll(
                    RegExp(r'[\s\-()]'),
                    '',
                  )
                      .trim() ??
                      '';

                  if (phone.length < 10) {
                    return 'Enter a valid phone number';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              const _Label(title: 'Email'),

              const SizedBox(height: 8),

              AuthTextField(
                controller: _emailController,
                hintText: 'visitor@example.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  final email = value?.trim() ?? '';

                  if (email.isEmpty) {
                    return null;
                  }

                  final valid = RegExp(
                    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
                  ).hasMatch(email);

                  return valid
                      ? null
                      : 'Enter a valid email address';
                },
              ),

              const SizedBox(height: 18),

              const _Label(title: 'Company'),

              const SizedBox(height: 8),

              AuthTextField(
                controller: _companyController,
                hintText: 'Company or organization',
                prefixIcon: Icons.business_outlined,
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 18),

              const _Label(
                title: 'Purpose of Visit',
                requiredField: true,
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: _purposeController,
                minLines: 3,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                validator: (value) {
                  if ((value?.trim().length ?? 0) < 3) {
                    return 'Please enter purpose of visit';
                  }

                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Meeting, delivery, interview...',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 55),
                    child: Icon(
                      Icons.description_outlined,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: AppColors.primary.withValues(
                        alpha: .10,
                      ),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                height: 58,
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _loading
                        ? const SizedBox.square(
                      key: ValueKey('loading'),
                      dimension: 23,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                        : const Row(
                      key: ValueKey('check-in'),
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login_rounded),
                        SizedBox(width: 9),
                        Text(
                          'Check In Visitor',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: .12),
            AppColors.primary.withValues(alpha: .03),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Row(
        children: [
          _HeaderIcon(),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'New Visitor',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Enter visitor details to complete check-in.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(17),
      ),
      child: const Icon(
        Icons.person_add_alt_1_rounded,
        color: Colors.white,
        size: 27,
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({
    required this.title,
    this.requiredField = false,
  });

  final String title;
  final bool requiredField;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (requiredField)
          const Text(
            ' *',
            style: TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}

class _SuccessDialog extends StatefulWidget {
  const _SuccessDialog({
    required this.visitorName,
  });

  final String visitorName;

  @override
  State<_SuccessDialog> createState() => _SuccessDialogState();
}

class _SuccessDialogState extends State<_SuccessDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25, 30, 25, 24),
        child: FadeTransition(
          opacity: _fade,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: .12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    size: 62,
                    color: AppColors.success,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                'Check-In Successful!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 9),

              Text(
                '${widget.visitorName} has been checked in successfully.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  height: 1.5,
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}