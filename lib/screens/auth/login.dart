import 'dart:developer';

import 'package:expense_tracker/core/bloc/supabase_cubit/supabase_cubit.dart';
import 'package:expense_tracker/core/constants/supabase.dart';
import 'package:expense_tracker/core/widgets/auth_text_field.dart';
import 'package:expense_tracker/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginAndSignup extends StatefulWidget {
  const LoginAndSignup({super.key, this.isSignup = false});
  final bool isSignup;

  @override
  State<LoginAndSignup> createState() => _LoginAndSignupState();
}

class _LoginAndSignupState extends State<LoginAndSignup> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController =
      TextEditingController();

  final ValueNotifier<String?> _error = ValueNotifier<String?>(null);
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ListView(
                clipBehavior: Clip.none,
                shrinkWrap: true,
                children: [
                  Form(
                    key: _formKey,
                    child: ValueListenableBuilder(
                      valueListenable: _error,
                      builder: (context, errorValue, child) {
                        return Column(
                          children: [
                            Text(
                              'Welcome !',
                              style: TextStyle(
                                fontSize: 32.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            AuthTextField(
                              controller: _emailController,
                              icon: Icons.mail_outline,
                              hintText: 'E-Mail',
                            ),

                            10.verticalSpace,
                            AuthTextField(
                              controller: _passwordController,
                              errorText: widget.isSignup ? null : errorValue,
                              hintText: 'Password',
                              icon: Icons.lock_outline,
                            ),
                            if (widget.isSignup) ...[
                              10.verticalSpace,
                              AuthTextField(
                                controller: _passwordConfirmationController,
                                icon: Icons.check,
                                errorText: widget.isSignup ? errorValue : null,

                                hintText: 'Password Confirmation',
                                validator: (value) {
                                  if (value != _passwordController.text) {
                                    return "Passwords Doesn't Match";
                                  }
                                },
                              ),
                            ],
                            10.verticalSpace,
                            ValueListenableBuilder(
                              valueListenable: _isLoading,
                              builder: (context, isLoading, child) {
                                return CustomButton(
                                  text: 'Submit',
                                  isLoading: isLoading,
                                  onTap: () async {
                                    if (_formKey.currentState!.validate()) {
                                      try {
                                        _isLoading.value = true;
                                        if (widget.isSignup == true) {
                                          final AuthResponse userCredential =
                                              await supabase.auth.signUp(
                                                email: _emailController.text
                                                    .trim(),
                                                password: _passwordController
                                                    .text
                                                    .trim(),
                                              );
                                          await supabase.from('users').upsert({
                                            "balance": 0,
                                            "email": userCredential.user?.email,
                                            "id":
                                                userCredential.session?.user.id,
                                          });
                                          log(userId.toString());
                                        } else {
                                          await supabase.auth
                                              .signInWithPassword(
                                                email: _emailController.text
                                                    .trim(),
                                                password: _passwordController
                                                    .text
                                                    .trim(),
                                              );
                                          log(userId.toString());
                                        }
                                        if (context.mounted) {
                                          context.push('/home');
                                        }
                                      } on SupabaseError catch (e) {
                                        _error.value = e.message;
                                      } finally {
                                        _isLoading.value = false;
                                      }
                                    }
                                  },
                                );
                              },
                            ),
                            10.verticalSpace,
                            if (widget.isSignup) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Already Have An Account? ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      context.go(
                                        '/loginAndSignup',
                                        extra: {'isSignup': false},
                                      );
                                    },
                                    child: Text(
                                      'Login',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ] else
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Don't Have An Account? ",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      context.go(
                                        '/loginAndSignup',
                                        extra: {'isSignup': true},
                                      );
                                    },
                                    child: Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
