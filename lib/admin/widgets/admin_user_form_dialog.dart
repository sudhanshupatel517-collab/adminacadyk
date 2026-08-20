import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/admin_models.dart';
import '../data/admin_mock_data.dart';
import '../../app/theme/app_colors.dart';

class AdminUserFormDialog extends StatefulWidget {
  final ManagedUser? initialUser;
  final Future<bool> Function({
    required String fullName,
    required String email,
    required String role,
    DateTime? dateOfBirth,
    String? fatherName,
    String? fatherMobile,
    String? currentAddress,
    String? department,
    String? enrollmentNumber,
    String? employeeId,
    String? course,
    String? branch,
    DateTime? admissionDate,
    DateTime? registrationDate,
    String? phone,
    String? designation,
    String? status,
  }) onSave;

  const AdminUserFormDialog({
    super.key,
    this.initialUser,
    required this.onSave,
  });

  static Future<bool?> show(
    BuildContext context, {
    ManagedUser? initialUser,
    required Future<bool> Function({
      required String fullName,
      required String email,
      required String role,
      DateTime? dateOfBirth,
      String? fatherName,
      String? fatherMobile,
      String? currentAddress,
      String? department,
      String? enrollmentNumber,
      String? employeeId,
      String? course,
      String? branch,
      DateTime? admissionDate,
      DateTime? registrationDate,
      String? phone,
      String? designation,
      String? status,
    }) onSave,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AdminUserFormDialog(
        initialUser: initialUser,
        onSave: onSave,
      ),
    );
  }

  @override
  State<AdminUserFormDialog> createState() => _AdminUserFormDialogState();
}

class _AdminUserFormDialogState extends State<AdminUserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateFormat = DateFormat('dd MMMM yyyy');

  late TextEditingController _fullNameController;
  late TextEditingController _fatherNameController;
  late TextEditingController _fatherMobileController;
  late TextEditingController _currentAddressController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _enrollmentController;
  late TextEditingController _employeeIdController;
  late TextEditingController _designationController;

  late String _role;
  late String _status;
  String? _selectedCourse;
  String? _selectedBranch;
  String? _selectedDepartment;

  DateTime? _dateOfBirth;
  DateTime? _admissionDate;
  DateTime _registrationDate = DateTime.now();

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final u = widget.initialUser;

    _fullNameController = TextEditingController(text: u?.fullName ?? '');
    _fatherNameController = TextEditingController(text: u?.fatherName ?? '');
    _fatherMobileController = TextEditingController(text: u?.fatherMobile ?? '');
    _currentAddressController = TextEditingController(text: u?.currentAddress ?? '');
    _emailController = TextEditingController(text: u?.email ?? '');
    _phoneController = TextEditingController(text: u?.phone ?? '');
    _enrollmentController = TextEditingController(text: u?.enrollmentNumber ?? '');
    _employeeIdController = TextEditingController(text: u?.employeeId ?? '');
    _designationController = TextEditingController(text: u?.designation ?? '');

    _role = u?.role ?? 'STUDENT';
    _status = u?.status ?? 'active';
    _selectedCourse = u?.course ?? AdminMockData.courses.first;
    _selectedBranch = u?.branch ?? AdminMockData.branches.first;
    _selectedDepartment = u?.department ?? AdminMockData.departments.first;

    _dateOfBirth = u?.dateOfBirth;
    _admissionDate = u?.admissionDate ?? DateTime.now();
    _registrationDate = u?.registrationDate ?? u?.joinedAt ?? DateTime.now();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _fatherNameController.dispose();
    _fatherMobileController.dispose();
    _currentAddressController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _enrollmentController.dispose();
    _employeeIdController.dispose();
    _designationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    required Function(DateTime) onPicked,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) {
      setState(() {
        onPicked(picked);
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dateOfBirth == null) {
      setState(() => _errorMessage = 'Please select Date of Birth.');
      return;
    }
    if (_role == 'STUDENT' && _admissionDate == null) {
      setState(() => _errorMessage = 'Please select Date of Admission.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final success = await widget.onSave(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        role: _role,
        status: _status,
        dateOfBirth: _dateOfBirth,
        fatherName: _fatherNameController.text.trim(),
        fatherMobile: _fatherMobileController.text.trim(),
        currentAddress: _currentAddressController.text.trim(),
        department: _selectedDepartment,
        enrollmentNumber: _role == 'STUDENT' ? _enrollmentController.text.trim() : null,
        employeeId: _role == 'FACULTY' ? _employeeIdController.text.trim() : null,
        course: _role == 'STUDENT' ? _selectedCourse : null,
        branch: _role == 'STUDENT' ? _selectedBranch : null,
        admissionDate: _admissionDate,
        registrationDate: _registrationDate,
        phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        designation: _role == 'FACULTY' ? _designationController.text.trim() : null,
      );

      if (mounted) {
        if (success) {
          Navigator.of(context).pop(true);
        } else {
          setState(() {
            _isSubmitting = false;
            _errorMessage = 'An error occurred while saving the user. Please try again.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = 'Submission failed: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.initialUser != null;
    final cardBg = AppColors.surfaceColor(isDark);
    final borderColor = AppColors.border(isDark);

    return Dialog(
      backgroundColor: cardBg,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: borderColor, width: 1),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820, maxHeight: 860),
        child: Column(
          children: [
            // Modal Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: borderColor, width: 1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEdit ? 'Edit User Record' : 'Add New Institutional User',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text(isDark),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isEdit
                              ? 'Update verified student or faculty member profile in the academic registry.'
                              : 'Register a verified student or faculty member into the institutional registry.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMut(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
                    child: Text('Close', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSec(isDark))),
                  ),
                ],
              ),
            ),

            // Scrollable Form Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth >= 600;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_errorMessage != null)
                            _buildErrorBanner(_errorMessage!, isDark),

                          // SECTION 1: PERSONAL INFORMATION
                          _buildSectionHeader('PERSONAL INFORMATION', isDark),
                          const SizedBox(height: 12),
                          if (isDesktop)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _fullNameController,
                                    label: 'Full Name *',
                                    hint: 'e.g. Sudhanshu Patel',
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) return 'Full Name is required.';
                                      if (v.trim().length < 2) return 'Enter a valid full name.';
                                      return null;
                                    },
                                    isDark: isDark,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDateField(
                                    label: 'Date of Birth *',
                                    value: _dateOfBirth,
                                    isDark: isDark,
                                    onTap: () => _pickDate(
                                      initialDate: _dateOfBirth ?? DateTime(2005, 1, 1),
                                      firstDate: DateTime(1940),
                                      lastDate: DateTime.now().subtract(const Duration(days: 365 * 14)),
                                      onPicked: (d) => _dateOfBirth = d,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else ...[
                            _buildTextField(
                              controller: _fullNameController,
                              label: 'Full Name *',
                              hint: 'e.g. Sudhanshu Patel',
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Full Name is required.';
                                if (v.trim().length < 2) return 'Enter a valid full name.';
                                return null;
                              },
                              isDark: isDark,
                            ),
                            const SizedBox(height: 12),
                            _buildDateField(
                              label: 'Date of Birth *',
                              value: _dateOfBirth,
                              isDark: isDark,
                              onTap: () => _pickDate(
                                initialDate: _dateOfBirth ?? DateTime(2005, 1, 1),
                                firstDate: DateTime(1940),
                                lastDate: DateTime.now().subtract(const Duration(days: 365 * 14)),
                                onPicked: (d) => _dateOfBirth = d,
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          if (isDesktop)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _fatherNameController,
                                    label: "Father's Name *",
                                    hint: 'e.g. Ramesh Patel',
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) return "Father's Name is required.";
                                      return null;
                                    },
                                    isDark: isDark,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _fatherMobileController,
                                    label: "Father's Mobile Number *",
                                    hint: '10-digit mobile (e.g. 9826012345)',
                                    keyboardType: TextInputType.phone,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) return "Father's Mobile Number is required.";
                                      final cleaned = v.trim().replaceAll(RegExp(r'[\s\-]'), '');
                                      if (!RegExp(r'^[6-9]\d{9}$').hasMatch(cleaned)) {
                                        return 'Enter a valid 10-digit mobile number.';
                                      }
                                      return null;
                                    },
                                    isDark: isDark,
                                  ),
                                ),
                              ],
                            )
                          else ...[
                            _buildTextField(
                              controller: _fatherNameController,
                              label: "Father's Name *",
                              hint: 'e.g. Ramesh Patel',
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return "Father's Name is required.";
                                return null;
                              },
                              isDark: isDark,
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: _fatherMobileController,
                              label: "Father's Mobile Number *",
                              hint: '10-digit mobile (e.g. 9826012345)',
                              keyboardType: TextInputType.phone,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return "Father's Mobile Number is required.";
                                final cleaned = v.trim().replaceAll(RegExp(r'[\s\-]'), '');
                                if (!RegExp(r'^[6-9]\d{9}$').hasMatch(cleaned)) {
                                  return 'Enter a valid 10-digit mobile number.';
                                }
                                return null;
                              },
                              isDark: isDark,
                            ),
                          ],

                          const SizedBox(height: 20),

                          // SECTION 2: ADDRESS
                          _buildSectionHeader('ADDRESS', isDark),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _currentAddressController,
                            label: 'Current Address *',
                            hint: 'House/Hostel, Street/Block, City/Town, District, State, PIN Code',
                            maxLines: 3,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Current Address is required.';
                              if (v.trim().length < 6) return 'Please provide full residential address.';
                              return null;
                            },
                            isDark: isDark,
                          ),

                          const SizedBox(height: 20),

                          // SECTION 3: ACADEMIC / ADMISSION DETAILS
                          _buildSectionHeader('ACADEMIC INFORMATION', isDark),
                          const SizedBox(height: 12),
                          if (isDesktop)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildDropdownField<String>(
                                    label: 'User Type / Role *',
                                    value: _role,
                                    items: const ['STUDENT', 'FACULTY', 'ADMIN'],
                                    onChanged: (val) {
                                      if (val != null) setState(() => _role = val);
                                    },
                                    isDark: isDark,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _role == 'STUDENT'
                                      ? _buildTextField(
                                          controller: _enrollmentController,
                                          label: 'Enrollment Number *',
                                          hint: 'e.g. BTAM25O1062',
                                          validator: (v) {
                                            if (_role == 'STUDENT' && (v == null || v.trim().isEmpty)) {
                                              return 'Enrollment Number is required for students.';
                                            }
                                            return null;
                                          },
                                          isDark: isDark,
                                        )
                                      : _buildTextField(
                                          controller: _employeeIdController,
                                          label: 'Employee ID *',
                                          hint: 'e.g. EMP1001',
                                          validator: (v) {
                                            if (_role == 'FACULTY' && (v == null || v.trim().isEmpty)) {
                                              return 'Employee ID is required for faculty.';
                                            }
                                            return null;
                                          },
                                          isDark: isDark,
                                        ),
                                ),
                              ],
                            )
                          else ...[
                            _buildDropdownField<String>(
                              label: 'User Type / Role *',
                              value: _role,
                              items: const ['STUDENT', 'FACULTY', 'ADMIN'],
                              onChanged: (val) {
                                if (val != null) setState(() => _role = val);
                              },
                              isDark: isDark,
                            ),
                            const SizedBox(height: 12),
                            if (_role == 'STUDENT')
                              _buildTextField(
                                controller: _enrollmentController,
                                label: 'Enrollment Number *',
                                hint: 'e.g. BTAM25O1062',
                                validator: (v) {
                                  if (_role == 'STUDENT' && (v == null || v.trim().isEmpty)) {
                                    return 'Enrollment Number is required for students.';
                                  }
                                  return null;
                                },
                                isDark: isDark,
                              )
                            else
                              _buildTextField(
                                controller: _employeeIdController,
                                label: 'Employee ID *',
                                hint: 'e.g. EMP1001',
                                validator: (v) {
                                  if (_role == 'FACULTY' && (v == null || v.trim().isEmpty)) {
                                    return 'Employee ID is required for faculty.';
                                  }
                                  return null;
                                },
                                isDark: isDark,
                              ),
                          ],
                          const SizedBox(height: 12),
                          if (_role == 'STUDENT') ...[
                            if (isDesktop)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _buildDropdownField<String>(
                                      label: 'Course *',
                                      value: _selectedCourse ?? AdminMockData.courses.first,
                                      items: AdminMockData.courses,
                                      onChanged: (val) => setState(() => _selectedCourse = val),
                                      isDark: isDark,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildDropdownField<String>(
                                      label: 'Branch *',
                                      value: _selectedBranch ?? AdminMockData.branches.first,
                                      items: AdminMockData.branches,
                                      onChanged: (val) => setState(() => _selectedBranch = val),
                                      isDark: isDark,
                                    ),
                                  ),
                                ],
                              )
                            else ...[
                              _buildDropdownField<String>(
                                label: 'Course *',
                                value: _selectedCourse ?? AdminMockData.courses.first,
                                items: AdminMockData.courses,
                                onChanged: (val) => setState(() => _selectedCourse = val),
                                isDark: isDark,
                              ),
                              const SizedBox(height: 12),
                              _buildDropdownField<String>(
                                label: 'Branch *',
                                value: _selectedBranch ?? AdminMockData.branches.first,
                                items: AdminMockData.branches,
                                onChanged: (val) => setState(() => _selectedBranch = val),
                                isDark: isDark,
                              ),
                            ],
                            const SizedBox(height: 12),
                          ],
                          if (isDesktop)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildDropdownField<String>(
                                    label: 'Department *',
                                    value: _selectedDepartment ?? AdminMockData.departments.first,
                                    items: AdminMockData.departments,
                                    onChanged: (val) => setState(() => _selectedDepartment = val),
                                    isDark: isDark,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildDateField(
                                    label: 'Date of Admission *',
                                    value: _admissionDate,
                                    isDark: isDark,
                                    onTap: () => _pickDate(
                                      initialDate: _admissionDate ?? DateTime.now(),
                                      firstDate: DateTime(2015),
                                      lastDate: DateTime.now().add(const Duration(days: 90)),
                                      onPicked: (d) => _admissionDate = d,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else ...[
                            _buildDropdownField<String>(
                              label: 'Department *',
                              value: _selectedDepartment ?? AdminMockData.departments.first,
                              items: AdminMockData.departments,
                              onChanged: (val) => setState(() => _selectedDepartment = val),
                              isDark: isDark,
                            ),
                            const SizedBox(height: 12),
                            _buildDateField(
                              label: 'Date of Admission *',
                              value: _admissionDate,
                              isDark: isDark,
                              onTap: () => _pickDate(
                                initialDate: _admissionDate ?? DateTime.now(),
                                firstDate: DateTime(2015),
                                lastDate: DateTime.now().add(const Duration(days: 90)),
                                onPicked: (d) => _admissionDate = d,
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),

                          // SECTION 4: ACCOUNT INFORMATION
                          _buildSectionHeader('ACCOUNT INFORMATION', isDark),
                          const SizedBox(height: 12),
                          if (isDesktop)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: _emailController,
                                    label: 'Official Email Address *',
                                    hint: 'e.g. student@acadyk.edu',
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) return 'Email Address is required.';
                                      if (!v.contains('@') || !v.contains('.')) return 'Enter a valid institutional email.';
                                      return null;
                                    },
                                    isDark: isDark,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: _phoneController,
                                    label: 'Contact Number (Optional)',
                                    hint: '10-digit mobile number',
                                    keyboardType: TextInputType.phone,
                                    validator: (v) {
                                      if (v != null && v.trim().isNotEmpty) {
                                        final cleaned = v.trim().replaceAll(RegExp(r'[\s\-]'), '');
                                        if (!RegExp(r'^[6-9]\d{9}$').hasMatch(cleaned)) {
                                          return 'Enter a valid 10-digit mobile number.';
                                        }
                                      }
                                      return null;
                                    },
                                    isDark: isDark,
                                  ),
                                ),
                              ],
                            )
                          else ...[
                            _buildTextField(
                              controller: _emailController,
                              label: 'Official Email Address *',
                              hint: 'e.g. student@acadyk.edu',
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Email Address is required.';
                                if (!v.contains('@') || !v.contains('.')) return 'Enter a valid institutional email.';
                                return null;
                              },
                              isDark: isDark,
                            ),
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: _phoneController,
                              label: 'Contact Number (Optional)',
                              hint: '10-digit mobile number',
                              keyboardType: TextInputType.phone,
                              validator: (v) {
                                if (v != null && v.trim().isNotEmpty) {
                                  final cleaned = v.trim().replaceAll(RegExp(r'[\s\-]'), '');
                                  if (!RegExp(r'^[6-9]\d{9}$').hasMatch(cleaned)) {
                                    return 'Enter a valid 10-digit mobile number.';
                                  }
                                }
                                return null;
                              },
                              isDark: isDark,
                            ),
                          ],
                          if (_role == 'FACULTY') ...[
                            const SizedBox(height: 12),
                            _buildTextField(
                              controller: _designationController,
                              label: 'Faculty Designation *',
                              hint: 'e.g. Professor, Assistant Professor, HOD',
                              validator: (v) {
                                if (_role == 'FACULTY' && (v == null || v.trim().isEmpty)) {
                                  return 'Faculty Designation is required.';
                                }
                                return null;
                              },
                              isDark: isDark,
                            ),
                          ],
                          if (isEdit) ...[
                            const SizedBox(height: 12),
                            _buildDropdownField<String>(
                              label: 'Account Status *',
                              value: _status,
                              items: const ['active', 'suspended', 'banned'],
                              onChanged: (val) {
                                if (val != null) setState(() => _status = val);
                              },
                              isDark: isDark,
                            ),
                          ],

                          const SizedBox(height: 20),

                          // SECTION 5: REGISTRATION INFORMATION
                          _buildSectionHeader('REGISTRATION INFORMATION', isDark),
                          const SizedBox(height: 12),
                          _buildDateField(
                            label: 'Registration / Current Date',
                            value: _registrationDate,
                            isDark: isDark,
                            onTap: () => _pickDate(
                              initialDate: _registrationDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now().add(const Duration(days: 30)),
                              onPicked: (d) => _registrationDate = d,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

            // Modal Footer Actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: borderColor, width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                      side: BorderSide(color: borderColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.white : AppColors.brand,
                      foregroundColor: isDark ? AppColors.brand : Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    child: _isSubmitting
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: isDark ? AppColors.brand : Colors.white,
                            ),
                          )
                        : Text(
                            isEdit ? 'Update User' : 'Save User',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textSec(isDark),
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 1,
          color: AppColors.borderSubtle(isDark),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.text(isDark),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(fontSize: 13, color: AppColors.text(isDark)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 12.5, color: AppColors.textMut(isDark)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final text = value != null ? _dateFormat.format(value) : 'Select date';
    final borderColor = AppColors.border(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.text(isDark),
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor(isDark),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: value != null ? AppColors.text(isDark) : AppColors.textMut(isDark),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.text(isDark),
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          initialValue: value,
          style: TextStyle(fontSize: 13, color: AppColors.text(isDark)),
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          dropdownColor: AppColors.surfaceColor(isDark),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(item.toString()),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildErrorBanner(String message, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: isDark ? AppColors.error.withValues(alpha: 0.4) : const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
