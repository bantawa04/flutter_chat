import 'package:flutter/material.dart';
import 'package:flutter_chat/widgets/user_image_picker.dart';
import 'dart:io';

class AuthForm extends StatefulWidget {
  final bool isLoading;
  final void Function(
    String email,
    String username,
    String password,
    bool isLogin,
    BuildContext ctx,
    File userImageFile,
  ) submitForm;
  const AuthForm(this.submitForm, this.isLoading, {Key? key}) : super(key: key);

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _usernameNode = FocusNode();
  final _passwordNode = FocusNode();

  final _formKey = GlobalKey<FormState>();

  var isLogin = true;
  var _userEmail = '';
  var _userName = '';
  var _password = '';
  File? _userImageFile;

  void _pickedImage(File image) {
    _userImageFile = image;
  }

  void _trySumbit() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();

    if (_userImageFile == null && !isLogin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Please pick an image"),
          duration: const Duration(seconds: 2),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
      return;
    }

    if (isValid) {
      _formKey.currentState!.save();
      widget.submitForm(
        _userEmail.trim(),
        _userName.trim(),
        _password.trim(),
        isLogin,
        context,
        _userImageFile!,
      );
    }
  }

  @override
  void dispose() {
    //Dispose nodes on widget close to avoid memory leak
    _usernameNode.dispose();
    _passwordNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min, //take only space as it needs
              children: <Widget>[
                if (!isLogin) UserImagePicker(_pickedImage),
                TextFormField(
                  key: const ValueKey('email'),
                  decoration: const InputDecoration(
                    label: Text("Email"),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context)
                        .requestFocus(isLogin ? _passwordNode : _usernameNode);
                  },
                  validator: (value) {
                    if (value!.isEmpty || !value.contains('@')) {
                      return "Please enter a valid email address";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _userEmail = value!;
                  },
                ),
                if (!isLogin)
                  TextFormField(
                    key: const ValueKey('username'),
                    decoration: const InputDecoration(label: Text("Username")),
                    focusNode: _usernameNode,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_passwordNode);
                    },
                    validator: (value) {
                      if (value!.isEmpty || value.length < 5) {
                        return "Please enter username greater than 5 charachers";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _userName = value!;
                    },
                  ),
                TextFormField(
                  key: const ValueKey('password'),
                  focusNode: _passwordNode,
                  decoration: const InputDecoration(label: Text("Password")),
                  obscureText: true,
                  validator: (value) {
                    if (value!.isEmpty || value.length < 7) {
                      return "Please enter password greater than 7 charachers";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _password = value!;
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                widget.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : ElevatedButton(
                        onPressed: _trySumbit,
                        child: Text(isLogin ? "Login" : "Signup"),
                      ),
                TextButton(
                    onPressed: () {
                      setState(() {
                        isLogin = !isLogin;
                      });
                    },
                    child: Text(
                      isLogin ? "Create new account" : "I already have account",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
