import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmanager/src/routes/app_routes.dart';
import 'package:taskmanager/src/utils/color_constants.dart';
import '../../view_models/auth_view_model.dart';
import '../../utils/app_theme.dart';
import '../../utils/consts.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_title_widget.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        onSignupTap: () {
          Navigator.pushNamed(context, AppRoutes.signup);
        },
      ),
      body: Container(
        color: ColorConstants.background,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ScreenTitle(title: 'Login'),
                const SizedBox(height: 16),
                LoginForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginForm extends ConsumerWidget {
  LoginForm({super.key});

  // Persistent controllers
  final _loginFormKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    return Container(
      width: MediaQuery.of(context).size.width * 0.40,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(width: 2, color: ColorConstants.primary),
      ),
      child: Form(
        key: _loginFormKey, // Assign form key here
        child: Column(
          children: [
            CustomForm(
              hintText: "Email",
              height: MediaQuery.sizeOf(context).height * 0.1,
              validationRegExp: EMAIL_VALIDATION_REGEX,
              controller: emailController,
            ),
            CustomForm(
              hintText: "Password",
              height: MediaQuery.sizeOf(context).height * 0.1,
              validationRegExp: PASSWORD_VALIDATION_REGEX,
              obscureText: true,
              controller: passwordController,
            ),
            const SizedBox(height: 24),
            authState.isLoading
                ? const CircularProgressIndicator()
                : ActionButton(
                    label: 'Login',
                    backgroundColor: ColorConstants.primary,
                    onPressed: () async {
                      print("email : ${emailController.text}");
                      print("pass : ${passwordController.text}");
                      if (_loginFormKey.currentState?.validate() ?? false) {
                        final result = await authNotifier.loginUser(
                          emailController.text,
                          passwordController.text,
                        );
                        if (result) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("User Logged in Successfully!")),
                          );
                          Navigator.pushNamed(context, AppRoutes.home);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    authState.errorMessage ?? "Login Failed")),
                          );
                        }
                      }
                    },
                  ),
            const SizedBox(height: 16),
            const Divider(thickness: 1, color: Colors.grey),
            _buildSignupPrompt(context),
            const SizedBox(height: 16),
            ActionButton(
              label: 'Continue with Google',
              backgroundColor: ColorConstants.primary,
              onPressed: () async {
                final result = await authNotifier.googleSigning();
                if (result) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("User Logged in Successfully!")),
                  );
                  Navigator.pushNamed(context, AppRoutes.home);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(authState.errorMessage ?? "Login Failed")),
                  );
                }
              },
              hasFullWidth: false,
            ),
            if (authState.errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                authState.errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Widget _buildSignupPrompt(BuildContext context) {
  return SizedBox(
    width: double.infinity,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account?",
          style: AppTheme.bodyBold,
        ),
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.signup);
          },
          child: const Text(
            ' Signup',
            style: TextStyle(
              color: ColorConstants.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}
