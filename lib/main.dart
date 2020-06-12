import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Firebase Authentication.'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  bool _isLoggedIn = false;
  String _photoUrl = '';
  String _loginType = '';


  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email'
    ],
  );
  var facebookLogin = new FacebookLogin();

  @override
  void dispose() {
    emailTextController.dispose();
    passwordTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
            widget.title,
        ),

      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.network(_photoUrl, height: 50.0, width: 50.0,),
                      Container(
                        child: _isLoggedIn
                        ? OutlineButton(child: Text('Logout - ${_loginType}'), onPressed: (){_logout();},)
                        : Text('Não Logado')
                      )
                    ],
            ),
            SizedBox(
              width: 360,
              child: TextFormField(
                validator: (input) {
                  if(input.isEmpty) {
                    return 'Please type an email';
                  }
                },
                decoration: InputDecoration(
                    labelText: 'Email'
                ),
                controller: emailTextController,
              ),
            ),
            SizedBox(
              width: 360,
              child: TextFormField(
                obscureText: true,
                validator: (input) {
                  if(input.isEmpty) {
                    return 'Please type an password';
                  }
                },
                decoration: InputDecoration(
                    labelText: 'Password'
                ),

                controller: passwordTextController,
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 360,
              child: RaisedButton(
                child: Row(
                  children: <Widget>[
                    Icon(Icons.mail, size: 30),
                    Text(
                      '  Sign up with Email',
                      style: TextStyle(fontSize: 28),
                    ),
                  ],
                ),
                textColor: Colors.white,
                color: Colors.red[400],
                padding: EdgeInsets.all(10),
                onPressed: () {
                  signUpWithMail();
                },
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 360,
              child: RaisedButton(
                child: Row(
                  children: <Widget>[
                    Icon(Icons.thumb_up, size: 30),
                    Text(
                      '  Sign up with Facebook',
                      style: TextStyle(fontSize: 28),
                    ),
                  ],
                ),
                textColor: Colors.white,
                color: Colors.blue[900],
                padding: EdgeInsets.all(10),
                onPressed: () {
                  signUpWithFacebook();
                },
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 360,
              child: RaisedButton(
                child: Row(
                  children: <Widget>[
                    Icon(Icons.toys, size: 30),
                    Text(
                      '  Sign up with Google',
                      style: TextStyle(fontSize: 28),
                    ),
                  ],
                ),
                textColor: Colors.black,
                color: Colors.white,
                padding: EdgeInsets.all(10),
                onPressed: () {
                  _googleSignUp();
                },
              ),
            ),

          ],
        ),
      ),
    );
  }

  Future<void> _googleSignUp() async {
    try {
      final FirebaseAuth _auth = FirebaseAuth.instance;

      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;

      print("signed in " + user.displayName);
      print('signed in ' + _googleSignIn.currentUser.photoUrl);

      setState(() {
        _isLoggedIn = true;
        _photoUrl = _googleSignIn.currentUser.photoUrl;
        _loginType = 'Google';
      });

      return user;
    }catch (e) {
      print(e.message);
    }
  }

  Future<void> signUpWithFacebook() async{
    try {
      await facebookLogin.logOut();
      var result = await facebookLogin.logIn(['email', 'public_profile']);

      if(result.status == FacebookLoginStatus.loggedIn) {
        final AuthCredential credential = FacebookAuthProvider.getCredential(
          accessToken: result.accessToken.token,

        );
        final FirebaseUser user = (await FirebaseAuth.instance.signInWithCredential(credential)).user;
        print('signed in ' + user.displayName);

        setState(() {
          _isLoggedIn = true;
          _photoUrl = user.photoUrl;
          _loginType = 'Facebook';
        });

        return user;
      }
    }catch (e) {
      print(e.message);
    }
  }

  Future<void> signUpWithMail() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailTextController.text,
          password: passwordTextController.text
      );

      setState(() {
        _isLoggedIn = true;
        _photoUrl = '';
        _loginType = 'e-mail';
      });

      showDialog(
          context: context,
        builder: (context) {
            return AlertDialog(
              content: Text('Success sign up'),
            );
        }
      );
    }catch(e) {
      print(e.message);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message),
            );
          }
      );
    }

  }

  _logout(){
    if (_isLoggedIn){
      if (_loginType == 'Google'){
        _googleSignIn.signOut();
      }

      if (_loginType == 'Facebook'){
        facebookLogin.logOut(); //todo-este logout ainda não funciona
      }
    }

    setState(() {
      _isLoggedIn = false;
      _photoUrl = '';
      _loginType = '';
    });
  }

}
