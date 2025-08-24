import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase/supabase.dart';
import '../../config/supabase_config.dart';

class CodeVerificationScreen extends StatefulWidget {
  final String email;

  const CodeVerificationScreen({super.key, required this.email});

  @override
  State<CodeVerificationScreen> createState() => _CodeVerificationScreenState();
}

class _CodeVerificationScreenState extends State<CodeVerificationScreen> {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isLoading = false;

  final _supabase = SupabaseClient(
    SupabaseConfig.supabaseUrl,
    SupabaseConfig.supabaseAnonKey,
    authOptions: const AuthClientOptions(authFlowType: AuthFlowType.implicit),
  );

  @override
  void dispose() {
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String get _code => _codeController.text.trim();

  bool get _isCodeComplete => _code.length == 6;

  Future<void> _verifyCode() async {
    if (!_isCodeComplete) return;

    setState(() {
      _isLoading = true;
    });

    try {
      print('🔢 Проверяем код: $_code для email: ${widget.email}');

      final response = await _supabase.auth.verifyOTP(
        email: widget.email,
        token: _code,
        type: OtpType.email,
      );

      print('📝 Ответ от Supabase: ${response.user?.id}');

      if (response.user != null && mounted) {
        print('✅ Авторизация успешна! User ID: ${response.user!.id}');
        // Успешная авторизация - переходим на главный экран
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } on AuthException catch (error) {
      print('🔐 AuthException при проверке кода: ${error.message}');
      print('🔐 AuthException details: $error');
      if (mounted) {
        _showErrorSnackBar(error.message);
        _clearCode();
      }
    } catch (error) {
      print('❌ Общая ошибка при проверке кода: $error');
      print('❌ Тип ошибки: ${error.runtimeType}');
      if (mounted) {
        _showErrorSnackBar('Произошла ошибка: $error');
        _clearCode();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearCode() {
    _codeController.clear();
    _focusNode.requestFocus();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _resendCode() async {
    try {
      await _supabase.auth.signInWithOtp(
        email: widget.email,
        shouldCreateUser: true,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Код отправлен повторно!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        _showErrorSnackBar('Ошибка отправки: $error');
      }
    }
  }

  Widget _buildCodeInput() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: _code.isNotEmpty ? Colors.orange : Colors.grey.shade300,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: TextField(
        controller: _codeController,
        focusNode: _focusNode,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.orange,
          letterSpacing: 8,
        ),
        keyboardType: TextInputType.number,
        maxLength: 6,
        enabled: !_isLoading,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
          hintText: '000000',
          hintStyle: TextStyle(color: Colors.grey, letterSpacing: 8),
          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        ),
        onChanged: (value) {
          setState(() {});
          // Автоматическая проверка когда код введен полностью
          if (value.length == 6) {
            _focusNode.unfocus();
            _verifyCode();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Заголовок
              const Icon(Icons.email_outlined, size: 64, color: Colors.orange),
              const SizedBox(height: 24),
              Text(
                'Введите код',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Мы отправили 6-значный код на',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                widget.email,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Поле ввода кода
              _buildCodeInput(),
              const SizedBox(height: 32),

              // Кнопка подтверждения
              ElevatedButton(
                onPressed: (_isCodeComplete && !_isLoading)
                    ? _verifyCode
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Подтвердить',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              const SizedBox(height: 24),

              // Кнопка повторной отправки
              TextButton(
                onPressed: _isLoading ? null : _resendCode,
                child: Text(
                  'Не получили код? Отправить повторно',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),

              const Spacer(),

              // Подсказка
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade600,
                      size: 20,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Проверьте папку "Спам" если письмо не пришло.\n'
                      'Код действителен в течение 1 часа.',
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontSize: 12,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
