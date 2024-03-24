import 'dart:io';

import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:useraccount/components/LoadingDialog.dart';
import 'package:useraccount/components/appbar.dart';

class BlogChatPage extends StatefulWidget {
  final String currentUserId;

  BlogChatPage({required this.currentUserId});

  @override
  _BlogChatPageState createState() => _BlogChatPageState();
}

class _BlogChatPageState extends State<BlogChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: Color(0xFF456461),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('blogs')
            .orderBy('timestamp', descending: true)
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
                padding: EdgeInsets.all(8.0),
                child: _buildBlogCard(blog),
              );
            },
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CreateBlogPage(currentUserId: widget.currentUserId),
              ),
            );
          },
          backgroundColor: Colors.green,
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildBlogCard(DocumentSnapshot blogSnapshot) {
    Map<String, dynamic> blog = blogSnapshot.data() as Map<String, dynamic>;

    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF182727),
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  blog['topic'] as String,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              IconButton(
                icon: Icon(Icons.flag),
                color: Colors.red,
                onPressed: () => _reportBlog(blogSnapshot.id),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Text(
            blog['content'] as String,
            style: TextStyle(
                fontSize: 14.0, color: Colors.white, fontFamily: 'Poppins'),
          ),
          SizedBox(height: 8.0),
          if (blog['imageUrl'] != null && blog['imageUrl'] != '')
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        FullImagePage(imageUrl: blog['imageUrl'] as String),
                  ),
                );
              },
              child: Image.network(
                blog['imageUrl'] as String,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          SizedBox(height: 8.0),
          Text(
            'Location: ${blog['location']}',
            style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.white,
                fontFamily: 'Poppins'),
          ),
          SizedBox(height: 8.0),
          _CommentSection(blogId: blogSnapshot.id),
        ],
      ),
    );
  }

  void _reportBlog(String blogId) async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot reportSnapshot = await FirebaseFirestore.instance
        .collection('reports')
        .doc(blogId)
        .collection('users')
        .doc(currentUserId)
        .get();

    if (reportSnapshot.exists) {
      int reportsCount =
          (reportSnapshot.data() as Map<String, dynamic>)['reportsCount'];

      if (reportsCount >= 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('You have already reported this blog twice!',
                  style: TextStyle(color: Colors.red, fontFamily: 'Poppins'))),
        );
        return;
      } else {
        await FirebaseFirestore.instance
            .collection('reports')
            .doc(blogId)
            .collection('users')
            .doc(currentUserId)
            .update({'reportsCount': FieldValue.increment(1)});
      }
    } else {
      await FirebaseFirestore.instance
          .collection('reports')
          .doc(blogId)
          .collection('users')
          .doc(currentUserId)
          .set({'reportsCount': 1});
    }

    FirebaseFirestore.instance.collection('blogs').doc(blogId).update({
      'reported': true,
      'totalReportsCount': FieldValue.increment(1),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Blog reported successfully!')),
    );
  }
}

class _CommentSection extends StatefulWidget {
  final String blogId;

  _CommentSection({required this.blogId});

  @override
  __CommentSectionState createState() => __CommentSectionState();
}

class __CommentSectionState extends State<_CommentSection> {
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _commentController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Write a comment...',
            hintStyle: TextStyle(color: Colors.grey),
            suffixIcon: IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                _postComment();
              },
            ),
            filled: true,
            fillColor: Color(0xFF182727),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
        SizedBox(height: 8.0),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewCommentsPage(blogId: widget.blogId),
              ),
            );
          },
          child: Text('View Comments'),
        ),
      ],
    );
  }

  void _postComment() {
    String commentText = _commentController.text.trim();
    if (commentText.isNotEmpty) {
      FirebaseFirestore.instance.collection('comments').add({
        'postId': widget.blogId,
        'commentText': commentText,
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _commentController.clear();
    }
  }
}

class ViewCommentsPage extends StatelessWidget {
  final String blogId;

  ViewCommentsPage({required this.blogId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: Color(0xFF456461),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('comments')
            .where('postId', isEqualTo: blogId)
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
              var comment = snapshot.data!.docs[index];
              return CommentItem(comment: comment);
            },
          );
        },
      ),
    );
  }
}

class CommentItem extends StatelessWidget {
  final QueryDocumentSnapshot<Object?> comment;

  CommentItem({required this.comment});

  @override
  Widget build(BuildContext context) {
    String userEmail = "User"; // Displaying user as "User"
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Color(0xFF182727),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            userEmail, // Display user as "User"
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            comment['commentText'].toString(),
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 8.0),
          _ReplySection(commentId: comment.id),
        ],
      ),
    );
  }
}

class _ReplySection extends StatefulWidget {
  final String commentId;

  _ReplySection({required this.commentId});

  @override
  __ReplySectionState createState() => __ReplySectionState();
}

class __ReplySectionState extends State<_ReplySection> {
  late TextEditingController _replyController;

  @override
  void initState() {
    super.initState();
    _replyController = TextEditingController();
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _replyController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Reply to comment...',
            hintStyle: TextStyle(color: Colors.grey),
            suffixIcon: IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                _postReply();
              },
            ),
            filled: true,
            fillColor: Color(0xFF182727),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
        SizedBox(height: 8.0),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ViewRepliesPage(commentId: widget.commentId),
              ),
            );
          },
          child: Text('View Replies'),
        ),
      ],
    );
  }

  void _postReply() {
    String replyText = _replyController.text.trim();
    if (replyText.isNotEmpty) {
      FirebaseFirestore.instance.collection('replies').add({
        'commentId': widget.commentId,
        'replyText': replyText,
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _replyController.clear();
    }
  }
}

class ViewRepliesPage extends StatelessWidget {
  final String commentId;

  ViewRepliesPage({required this.commentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: Color(0xFF456461),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('replies')
            .where('commentId', isEqualTo: commentId)
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
              var reply = snapshot.data!.docs[index];
              return ReplyItem(reply: reply);
            },
          );
        },
      ),
    );
  }
}

class ReplyItem extends StatelessWidget {
  final QueryDocumentSnapshot<Object?> reply;

  ReplyItem({required this.reply});

  @override
  Widget build(BuildContext context) {
    String userEmail = "User"; // Displaying user as "User"
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Color(0xFF182727),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            userEmail, // Display user as "User"
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            reply['replyText'].toString(),
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class FullImagePage extends StatelessWidget {
  final String imageUrl;

  FullImagePage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Center(
        child: Image.network(
          imageUrl,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class CreateBlogPage extends StatefulWidget {
  final String currentUserId;

  CreateBlogPage({required this.currentUserId});

  @override
  _CreateBlogPageState createState() => _CreateBlogPageState();
}

class _CreateBlogPageState extends State<CreateBlogPage> {
  TextEditingController _topicController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  TextEditingController _locationController = TextEditingController();

  File? _image;
  final picker = ImagePicker();

  Future<void> getImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      setState(() {
        _image = pickedFile != null ? File(pickedFile.path) : null;
      });
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _topicController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Topic',
                labelStyle:
                    TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                filled: true,
                fillColor: Color(0xFF182727),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                hintStyle: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _contentController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Content',
                labelStyle:
                    TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                filled: true,
                fillColor: Color(0xFF182727),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                hintStyle: TextStyle(color: Colors.white),
              ),
              maxLines: 4,
            ),
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: getImage,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xFF182727),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Select Image',
                    style:
                        TextStyle(color: Colors.white, fontFamily: 'Poppins')),
              ),
            ),
            SizedBox(height: 10),
            _image != null ? Image.file(_image!) : SizedBox(),
            SizedBox(height: 10),
            TextFormField(
              controller: _locationController,
              style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
              decoration: InputDecoration(
                labelText: 'Location',
                labelStyle:
                    TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                filled: true,
                fillColor: Color(0xFF182727),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                hintStyle:
                    TextStyle(color: Colors.white, fontFamily: 'Poppins'),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _addBlogToFirebase(
                    _topicController.text,
                    _contentController.text,
                    _locationController.text,
                    context,
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text('Post',
                    style:
                        TextStyle(color: Colors.white, fontFamily: 'Poppins')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addBlogToFirebase(
    String topic,
    String content,
    String location,
    BuildContext context,
  ) async {
    try {
      // Start Firebase performance monitoring for this operation
      final Trace myTrace =
          FirebasePerformance.instance.newTrace('Chat_CreateBlogPage_PostBlog');
      myTrace.start();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return LoadingDialog(
            message: 'Posting Blog...',
            iconData: Icons.cloud_upload_outlined,
          );
        },
      );

      String imageUrl = '';

      if (_image != null) {
        var storageReference = FirebaseStorage.instance
            .ref()
            .child('blog_images')
            .child(DateTime.now().toString());
        var uploadTask = storageReference.putFile(_image!);
        var snapshot = await uploadTask.whenComplete(() {});
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      var blogRef = await FirebaseFirestore.instance.collection('blogs').add({
        'topic': topic,
        'content': content,
        'imageUrl': imageUrl,
        'location': location,
        'userId': widget.currentUserId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!(await blogRef.collection('comments').doc().get()).exists) {
        await blogRef.collection('comments').add({});
      }

      // Stop Firebase performance monitoring for this operation
      myTrace.stop();

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Blog posted successfully!')),
      );

      Navigator.pop(context);
    } catch (error) {
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error posting blog: $error')),
      );
    }
  }
}
