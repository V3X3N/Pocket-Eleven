import 'package:flutter/material.dart';
import 'package:pocket_eleven/components/option_button.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/firebase/auth_functions.dart';
import 'package:pocket_eleven/pages/loading/temp_register_page.dart';
import 'package:pocket_eleven/pages/home_page.dart';

class TempLoginPage extends StatefulWidget {
  const TempLoginPage({super.key});

  @override
  State<TempLoginPage> createState() => _TempLoginPageState();
}

class _TempLoginPageState extends State<TempLoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

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
            _inputField("Email", usernameController),
            const SizedBox(height: 20),
            _inputField("Password", passwordController, isPassword: true),
            const SizedBox(height: 50),
            _loginBtn(),
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

  Widget _loginBtn() {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    return OptionButton(
      index: 0,
      text: 'Sign in',
      onTap: () async {
        // Call AuthServices.signinUser
        await AuthServices.signinUser(
          usernameController.text,
          passwordController.text,
          context,
        );

        // Navigate to HomePage after successful login
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
        "New here? Register now!",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TempRegisterPage()),
        );
      },
    );
  }
}
