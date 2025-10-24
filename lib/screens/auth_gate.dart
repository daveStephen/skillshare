import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_controller.dart'; 
import 'main_screens.dart'; // Import MainAppWrapper

// --- 1. AUTH GATE (Router) ---

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<AppController>(context);

    // 1. Show a loading indicator if the controller is busy (e.g., logging in/out)
    if (controller.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 2. Redirect based on login status
    if (controller.isLoggedIn && controller.currentUser != null) {
      return MainAppWrapper(controller: controller);
    } else {
      // Otherwise, show the login screen
      return const LoginScreen();
    }
  }
}

// --- 2. LOGIN SCREEN ---

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // >>>>>>>>>>>>>>>>>>>>>>>>>>>>> LOGIN LOGIC FIX <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  void _login() {
    // Only login if fields are not empty
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password.')),
      );
      return;
    }
    
    // Call the mockLogin function and check the result
    final success = Provider.of<AppController>(context, listen: false).mockLogin(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success) {
      // Success: AppController state change triggers AuthGate to navigate to Home
      _emailController.clear();
      _passwordController.clear();
    } else {
      // Failure: Show error message
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Provider.of<AppController>(context, listen: false).authError ?? 'Login failed. Check credentials.')),
      );
    }
  }
  // >>>>>>>>>>>>>>>>>>>>>>>>>>>>> END LOGIN LOGIC FIX <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AppController>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Welcome to SkillShare', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock)),
                obscureText: true,
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Login', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: isLoading ? null : () {
                  // Navigate to the SignUpScreen
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SignUpScreen(),
                  ));
                },
                child: const Text("Don't have an account? Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 3. SIGN UP SCREEN ---

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // >>>>>>>>>>>>>>>>>>>>>>>>>>>>> SIGNUP LOGIC FIX <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  void _signUp() async {
    // Basic validation
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields.')),
      );
      return;
    }

    final controller = Provider.of<AppController>(context, listen: false);

    // This call now handles logging the user in upon success (in AppController)
    final result = await controller.signUp(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _nameController.text.trim(),
    );

    if (mounted) {
      if (result == null) {
        // SUCCESS: The AppController now contains the new user.
        // We only need to clear the form and pop the screen. AuthGate handles navigation.
        
        _emailController.clear();
        _passwordController.clear();
        _nameController.clear();
        
        // Go back to the Login screen (which will immediately redirect to Home via AuthGate)
        Navigator.of(context).pop(); 

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup Successful! Welcome!')),
        );
      } else {
        // FAILURE: Show the error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result)),
        );
      }
    }
  }
  // >>>>>>>>>>>>>>>>>>>>>>>>>>>>> END SIGNUP LOGIC FIX <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AppController>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Join SkillShare Today', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email)),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock)),
                obscureText: true,
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: isLoading ? null : _signUp,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Sign Up', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: isLoading ? null : () {
                  Navigator.of(context).pop(); // Go back to Login Screen
                },
                child: const Text("Already have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}