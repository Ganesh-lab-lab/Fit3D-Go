import 'package:flutter/material.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/state/roomfit_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/glass_button.dart';
import '../../../core/theme/glass_card.dart';
import '../../home/presentation/home_screen.dart';

class AuthScreen extends StatefulWidget {
  final RoomFitState state;

  const AuthScreen({super.key, required this.state});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isSignUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    setState(() => _errorMessage = null);

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Please enter a valid email address');
      return;
    }

    if (password.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters');
      return;
    }

    if (_isSignUp && password != confirmPassword) {
      setState(() => _errorMessage = 'Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isSignUp) {
        final res = await SupabaseService.instance.signUp(
          email: email,
          password: password,
        );

        if (!mounted) return;

        if (res.session == null && res.user != null) {
          // Email confirmation is required by Supabase project settings
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF1E293B),
              content: Text(
                'Registration successful! Please check your email to confirm your account.',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.primaryCyan),
              ),
              duration: const Duration(seconds: 5),
            ),
          );
          setState(() {
            _isSignUp = false;
            _passwordController.clear();
            _confirmPasswordController.clear();
          });
        } else {
          // Logged in immediately
          await widget.state.loadFromSupabase();
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => HomeScreen(state: widget.state)),
          );
        }
      } else {
        await SupabaseService.instance.signIn(
          email: email,
          password: password,
        );

        if (!mounted) return;

        await widget.state.loadFromSupabase();
        if (!mounted) return;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => HomeScreen(state: widget.state)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      String msg = e.toString();
      if (msg.contains('Exception:')) {
        msg = msg.split('Exception:').last.trim();
      } else if (msg.contains('AuthApiException:')) {
        msg = msg.split('AuthApiException:').last.trim();
      }
      setState(() => _errorMessage = msg);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background ambient cyan glow orb
          Positioned(
            top: -100,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x3300F0FF),
                    Color(0x0000F0FF),
                  ],
                ),
              ),
            ),
          ),
          // Background ambient purple glow orb
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 340,
              height: 340,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x287000FF),
                    Color(0x007000FF),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // App Logo & Branding
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.cyanShadow,
                              blurRadius: 24,
                              spreadRadius: -4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.view_in_ar_rounded,
                          size: 44,
                          color: Color(0xFF001524),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        'RoomFit 3D',
                        style: AppTypography.displayMedium.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Text(
                        'OriginOS Spatial Fit Engine',
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 12,
                          color: AppColors.primaryCyan,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Glass Card Container
                    GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Tab switcher (Sign In vs Sign Up)
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0x1FFFFFFF),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isSignUp = false;
                                        _errorMessage = null;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: !_isSignUp
                                            ? AppColors.primaryCyan.withOpacity(0.2)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                        border: !_isSignUp
                                            ? Border.all(color: AppColors.primaryCyan.withOpacity(0.5))
                                            : null,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Sign In',
                                        style: AppTypography.titleMedium.copyWith(
                                          fontSize: 14,
                                          fontWeight: !_isSignUp ? FontWeight.w700 : FontWeight.w500,
                                          color: !_isSignUp ? AppColors.primaryCyan : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isSignUp = true;
                                        _errorMessage = null;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      decoration: BoxDecoration(
                                        color: _isSignUp
                                            ? AppColors.primaryCyan.withOpacity(0.2)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                        border: _isSignUp
                                            ? Border.all(color: AppColors.primaryCyan.withOpacity(0.5))
                                            : null,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Create Account',
                                        style: AppTypography.titleMedium.copyWith(
                                          fontSize: 14,
                                          fontWeight: _isSignUp ? FontWeight.w700 : FontWeight.w500,
                                          color: _isSignUp ? AppColors.primaryCyan : AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Error Message Banner
                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0x2BFF3B30),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0x66FF3B30)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline_rounded,
                                      size: 18, color: Color(0xFFFF5252)),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: const Color(0xFFFF5252),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                          ],

                          // Email Field
                          Text('Email Address',
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              )),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _emailController,
                            hintText: 'alex@example.com',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 18),

                          // Password Field
                          Text('Password',
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              )),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _passwordController,
                            hintText: '••••••••',
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.textTertiary,
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),

                          // Confirm Password Field (if sign-up)
                          if (_isSignUp) ...[
                            const SizedBox(height: 18),
                            Text('Confirm Password',
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                )),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _confirmPasswordController,
                              hintText: '••••••••',
                              prefixIcon: Icons.lock_reset_rounded,
                              obscureText: _obscureConfirmPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textTertiary,
                                  size: 20,
                                ),
                                onPressed: () => setState(() =>
                                    _obscureConfirmPassword = !_obscureConfirmPassword),
                              ),
                            ),
                          ],

                          const SizedBox(height: 28),

                          // Submit GlassButton
                          GlassButton(
                            label: _isSignUp ? 'Create Account' : 'Sign In',
                            icon: _isSignUp
                                ? Icons.person_add_alt_1_rounded
                                : Icons.login_rounded,
                            isLoading: _isLoading,
                            onPressed: _isLoading ? null : _submit,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
        cursorColor: AppColors.primaryCyan,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTypography.bodyLarge.copyWith(color: AppColors.textTertiary),
          prefixIcon: Icon(prefixIcon, color: AppColors.textTertiary, size: 20),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
