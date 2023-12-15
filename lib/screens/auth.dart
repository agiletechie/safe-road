import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:road_safety/provider/auth_notifier.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _dialogController;
  bool isSignUp = true;
  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _dialogController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _dialogController.dispose();
    super.dispose();
  }

  Future<void> showNameDialog(
      BuildContext context, AuthNotifier authNotifier) async {
    print('Hahha:D');
    final name = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Enter you name'),
          content: TextField(
            autofocus: true,
            controller: _dialogController,
          ),
          actions: [
            TextButton(
                onPressed: () async {
                  if (_dialogController.text.isNotEmpty) {
                    Navigator.of(context).pop(_dialogController.text);
                  }
                },
                child: Text('Submit'))
          ],
        );
      },
    );

    await authNotifier.updateUserNameAndWriteToDoc(name!);
  }

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.orange.shade100,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SvgPicture.asset(
                    isSignUp ? 'assets/sign_up.svg' : 'assets/login.svg',
                    height: 240),
                SizedBox(height: 32),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                      label: Text('Email'),
                      isDense: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.white))),
                ),
                SizedBox(height: 24),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                      isDense: true,
                      label: Text('Password'),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.white))),
                ),
                SizedBox(height: 32),
                Consumer<AuthNotifier>(
                  builder: (context, AuthNotifier authNotifier, child) {
                    if (authNotifier.errorMessage != null) {
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(authNotifier.errorMessage!)));
                      });
                    }
                    if (authNotifier.user != null &&
                        authNotifier.displayName == null) {
                      WidgetsBinding.instance.addPostFrameCallback(
                          (timeStamp) => showNameDialog(context, authNotifier));
                    }
                    return authNotifier.isLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () async {
                              if (_emailController.text.isNotEmpty &&
                                  _passwordController.text.isNotEmpty) {
                                isSignUp
                                    ? authNotifier.createNewUser(
                                        _emailController.text,
                                        _passwordController.text)
                                    : authNotifier.signInUser(
                                        _emailController.text,
                                        _passwordController.text);
                              }
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 64.0),
                              child: Text(isSignUp ? 'Sign Up' : 'Sign In'),
                            ),
                          );
                  },
                ),
                SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (isSignUp) Text('Already have an account ?'),
                    if (!isSignUp) Text('Not have an account ?'),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isSignUp = !isSignUp;
                        });
                      },
                      child: Text(isSignUp ? 'SignIn' : 'SignUp',
                          style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
