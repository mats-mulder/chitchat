import 'package:chitchat/overview/overview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chitchat/const.dart';
import 'package:chitchat/chat/chatGallery.dart';

class ChatSettings extends StatefulWidget {
  final String chatId;
  final Future<Map<String, DocumentSnapshot>> chatUsers;
  final String chatType;
  final String currentUserId;
  Stream<QuerySnapshot> streamMessage;

  ChatSettings(this.chatUsers, this.chatId, this.chatType, this.currentUserId);

  @override
  createState() => ChatSettingsState();
}

class ChatSettingsState extends State<ChatSettings> {
  Size deviceSize;

  Widget profileHeader() => Container(
        height: deviceSize.height / 4,
        width: double.infinity,
        color: themeColor,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            color: themeColor,
            child: FittedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50.0),
                        border: Border.all(width: 2.0, color: Colors.white)),
                    child: CircleAvatar(
                      radius: 40.0,
                      backgroundImage: NetworkImage(
                          "https://cdn.pixabay.com/photo/2017/03/24/07/28/whatsapp-2170427_960_720.png"),
                    ),
                  ),
                  Text(
                    "Name of the chat",
                    style: TextStyle(color: Colors.white, fontSize: 20.0),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget imagesCard() => Container(
        height: deviceSize.height / 6,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChatGallery(widget.chatId, widget.chatUsers)),
                    );
                  },
                  child: Text(
                    "Photos",
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0),
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, i) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.network(
                              "https://cdn.pixabay.com/photo/2016/10/31/18/14/ice-1786311_960_720.jpg"),
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget profileColumn(user, length) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            backgroundImage: NetworkImage(
                user["photoUrl"]),
          ),
          Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      user["nickname"],
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                  ],
                ),
              )
          ),
          /* widget.chatType == "G"
           ? IconButton(
            icon: Icon(Icons.delete),
            tooltip: 'Delete a user of the group',
            onPressed: () {},
          )
          : Container(), */
        ],
      ),
    );
  }

  Widget userList() => Container(
      height: deviceSize.height / 4,
      padding: const EdgeInsets.all(0.0),
      child: FutureBuilder(
          future: widget.chatUsers,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return ListView.builder(
                padding: EdgeInsets.all(10.0),
                itemBuilder: (context, index) => profileColumn(snapshot.data.values.toList()[index], snapshot.data.values.length),
                itemCount: snapshot.data.length,
                reverse: true,
              );
            } else {
              return Container();
            }
          }
      ),
    );

  Widget usersCard() => Container(
        width: double.infinity,
        height: deviceSize.height / 2.75,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  "Users",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0),
                ),
              ),
              userList(),
            ],
          ),
        ),
      );

  Widget leaveChatCard() => Container(
        height: deviceSize.height / 18,
        width: deviceSize.width / 2,
        //padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 1.0),
        child: FlatButton(
          onPressed: () => leaveChat(),
          child: Text(
            'Leave chat',
            style: TextStyle(fontSize: 16.0, color: Colors.white),
          ),
          color: Colors.red,
          highlightColor: Colors.white30,
          splashColor: Colors.transparent,
          textColor: Colors.white,
          padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
        ),
      );

  Widget bodyData() => Container(
        child: Column(
          children: <Widget>[
            profileHeader(),
            imagesCard(),
            usersCard(),
            widget.chatType == "G"
            ? leaveChatCard()
            : Container(),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    deviceSize = MediaQuery.of(context).size;
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
          'CHAT SETTINGS',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: bodyData(), //new ChatSettingsScreen(),
    );
  }

  void leaveChat() async {

    Map<String, DocumentSnapshot> listUsers = await widget.chatUsers;
    listUsers.remove(widget.currentUserId);
    await Firestore.instance
        .collection('chats')
        .document(widget.chatId)
        .updateData({'users': listUsers.keys.toList() });
    //Check if chat is empty and delete it
    if(listUsers.isEmpty){
      await Firestore.instance
        .collection('chats')
        .document(widget.chatId)
        .delete();
    }
    Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                  MainScreen(currentUserId: widget.currentUserId),
            )
    );
    /*
    Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                  MainScreen(currentUserId: widget.currentUserId),
            )
          );
          */
  }

  List<QuerySnapshot> getParticipants() {
    var participants = Firestore.instance
        .collection('chats')
        .document(widget.chatId)
        .collection('users')
        .snapshots()
        .toList();

    return null;
  }
}

class ProfileTile extends StatelessWidget {
  final title;
  final subtitle;
  final textColor;

  ProfileTile({this.title, this.subtitle, this.textColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
              fontSize: 50.0, fontWeight: FontWeight.w700, color: textColor),
        ),
        SizedBox(
          height: 5.0,
        ),
        Text(
          subtitle,
          style: TextStyle(
              fontSize: 15.0, fontWeight: FontWeight.normal, color: textColor),
        ),
      ],
    );
  }
}
