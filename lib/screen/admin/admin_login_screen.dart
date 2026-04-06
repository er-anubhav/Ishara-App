import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../contstants/app_colors.dart';
import '../../services/admin_access_service.dart';
import '../../services/ble_admin_service.dart';
import '../../services/ble_service.dart';
import 'admin_config_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final BleAdminService _adminService = BleAdminService();
  final BleService _bleService = BleService();
  final AdminAccessService _sessionService = AdminAccessService();
  final TextEditingController _passwordController = TextEditingController();

  bool _submitting = false;
  bool _obscurePassword = true;

  String get _deviceName =>
      _bleService.connectedDevice?.platformName ?? 'No device connected';

  String get _deviceId =>
      _bleService.connectedDevice?.remoteId.toString() ?? '-';

  Future<void> _login() async {
    final connectedDevice = _bleService.connectedDevice;
    if (connectedDevice == null) {
      _showMessage(
        'Connect a BLE device before using the admin login.',
        isError: true,
      );
      return;
    }

    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      _showMessage('Enter the admin password.', isError: true);
      return;
    }

    setState(() => _submitting = true);

    try {
      await _adminService.unlock(password);
      _sessionService.openSession(
        deviceId: connectedDevice.remoteId.toString(),
        password: password,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const AdminConfigScreen(),
        ),
      );
    } on BleAdminException catch (error) {
      _showMessage(error.message, isError: true);
    } catch (_) {
      _showMessage('Unable to authenticate with the connected device.',
          isError: true);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade400 : AppColors.primaryColor,
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = _bleService.connectedDevice != null;

    return Scaffold(
      backgroundColor: AppColors.whitebgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.whitebgColor,
        iconTheme: IconThemeData(color: AppColors.darkGreyTextColor),
        title: Text(
          'Admin Login',
          style: TextStyle(
            color: AppColors.darkGreyTextColor,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(18.r),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryLinearGradient,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: AppColors.primaryColor.withValues(alpha: 0.22),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hidden Admin Access',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.selectedIconColor,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'This password is verified directly against the connected '
                      'device over BLE. It is kept only in memory for the '
                      'current admin session.',
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
              _buildDeviceCard(isConnected),
              SizedBox(height: 18.h),
              Text(
                'Admin Password',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGreyTextColor,
                ),
              ),
              SizedBox(height: 10.h),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                enabled: !_submitting && isConnected,
                decoration: InputDecoration(
                  hintText: 'Enter device admin password',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.greyTextColor,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                isConnected
                    ? 'Connected device: $_deviceName'
                    : 'No BLE device is connected yet.',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isConnected
                      ? AppColors.greyTextColor
                      : Colors.red.shade400,
                ),
              ),
              SizedBox(height: 22.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting || !isConnected ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: _submitting
                      ? SizedBox(
                          width: 20.r,
                          height: 20.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Unlock Admin Editor',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
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

  Widget _buildDeviceCard(bool isConnected) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isConnected
              ? AppColors.primaryColor.withValues(alpha: 0.28)
              : Colors.red.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: isConnected
                  ? AppColors.primaryColor.withValues(alpha: 0.14)
                  : Colors.red.shade50,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              isConnected
                  ? Icons.admin_panel_settings_outlined
                  : Icons.bluetooth_disabled,
              color: isConnected ? AppColors.primaryColor : Colors.red.shade400,
              size: 28.r,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConnected ? _deviceName : 'Device Required',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGreyTextColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  isConnected
                      ? _deviceId
                      : 'Connect from Device Connections first',
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
    );
  }
}
