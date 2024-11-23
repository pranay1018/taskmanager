import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmanager/src/view_models/auth_view_model.dart';
import '../../routes/app_routes.dart';
import '../../utils/app_theme.dart';
import '../../utils/color_constants.dart';
import '../../utils/consts.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_title_widget.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});



  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: CustomAppBar(
        onLoginTap: () {
          Navigator.pushNamed(context, AppRoutes.login);
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
                const ScreenTitle(title: 'Signup'),
                const SizedBox(height: 16),
                SignupForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SignupForm extends ConsumerWidget {
  SignupForm({super.key});

  final _registerFormKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

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
        key: _registerFormKey,
        child: Column(
          children: [
            CustomForm(
              hintText: "First Name",
              height: MediaQuery.sizeOf(context).height * 0.1,
              validationRegExp: NAME_VALIDATION_REGEX,
              controller: firstNameController,
            ),
            CustomForm(
              hintText: "Last Name",
              height: MediaQuery.sizeOf(context).height * 0.1,
              validationRegExp: NAME_VALIDATION_REGEX,
              controller: lastNameController,
            ),
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
            CustomForm(
              hintText: "Confirm Password",
              height: MediaQuery.sizeOf(context).height * 0.1,
              validationRegExp: PASSWORD_VALIDATION_REGEX,
              obscureText: true,
              controller: confirmPasswordController,
            ),
            const SizedBox(height: 24),
            authState.isLoading
                ? const CircularProgressIndicator()
                : ActionButton(
                    label: 'Signup',
                    backgroundColor: ColorConstants.primary,
                    onPressed: () async {
                      if (_registerFormKey.currentState?.validate() ?? false) {
                        _registerFormKey.currentState?.save();
                        if (passwordController.text !=
                            confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Passwords do not match!")),
                          );
                          return;
                        }

                        final result = await authNotifier.signupUser(
                            emailController.text, passwordController.text,firstNameController.text,lastNameController.text);

                        if (result) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("User Registered Successfully!")),
                          );
                          Navigator.pushReplacementNamed(
                              context, AppRoutes.home);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    authState.errorMessage ?? "Signup Failed")),
                          );
                        }
                      }
                    },
                  ),
            const SizedBox(height: 16),
            const Divider(thickness: 1, color: Colors.grey),
            _buildLoginPrompt(context),
            const SizedBox(height: 16),
            ActionButton(
              label: 'Continue with Google',
              backgroundColor: ColorConstants.primary,
              onPressed: () async {
                final result = await authNotifier.googleSigning();
                if (result) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("User Sign up Successful!")),
                  );
                  Navigator.pushNamed(context, AppRoutes.home);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(authState.errorMessage ?? " Sign up  Failed")),
                  );
                }
              },

              hasFullWidth: false,
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildLoginPrompt(BuildContext context) {
  return SizedBox(
    width: double.infinity,
    // Makes the button take the full width of its parent
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account?",
          style: AppTheme.bodyBold,
        ),
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.login);
          },
          child: const Text(
            ' Login',
            style: TextStyle(
                color: ColorConstants.primary,
                fontSize: 14,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}
