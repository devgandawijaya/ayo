import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/api_constants.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _appIdController = TextEditingController(text: ApiConstants.defaultAppId);

  bool _obscurePassword = true;
  bool _showAdvancedSettings = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _appIdController.dispose();
    super.dispose();
  }

  void _fillDemoCredentials() {
    setState(() {
      _emailController.text = 'tatang@pkp.co.id';
      _passwordController.text = 'pkp12345678';
      _appIdController.text = '3507398578724';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kredensial demo berhasil diisi'),
        backgroundColor: AppTheme.accentColor,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleLogin() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      email: _emailController.text,
      password: _passwordController.text,
      appId: _appIdController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      final error = authProvider.errorMessage ?? 'Login gagal. Coba lagi.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppTheme.dangerColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Logo & Branding
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.lock_person_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        'PT. PKP',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Center(
                      child: Text(
                        'Prawathiya Karsa Pradiptha',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Card Form Container
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Masuk Akun',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Masukkan email dan password untuk melanjutkan.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Error Banner if present
                          if (auth.errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: AppTheme.dangerColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppTheme.dangerColor.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: AppTheme.dangerColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      auth.errorMessage!,
                                      style: const TextStyle(
                                        color: AppTheme.dangerColor,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => auth.clearError(),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: AppTheme.dangerColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Email Field
                          CustomTextField(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'tatang@pkp.co.id',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email wajib diisi';
                              }
                              if (!value.contains('@') || !value.contains('.')) {
                                return 'Format email tidak valid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          CustomTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: '••••••••',
                            prefixIcon: Icons.lock_outline,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppTheme.textSecondary,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password wajib diisi';
                              }
                              if (value.length < 6) {
                                return 'Password minimal 6 karakter';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Expandable App ID Setting
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showAdvancedSettings = !_showAdvancedSettings;
                              });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  _showAdvancedSettings
                                      ? Icons.keyboard_arrow_down
                                      : Icons.keyboard_arrow_right,
                                  size: 18,
                                  color: AppTheme.primaryLight,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Pengaturan App ID (Lanjutan)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.primaryLight,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_showAdvancedSettings) ...[
                            const SizedBox(height: 12),
                            CustomTextField(
                              controller: _appIdController,
                              label: 'Application ID',
                              hint: '3507398578724',
                              prefixIcon: Icons.fingerprint,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'App ID tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Login Button
                          CustomButton(
                            text: 'Masuk',
                            icon: Icons.login,
                            isLoading: auth.isLoading,
                            onPressed: _handleLogin,
                          ),

                          const SizedBox(height: 16),

                          // Quick Fill Demo Credentials
                          OutlinedButton.icon(
                            onPressed: auth.isLoading ? null : _fillDemoCredentials,
                            icon: const Icon(Icons.flash_on, size: 18),
                            label: const Text(
                              'Gunakan Kredensial Demo',
                              style: TextStyle(fontSize: 13),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryLight,
                              side: const BorderSide(color: AppTheme.primaryLight),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Center(
                      child: Text(
                        '© 2026 PT. PKP. All rights reserved.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
