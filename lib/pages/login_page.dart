import 'package:flutter/material.dart';
import 'package:pocket_eleven/firebase/auth_functions.dart';
import 'package:pocket_eleven/pages/club_create_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  late Image _loadingImage;
  final _formKey = GlobalKey<FormState>();
  String managerName = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  bool login = false;
  String errorMessage = '';

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

  Future<bool> isEmailRegistered(String email) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    final List<DocumentSnapshot> documents = result.docs;
    return documents.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
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
                            key: const ValueKey('managerName'),
                            decoration: const InputDecoration(
                              hintText: "What's your name Manager?",
                              filled: true,
                              fillColor: Colors.white70,
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please tell us your name";
                              } else {
                                return null;
                              }
                            },
                            onSaved: (value) {
                              setState(() {
                                managerName = value!;
                              });
                            },
                          ),
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 10),
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
                    Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
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
                        onPressed: _isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  if (password == confirmPassword) {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    try {
                                      if (!login) {
                                        bool isRegistered =
                                            await isEmailRegistered(email);
                                        if (isRegistered) {
                                          setState(() {
                                            errorMessage =
                                                'This email is already registered';
                                            _isLoading = false;
                                          });
                                          return;
                                        }
                                      }
                                      login
                                          ? await AuthServices.signinUser(
                                              email, password, context)
                                          : await AuthServices.signupUser(email,
                                              password, managerName, context);
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ClubCreatePage(),
                                        ),
                                        (route) => false,
                                      );
                                    } catch (error) {
                                      print('Error: $error');
                                    } finally {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Passwords don't match"),
                                      ),
                                    );
                                  }
                                }
                              },
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : Text(
                                login ? 'Login' : 'Signup',
                                style: const TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
