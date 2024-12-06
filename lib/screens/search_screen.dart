import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:instagram_clone/constants/firebase_consts.dart';
import 'package:instagram_clone/constants/firestore_consts.dart';
import 'package:instagram_clone/screens/profile_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onSubmitted: (value) {
                setState(() {
                  searchController.text = value;
                });
              },
              controller: searchController,
              decoration: InputDecoration(
                  fillColor: const Color(0XFF262626),
                  filled: true,
                  prefixIcon: const Icon(
                    CupertinoIcons.search,
                    color: Colors.white,
                  ),
                  hintText: 'Search',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0))),
            ),
          ),
          const SizedBox(
            height: 12.0,
          ),
          searchController.text.isEmpty
              ? FutureBuilder(
                  future: firestore
                      .collection(FirestoreConstants.postsCollection)
                      .orderBy('datePublished')
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(snapshot.error.toString()),
                      );
                    } else {
                      return Expanded(
                        child: GridView.builder(
                          itemCount: snapshot.data!.docs.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 4,
                                  crossAxisSpacing: 4),
                          itemBuilder: (context, index) {
                            final snap = snapshot.data!.docs[index];
                            // ignore: avoid_unnecessary_containers
                            return Container(
                                child: CachedNetworkImage(
                              imageUrl: snap['postUrl'],
                              fit: BoxFit.cover,
                              placeholder: (context, url) {
                                return const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2.5,),
                                );
                              },
                            ));
                          },
                        ),
                      );
                    }
                  },
                )
              : StreamBuilder(
                  stream: firestore
                      .collection(FirestoreConstants.usersCollection)
                      .where('username',
                          isGreaterThanOrEqualTo: searchController.text.trim())
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      return Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final data = snapshot.data!.docs[index];
                            return ListTile(
                              onTap: () =>
                                  Get.to(() => ProfileScreen(uid: data['uid'])),
                              leading: CircleAvatar(
                                radius: 28,
                                backgroundImage: NetworkImage(data['photoUrl']),
                              ),
                              title: Text(data['username']),
                              subtitle: Text(data['bio']),
                            );
                          },
                        ),
                      );
                    } else {
                  return    const Center(
                        child: CircularProgressIndicator(strokeWidth: 2.5,)
                        ,
                      );
                    }
                  },
                )
        ]),
      ),
    );
  }
}
