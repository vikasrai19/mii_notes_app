import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/helper/helper_functions.dart';
import 'package:notes_app/services/auth.dart';
import 'package:notes_app/services/database.dart';

bool isSearching;

class ChatScreenPage extends StatefulWidget {
  final String email;

  const ChatScreenPage({Key key, this.email}) : super(key: key);
  @override
  _ChatScreenPageState createState() => _ChatScreenPageState();
}

class _ChatScreenPageState extends State<ChatScreenPage> {
  TextEditingController searchController = new TextEditingController();
  DatabaseMethods databaseMethods = new DatabaseMethods();

  Stream searchStream;
  QuerySnapshot friendsSnapshot;
  String myEmail;
  List friends;

  @override
  void initState() {
    super.initState();
    isSearching = false;
    HelperFunction.getUserEmailFromSharedPreference().then((value) {
      setState(() {
        myEmail = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    String value;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(
            children: [
              CustomChatAppBar(),
              SizedBox(height: 20.0),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                height: 40,
                width: screenWidth,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    // color: Colors.red,
                    border: Border.all(
                        width: 1.0, color: Theme.of(context).indicatorColor)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.search, color: Theme.of(context).indicatorColor),
                    Expanded(
                      child: TextFormField(
                        onChanged: (string) {
                          print(string);
                          if (string == null || string == "") {
                            setState(() {
                              isSearching = false;
                              value = string;
                            });
                            print(isSearching);
                          } else {
                            setState(() {
                              isSearching = true;
                            });
                            databaseMethods
                                .getFirendList(roomId: myEmail)
                                .then((value) {
                              setState(() {
                                friendsSnapshot = value;
                                friends = friendsSnapshot
                                    .documents[0].data["friends"];
                                print(friendsSnapshot
                                    .documents[0].data["friends"].length);
                              });
                            });
                            databaseMethods
                                .findFriends(value: string)
                                .then((value) {
                              setState(() {
                                searchStream = value;
                              });
                            });
                            print(isSearching);
                          }
                        },
                        style: GoogleFonts.montserrat(
                            color: Theme.of(context).indicatorColor,
                            fontSize: 18.0),
                        controller: searchController,
                        decoration: InputDecoration(
                            alignLabelWithHint: true,
                            // prefixIcon: Icon(Icons.search,
                            //     color: Theme.of(context).indicatorColor, size: 16),
                            contentPadding: EdgeInsets.only(
                                left: 8.0, right: 8.0, bottom: 12.0),
                            hintText: 'Search Here Using Name Or Email',
                            hintStyle: GoogleFonts.montserrat(
                                fontSize: 14.0,
                                color: Theme.of(context)
                                    .indicatorColor
                                    .withOpacity(0.4)),
                            border: InputBorder.none),
                      ),
                    ),
                  ],
                ),
              ),
              isSearching
                  ? SearchListView(
                      searchStream: searchStream,
                      screenHeight: screenHeight,
                      screenWidth: screenWidth,
                      myEmail: myEmail,
                      friendList: friends,
                    )
                  : Container(height: 100, width: 100, color: Colors.blue)
            ],
          ),
        ),
      ),
    );
  }
}

class SearchListView extends StatefulWidget {
  const SearchListView(
      {Key key,
      @required this.searchStream,
      @required this.screenHeight,
      @required this.screenWidth,
      this.friendList,
      this.myEmail})
      : super(key: key);

  final Stream searchStream;
  final double screenHeight;
  final double screenWidth;
  final String myEmail;
  final List friendList;

  @override
  _SearchListViewState createState() => _SearchListViewState();
}

class _SearchListViewState extends State<SearchListView> {
  bool isFriend = false;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder(
        stream: widget.searchStream,
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) {
                    if (widget.friendList != null &&
                        widget.friendList.contains(snapshot
                                .data.documents[index].data["userEmail"]) ==
                            true) {
                      isFriend = true;
                    } else {
                      isFriend = false;
                    }
                    if (widget.friendList != null &&
                        snapshot.data.documents[index].data["userEmail"] !=
                            widget.myEmail) {
                      return ListTile(
                        leading: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: snapshot.data.documents[index]
                                          .data["imageUrl"] !=
                                      null
                                  ? Colors.transparent
                                  : Colors.grey),
                          child: snapshot
                                      .data.documents[index].data["imageUrl"] !=
                                  null
                              ? ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0)),
                                  child: Image.network(
                                      snapshot.data.documents[index]
                                          .data["imageUrl"],
                                      fit: BoxFit.cover),
                                )
                              : Icon(Icons.person,
                                  color: Theme.of(context).indicatorColor),
                        ),
                        trailing: GestureDetector(
                          onTap: () {
                            if (isFriend == false) {
                              print("Add");
                              if (widget.friendList.contains(snapshot.data
                                      .documents[index].data["userEmail"]) ==
                                  false) {
                                Map<String, dynamic> data = {
                                  "friends": FieldValue.arrayUnion([
                                    snapshot
                                        .data.documents[index].data["userEmail"]
                                  ])
                                };
                                Map<String, dynamic> myData = {
                                  "friends":
                                      FieldValue.arrayUnion([widget.myEmail])
                                };
                                setState(() {
                                  isFriend = true;
                                });
                                databaseMethods.addFriends(
                                    roomId: widget.myEmail, friendData: data);

                                databaseMethods.addFriends(
                                    roomId: snapshot.data.documents[index]
                                        .data["userEmail"],
                                    friendData: myData);
                              }
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: 30,
                            width: 60.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.blue,
                            ),
                            child: isFriend
                                ? Text(
                                    "Message",
                                    style: GoogleFonts.montserrat(
                                        color: Colors.white, fontSize: 10),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Add",
                                        style: GoogleFonts.montserrat(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                      Icon(Icons.add,
                                          color: Colors.white, size: 12)
                                    ],
                                  ),
                          ),
                        ),
                        title: Text(
                          snapshot.data.documents[index].data["name"],
                          style: GoogleFonts.montserrat(
                              color: Theme.of(context).indicatorColor,
                              fontSize: 16),
                        ),
                        subtitle: AutoSizeText(
                          snapshot.data.documents[index].data["userEmail"],
                          style: GoogleFonts.montserrat(
                              color: Theme.of(context).indicatorColor,
                              fontSize: 12),
                          minFontSize: 8,
                          maxFontSize: 12,
                        ),
                      );
                    }
                  },
                )
              : Container(
                  height: widget.screenHeight * 0.35,
                  width: widget.screenWidth,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
        },
      ),
    );
  }
}

class CustomChatAppBar extends StatelessWidget {
  const CustomChatAppBar({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                child: Icon(Icons.arrow_back,
                    color: Theme.of(context).indicatorColor),
              ),
            ),
            SizedBox(width: 20),
            Text(
              "Chats",
              style: GoogleFonts.montserrat(
                  color: Theme.of(context).indicatorColor,
                  fontSize: 22.0,
                  fontWeight: FontWeight.w600),
            )
          ],
        ),
        FaIcon(FontAwesomeIcons.heart, color: Theme.of(context).indicatorColor)
      ],
    );
  }
}
