import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../contstants/app_colors.dart';
import '../../services/admin_access_service.dart';
import '../../services/ble_admin_service.dart';
import '../../services/ble_service.dart';

class AdminConfigScreen extends StatefulWidget {
  const AdminConfigScreen({super.key});

  @override
  State<AdminConfigScreen> createState() => _AdminConfigScreenState();
}

class _AdminConfigScreenState extends State<AdminConfigScreen> {
  final BleAdminService _adminService = BleAdminService();
  final BleService _bleService = BleService();
  final AdminAccessService _sessionService = AdminAccessService();

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _selectedValues = {};

  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;

  AdminConfigSnapshot? _snapshot;
  AdminVerifyResult? _verifyResult;
  String? _errorMessage;
  bool _loading = true;
  bool _busy = false;
  bool _deviceDisconnected = false;

  String get _deviceId =>
      _bleService.connectedDevice?.remoteId.toString() ?? '';

  String get _deviceName =>
      _bleService.connectedDevice?.platformName ?? 'Unknown Device';

  String? get _sessionPassword => _sessionService.passwordFor(_deviceId);

  @override
  void initState() {
    super.initState();
    _connectionSubscription = _bleService.connectionStream.listen((state) {
      if (!mounted) {
        return;
      }

      if (state == BluetoothConnectionState.disconnected) {
        setState(() {
          _deviceDisconnected = true;
        });
      }
    });
    _loadConfig();
  }

  Future<void> _loadConfig({bool showFeedback = false}) async {
    final sessionPassword = _sessionPassword;
    if (sessionPassword == null) {
      setState(() {
        _loading = false;
        _errorMessage =
            'Admin session expired for this device. Exit and unlock again.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
      _verifyResult = null;
      _deviceDisconnected = _bleService.connectedDevice == null;
    });

    try {
      final snapshot = await _adminService.readCurrentConfig();
      _applySnapshot(snapshot);

      if (showFeedback && mounted) {
        _showMessage('Current config refreshed.');
      }
    } on BleAdminException catch (error) {
      setState(() {
        _errorMessage = error.message;
      });
    } catch (_) {
      setState(() {
        _errorMessage = 'Unable to load the current device config.';
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _applySnapshot(AdminConfigSnapshot snapshot) {
    _disposeControllers();

    for (final field in snapshot.profile.fields) {
      final value = snapshot.values[field.key] ?? '';
      if (field.kind == AdminFieldKind.select) {
        _selectedValues[field.key] = value;
      } else {
        _controllers[field.key] = TextEditingController(text: value);
      }
    }

    setState(() {
      _snapshot = snapshot;
      _errorMessage = null;
      _deviceDisconnected = _bleService.connectedDevice == null;
    });
  }

  Map<String, String>? _collectValidatedValues() {
    final snapshot = _snapshot;
    if (snapshot == null) {
      _showMessage('Current config is not loaded yet.', isError: true);
      return null;
    }

    final values = <String, String>{};

    for (final field in snapshot.profile.fields) {
      final value = field.kind == AdminFieldKind.select
          ? (_selectedValues[field.key] ?? '')
          : (_controllers[field.key]?.text.trim() ?? '');

      if (field.required && value.isEmpty) {
        _showMessage('${field.label} is required.', isError: true);
        return null;
      }

      if (value.isNotEmpty && field.kind == AdminFieldKind.integer) {
        final parsed = int.tryParse(value);
        if (parsed == null) {
          _showMessage('${field.label} must be a whole number.', isError: true);
          return null;
        }
        if (field.min != null && parsed < field.min!) {
          _showMessage(
            '${field.label} must be at least ${field.min}.',
            isError: true,
          );
          return null;
        }
        if (field.max != null && parsed > field.max!) {
          _showMessage(
            '${field.label} must be at most ${field.max}.',
            isError: true,
          );
          return null;
        }
      }

      if (value.isNotEmpty && field.kind == AdminFieldKind.decimal) {
        final parsed = double.tryParse(value);
        if (parsed == null) {
          _showMessage('${field.label} must be a decimal number.',
              isError: true);
          return null;
        }
        if (field.min != null && parsed < field.min!) {
          _showMessage(
            '${field.label} must be at least ${field.min}.',
            isError: true,
          );
          return null;
        }
        if (field.max != null && parsed > field.max!) {
          _showMessage(
            '${field.label} must be at most ${field.max}.',
            isError: true,
          );
          return null;
        }
      }

      if (field.kind == AdminFieldKind.select &&
          field.options.isNotEmpty &&
          !field.options.any((option) => option.value == value)) {
        _showMessage('Choose a valid value for ${field.label}.', isError: true);
        return null;
      }

      values[field.key] = value;
    }

    return values;
  }

  Future<void> _verifyEdits() async {
    final snapshot = _snapshot;
    final password = _sessionPassword;
    final values = _collectValidatedValues();

    if (snapshot == null || password == null || values == null) {
      return;
    }

    setState(() => _busy = true);

    try {
      final result = await _adminService.verifyConfig(
        profile: snapshot.profile,
        editedValues: values,
        password: password,
      );

      if (!mounted) {
        return;
      }

      setState(() => _verifyResult = result);
      _showMessage('Candidate config verified against the device.');
    } on BleAdminException catch (error) {
      _showMessage(error.message, isError: true);
    } catch (_) {
      _showMessage('Unable to verify the edited config.', isError: true);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _saveEdits() async {
    final snapshot = _snapshot;
    final password = _sessionPassword;
    final values = _collectValidatedValues();

    if (snapshot == null || password == null || values == null) {
      return;
    }

    setState(() => _busy = true);

    try {
      final savedSnapshot = await _adminService.saveConfig(
        profile: snapshot.profile,
        editedValues: values,
        password: password,
      );

      if (!mounted) {
        return;
      }

      _applySnapshot(savedSnapshot);
      setState(() => _verifyResult = null);
      _showMessage('NVS config saved to the device.');
    } on BleAdminException catch (error) {
      _showMessage(error.message, isError: true);
    } catch (_) {
      _showMessage('Unable to save the edited config.', isError: true);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _runFactoryReset() async {
    final password = _sessionPassword;
    if (password == null) {
      _showMessage('Admin session expired. Unlock again first.', isError: true);
      return;
    }

    final shouldReset = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Factory Reset'),
            content: const Text(
              'This will send the device factory-reset command. '
              'The device may reboot and disconnect.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Reset'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldReset) {
      return;
    }

    setState(() => _busy = true);

    try {
      await _adminService.factoryReset(password: password);
      if (!mounted) {
        return;
      }
      _showMessage(
        'Factory reset command sent. The device may disconnect while rebooting.',
      );
    } on BleAdminException catch (error) {
      _showMessage(error.message, isError: true);
    } catch (_) {
      _showMessage('Unable to send factory reset.', isError: true);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  void _logout() {
    _sessionService.clearSession();
    Navigator.of(context).pop();
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade400 : AppColors.primaryColor,
      ),
    );
  }

  void _disposeControllers() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _selectedValues.clear();
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;

    return Scaffold(
      backgroundColor: AppColors.whitebgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.whitebgColor,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: AppColors.darkGreyTextColor),
        title: Text(
          'Firmware Admin',
          style: TextStyle(
            color: AppColors.darkGreyTextColor,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _busy ? null : _logout,
            child: Text(
              'Logout',
              style: TextStyle(
                color: Colors.red.shade400,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ),
              )
            : snapshot == null
                ? _buildErrorState()
                : SingleChildScrollView(
                    padding: EdgeInsets.all(18.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderCard(snapshot),
                        SizedBox(height: 16.h),
                        if (_deviceDisconnected) _buildDisconnectedCard(),
                        if (_verifyResult != null) ...[
                          _buildVerifyCard(_verifyResult!),
                          SizedBox(height: 16.h),
                        ],
                        Text(
                          'Editable Parameters',
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGreyTextColor,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        ...snapshot.profile.fields.map(_buildFieldCard),
                        SizedBox(height: 8.h),
                        _buildActionButtons(),
                        SizedBox(height: 16.h),
                        _buildRawPayloadCard(snapshot),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: EdgeInsets.all(22.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(18.r),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Editor Unavailable',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade400,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  _errorMessage ??
                      'The app could not load a compatible config layout.',
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.45,
                    color: AppColors.darkGreyTextColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 18.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _busy ? null : () => _loadConfig(showFeedback: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 15.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: const Text('Retry Config Read'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(AdminConfigSnapshot snapshot) {
    final authenticatedAt = _sessionService.authenticatedAtFor(_deviceId);

    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        gradient: AppColors.primaryLinearGradient,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Icon(
                  Icons.memory_outlined,
                  color: AppColors.primaryColor,
                  size: 28.r,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _deviceName,
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.selectedIconColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _deviceId,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.greyTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _buildTag(snapshot.profile.title),
              _buildTag(snapshot.profile.modeLabel),
              if (authenticatedAt != null)
                _buildTag(
                  'Unlocked ${authenticatedAt.hour.toString().padLeft(2, '0')}:'
                  '${authenticatedAt.minute.toString().padLeft(2, '0')}',
                ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            snapshot.profile.description,
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.45,
              color: AppColors.darkGreyTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.darkGreyTextColor,
        ),
      ),
    );
  }

  Widget _buildDisconnectedCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.bluetooth_disabled, color: Colors.red.shade400),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'The BLE device disconnected. Reconnect before sending admin changes.',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.red.shade400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldCard(AdminFieldDefinition field) {
    final value =
        _snapshot?.values[field.key] ?? _selectedValues[field.key] ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGreyTextColor,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            field.helperText ??
                (field.unit != null
                    ? 'Current unit: ${field.unit}'
                    : 'Current value: $value'),
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.greyTextColor,
            ),
          ),
          SizedBox(height: 10.h),
          if (field.kind == AdminFieldKind.select)
            DropdownButtonFormField<String>(
              initialValue: _selectedValues[field.key],
              decoration: _fieldDecoration(field),
              items: field.options
                  .map(
                    (option) => DropdownMenuItem<String>(
                      value: option.value,
                      child: Text(option.label),
                    ),
                  )
                  .toList(),
              onChanged: _busy || _deviceDisconnected
                  ? null
                  : (nextValue) {
                      if (nextValue == null) {
                        return;
                      }
                      setState(() => _selectedValues[field.key] = nextValue);
                    },
            )
          else
            TextField(
              controller: _controllers[field.key],
              enabled: !_busy && !_deviceDisconnected,
              keyboardType: field.kind == AdminFieldKind.text
                  ? TextInputType.text
                  : const TextInputType.numberWithOptions(
                      signed: true,
                      decimal: true,
                    ),
              decoration: _fieldDecoration(field),
            ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration(AdminFieldDefinition field) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade50,
      hintText: field.unit != null ? 'Value in ${field.unit}' : 'Enter value',
      suffixText: field.unit,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: AppColors.primaryColor, width: 1.4),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _busy ? null : () => _loadConfig(showFeedback: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 15.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
            icon: const Icon(Icons.refresh),
            label: const Text('Read Current Config'),
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed:
                _busy || _deviceDisconnected ? null : () => _verifyEdits(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade400,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 15.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
            icon: _busy
                ? SizedBox(
                    width: 16.r,
                    height: 16.r,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.fact_check_outlined),
            label: const Text('Verify Edited Values'),
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _busy || _deviceDisconnected ? null : () => _saveEdits(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 15.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save To Device NVS'),
          ),
        ),
        SizedBox(height: 10.h),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed:
                _busy || _deviceDisconnected ? null : () => _runFactoryReset(),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade400,
              side: BorderSide(color: Colors.red.shade200),
              padding: EdgeInsets.symmetric(vertical: 15.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
            icon: const Icon(Icons.restart_alt_outlined),
            label: const Text('Factory Reset Device'),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyCard(AdminVerifyResult result) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verify Result',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade700,
            ),
          ),
          SizedBox(height: 10.h),
          ...result.current.profile.fields.map((field) {
            final currentValue = result.current.values[field.key] ?? '';
            final newValue = result.candidate.values[field.key] ?? '';
            final changed = currentValue != newValue;

            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      field.label,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGreyTextColor,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      currentValue,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.greyTextColor,
                      ),
                    ),
                  ),
                  Icon(
                    changed ? Icons.arrow_forward : Icons.remove,
                    size: 16.r,
                    color: changed
                        ? Colors.orange.shade700
                        : AppColors.lightGreyTextColor,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      newValue,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: changed ? FontWeight.w700 : FontWeight.w500,
                        color: changed
                            ? Colors.orange.shade700
                            : AppColors.greyTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRawPayloadCard(AdminConfigSnapshot snapshot) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Raw Device Payload',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGreyTextColor,
            ),
          ),
          SizedBox(height: 8.h),
          SelectableText(
            snapshot.rawLine,
            style: TextStyle(
              fontSize: 12.sp,
              fontFamily: 'monospace',
              color: AppColors.greyTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
