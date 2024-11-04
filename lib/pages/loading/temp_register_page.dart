import 'package:flutter/material.dart';
import 'package:pocket_eleven/components/option_button.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/firebase/auth_functions.dart';
import 'package:pocket_eleven/pages/loading/temp_login_page.dart';
import 'package:pocket_eleven/pages/home_page.dart';

class TempRegisterPage extends StatefulWidget {
  const TempRegisterPage({super.key});

  @override
  State<TempRegisterPage> createState() => _TempRegisterPageState();
}

class _TempRegisterPageState extends State<TempRegisterPage> {
  TextEditingController clubnameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _page(),
      ),
    );
  }

  Widget _page() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _gameText(),
            const SizedBox(height: 50),
            _inputField("Clubname", clubnameController),
            const SizedBox(height: 20),
            _inputField("Username", usernameController),
            const SizedBox(height: 20),
            _inputField("Email", emailController),
            const SizedBox(height: 20),
            _inputField("Password", passwordController, isPassword: true),
            const SizedBox(height: 20),
            _inputField("Confirm Password", confirmPasswordController,
                isPassword: true),
            const SizedBox(height: 50),
            _registerBtn(),
            const SizedBox(height: 20),
            _extraText(),
          ],
        ),
      ),
    );
  }

  Widget _gameText() {
    return const Column(
      children: [
        Text(
          'POCKET',
          style: TextStyle(
            fontSize: 44.0,
            fontWeight: FontWeight.bold,
            color: AppColors.textEnabledColor,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'ELEVEN',
          style: TextStyle(
            fontSize: 44.0,
            fontWeight: FontWeight.bold,
            color: AppColors.textEnabledColor,
          ),
        ),
      ],
    );
  }

  Widget _inputField(String hintText, TextEditingController controller,
      {isPassword = false}) {
    var border = OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.white));

    return TextField(
      style: const TextStyle(color: Colors.white),
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white),
        enabledBorder: border,
        focusedBorder: border,
      ),
      obscureText: isPassword,
    );
  }

  Widget _registerBtn() {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    return OptionButton(
      index: 0,
      text: 'Sign up',
      onTap: () async {
        if (passwordController.text != confirmPasswordController.text) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Passwords do not match')));
          return;
        }

        await AuthServices.signupUser(
          emailController.text,
          passwordController.text,
          usernameController.text,
          clubnameController.text,
          context,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      },
      screenWidth: screenWidth,
      screenHeight: screenHeight,
    );
  }

  Widget _extraText() {
    return InkWell(
      child: const Text(
        "Already with US? Login here!",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TempLoginPage()),
        );
      },
    );
  }
}
