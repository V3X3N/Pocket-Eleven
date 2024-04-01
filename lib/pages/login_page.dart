import 'package:flutter/material.dart';
import 'package:pocket_eleven/auth_functions.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocket_eleven/pages/home_page.dart';
import 'package:pocket_eleven/pages/login_page.dart';
import 'package:pocket_eleven/firebase_options.dart';
import 'package:pocket_eleven/image_loader.dart';

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
      appBar: AppBar(
        elevation: 0,
        title: Text('Login'),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ======== Full Name ========
              login
                  ? Container()
                  : TextFormField(
                      key: const ValueKey('fullname'),
                      decoration: const InputDecoration(
                        hintText: 'Enter Full Name',
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

              // ======== Email ========
              TextFormField(
                key: ValueKey('email'),
                decoration: InputDecoration(
                  hintText: 'Enter Email',
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
              // ======== Password ========
              TextFormField(
                key: ValueKey('password'),
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Enter Password',
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
              SizedBox(
                height: 30,
              ),
              Container(
                height: 55,
                width: double.infinity,
                child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        login
                            ? AuthServices.signinUser(email, password, context)
                            : AuthServices.signupUser(
                                email, password, fullname, context);
                      }
                    },
                    child: Text(login ? 'Login' : 'Signup')),
              ),
              SizedBox(
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
    );
  }
}
