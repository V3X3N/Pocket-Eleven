import 'package:flutter/material.dart';
import 'package:pocket_eleven/firebase/auth_functions.dart';
import 'package:pocket_eleven/pages/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = true;
  late Image _loadingImage;
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String confirmPassword = '';
  String clubName = '';
  bool login = false;

  @override
  void initState() {
    super.initState();
    _loadLoadingImage();
  }

  void _loadLoadingImage() {
    _loadingImage = Image.asset('assets/background/loading_bg.png');

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: _loadingImage.image,
                  fit: BoxFit.cover,
                ),
              ),
              child: Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      login
                          ? Container()
                          : TextFormField(
                              key: const ValueKey('clubName'),
                              decoration: const InputDecoration(
                                hintText: 'Enter Club Name',
                                filled: true,
                                fillColor: Colors.white70,
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please Enter Club Name';
                                } else {
                                  return null;
                                }
                              },
                              onSaved: (value) {
                                setState(() {
                                  clubName = value!;
                                });
                              },
                            ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        key: const ValueKey('email'),
                        decoration: const InputDecoration(
                          hintText: 'Enter Email',
                          filled: true,
                          fillColor: Colors.white70,
                        ),
                        validator: (value) {
                          if (value!.isEmpty || !value.contains('@')) {
                            return 'Please Enter valid Email';
                          } else {
                            return null;
                          }
                        },
                        onSaved: (value) {
                          setState(() {
                            email = value!;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        key: const ValueKey('password'),
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: 'Enter Password',
                          filled: true,
                          fillColor: Colors.white70,
                        ),
                        validator: (value) {
                          password = value.toString();
                          if (value!.length < 6) {
                            return 'Please Enter Password of min length 6';
                          } else {
                            return null;
                          }
                        },
                        onSaved: (value) {
                          setState(() {
                            password = value!;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        key: const ValueKey('confirmPassword'),
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: 'Confirm Password',
                          filled: true,
                          fillColor: Colors.white70,
                        ),
                        validator: (value) {
                          confirmPassword = value.toString();
                          if (confirmPassword != password) {
                            return "Passwords don't match";
                          } else {
                            return null;
                          }
                        },
                        onSaved: (value) {
                          setState(() {
                            confirmPassword = value!;
                          });
                        },
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            login = !login;
                          });
                        },
                        child: Text(login
                            ? "Don't have an account? Signup"
                            : "Already have an account? Login"),
                      ),
                      SizedBox(
                        height: 40,
                        width: 100,
                        child: MaterialButton(
                          color: Colors.blueAccent,
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              if (password == confirmPassword) {
                                try {
                                  login
                                      ? await AuthServices.signinUser(
                                          email, password, context)
                                      : await AuthServices.signupUser(
                                          email, password, clubName, context);
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const HomePage(),
                                    ),
                                    (route) => false,
                                  );
                                } catch (error) {
                                  print('Error: $error');
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Passwords don't match"),
                                  ),
                                );
                              }
                            }
                          },
                          child: Text(
                            login ? 'Login' : 'Signup',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
