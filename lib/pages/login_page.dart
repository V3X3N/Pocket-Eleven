import 'package:flutter/material.dart';
import 'package:pocket_eleven/firebase/auth_functions.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = true;
  late Image _loadingImage;
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool login = false;

  late String fullname;

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
                              key: const ValueKey('fullname'),
                              decoration: const InputDecoration(
                                hintText: 'Enter Full Name',
                                filled: true,
                                fillColor: Colors.white70,
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please Enter Full Name';
                                } else {
                                  return null;
                                }
                              },
                              onSaved: (value) {
                                setState(() {
                                  fullname = value!;
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
                        height: 30,
                      ),
                      SizedBox(
                        height: 40,
                        width: 100,
                        child: MaterialButton(
                            color: Colors.blueAccent,
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                login
                                    ? AuthServices.signinUser(
                                        email, password, context)
                                    : AuthServices.signupUser(
                                        email, password, fullname, context);
                              }
                            },
                            child: Text(
                                style: const TextStyle(color: Colors.white),
                                login ? 'Login' : 'Signup')),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextButton(
                          onPressed: () {
                            setState(() {
                              login = !login;
                            });
                          },
                          child: Text(login
                              ? "Don't have an account? Signup"
                              : "Already have an account? Login"))
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
