import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:useraccount/components/LoadingDialog.dart';
import 'package:useraccount/components/appbar.dart';
import 'package:useraccount/pages/Signin.dart'; // Import your Signin.dart file

void main() {
  runApp(MaterialApp(
    home: UserProfilePage(
      userProfile: FirebaseAuth.instance.currentUser,
    ),
  ));
}

class UserProfilePage extends StatefulWidget {
  final User? userProfile;

  UserProfilePage({Key? key, required this.userProfile}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  Widget build(BuildContext context) {
    final String? username = widget.userProfile!.email!.split('@').first;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight * 1.5),
        child: CustomAppBarWithProfile(
          context: context,
          height: kToolbarHeight * 1.5, // Define the height of the app bar
        ),
      ),
      backgroundColor: Color(0xFF456461),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(top: 30.0, left: 20.0, bottom: 20.0),
              child: Text(
                'Hello, $username',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Color(0xFF182727),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email: ',
                      style: TextStyle(
                        fontSize: 18,
                        color: const Color.fromARGB(255, 255, 255, 255),
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${widget.userProfile!.email}',
                      style: TextStyle(
                        fontSize: 17,
                        color: const Color.fromARGB(255, 255, 255, 255),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChangePasswordForm(),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Change Password',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preferences:',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        PreferencesForm(userProfile: widget.userProfile),
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _signOut(context),
                      child: Text(
                        'Sign Out',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[900],
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _deleteAccount(context),
                      child: Text(
                        'Delete Account',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[900],
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MyBlogsPage(userProfile: widget.userProfile),
                            ),
                          );
                        },
                        child: ListTile(
                          title: Text(
                            'My Blogs',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: SizedBox(
                            width: 40, // Adjust the width as needed
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Spacer(),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      //   bottomNavigationBar: CustomNavBar.CustomBottomNavigationBar(
      //     currentIndex: 4,
      //     onTap: (index) {},
      //   ),
    );
  }
}

class ChangePasswordForm extends StatefulWidget {
  @override
  _ChangePasswordFormState createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  void _changePassword() async {
    setState(() {
      _isLoading = true;
    });

    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: FirebaseAuth.instance.currentUser!.email!,
        password: _oldPasswordController.text,
      );
      await FirebaseAuth.instance.currentUser!
          .reauthenticateWithCredential(credential);
      await FirebaseAuth.instance.currentUser!
          .updatePassword(_newPasswordController.text);
      Navigator.pop(context); // Close the change password screen
    } catch (e) {
      print('Error changing password: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: Color(0xFF456461),
      body: _isLoading
          ? LoadingDialog(message: 'Changing password...', iconData: Icons.lock)
          : SingleChildScrollView(
              padding: EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _oldPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Old Password',
                        labelStyle: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your old password.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _newPasswordController,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        labelStyle: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your new password.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _changePassword,
                      child: Text(
                        'Change Password',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class PreferencesForm extends StatefulWidget {
  final User? userProfile;

  const PreferencesForm({Key? key, required this.userProfile})
      : super(key: key);

  @override
  _PreferencesFormState createState() => _PreferencesFormState();
}

class _PreferencesFormState extends State<PreferencesForm> {
  late List<String> _preferences = [];
  late List<String> _selectedPreferences = [];

  @override
  void initState() {
    super.initState();
    _fetchPreferences();
  }

  void _fetchPreferences() async {
    final preferencesSnapshot =
        await FirebaseFirestore.instance.collection('preferences').get();

    if (preferencesSnapshot.docs.isNotEmpty) {
      setState(() {
        _preferences = preferencesSnapshot.docs
            .map((doc) => doc.get('name'))
            .toList()
            .cast<String>();
      });
      _fetchUserPreferences();
    }
  }

  void _fetchUserPreferences() async {
    final preferences = await FirebaseFirestore.instance
        .collection('userPreferences')
        .doc(widget.userProfile!.uid)
        .get();

    if (preferences.exists) {
      final List<dynamic>? userPreferences = preferences['preferences'];
      if (userPreferences != null) {
        setState(() {
          _selectedPreferences =
              userPreferences.map((pref) => pref.toString()).toList();
        });
      }
    } else {
      _selectedPreferences = [];
    }
  }

  void _togglePreference(String preference) {
    setState(() {
      if (_selectedPreferences.contains(preference)) {
        _selectedPreferences.remove(preference);
      } else {
        _selectedPreferences.add(preference);
      }
    });

    _updateUserPreferences();
  }

  void _updateUserPreferences() {
    FirebaseFirestore.instance
        .collection('userPreferences')
        .doc(widget.userProfile!.uid)
        .set({'preferences': _selectedPreferences});
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: _preferences.map((preference) {
        return FilterChip(
          label: Text(preference),
          selected: _selectedPreferences.contains(preference),
          onSelected: (bool selected) {
            _togglePreference(preference);
          },
          selectedColor: Colors.green,
          backgroundColor: Colors.grey[200],
        );
      }).toList(),
    );
  }
}

class MyBlogsPage extends StatefulWidget {
  final User? userProfile;

  MyBlogsPage({Key? key, required this.userProfile}) : super(key: key);

  @override
  _MyBlogsPageState createState() => _MyBlogsPageState();
}

class _MyBlogsPageState extends State<MyBlogsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: Color(0xFF456461),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('blogs')
            .where('userId', isEqualTo: widget.userProfile!.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var blog = snapshot.data!.docs[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: Color(0xFF182727),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(
                          blog['topic'],
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          blog['content'],
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            // Delete image from Firestore storage
                            if (blog['imageUrl'] != null &&
                                blog['imageUrl'] != '') {
                              try {
                                await FirebaseStorage.instance
                                    .refFromURL(blog['imageUrl'])
                                    .delete();
                              } catch (e) {
                                print('Error deleting image: $e');
                                // Handle error accordingly
                              }
                            }

                            // Delete document from Firestore
                            FirebaseFirestore.instance
                                .collection('blogs')
                                .doc(blog.id)
                                .delete();
                          },
                        ),
                      ),
                      if (blog['imageUrl'] != null && blog['imageUrl'] != '')
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Image.network(
                            blog['imageUrl'],
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Location: ${blog['location']}',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

void _signOut(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SigninForm()),
    );
  } catch (e) {
    print('Error signing out: $e');
    // Handle error accordingly
  }
}

void _deleteAccount(BuildContext context) async {
  final User user = FirebaseAuth.instance.currentUser!;
  final providerData = user.providerData;
  bool isGoogleSignIn = false;

  for (var provider in providerData) {
    if (provider.providerId == 'google.com') {
      isGoogleSignIn = true;
      break;
    }
  }

  if (isGoogleSignIn) {
    // User signed in with Google, show confirmation dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Account"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("Type DELETE to confirm:"),
              TextField(
                autofocus: true,
                decoration: InputDecoration(hintText: 'DELETE'),
                onChanged: (value) {
                  // Track the value
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                // Delete the account
                // ignore: unnecessary_null_comparison
                if (user != null) {
                  try {
                    await user.delete();
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SigninForm()),
                    );
                  } catch (e) {
                    print("Error deleting user: $e");
                    // Handle error accordingly
                  }
                }
              },
              child: Text("Confirm"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  } else {
    // User signed in with email/password, ask for password
    String password = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Enter Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                obscureText: true,
                decoration: InputDecoration(hintText: 'Password'),
                onChanged: (value) {
                  password = value;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                // Delete the account
                // ignore: unnecessary_null_comparison
                if (user != null) {
                  try {
                    AuthCredential credential = EmailAuthProvider.credential(
                      email: user.email!,
                      password: password,
                    );
                    await user.reauthenticateWithCredential(credential);
                    await user.delete();
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SigninForm()),
                    );
                  } catch (e) {
                    print("Error deleting user: $e");
                    // Handle error accordingly
                  }
                }
              },
              child: Text("Confirm"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }
}
