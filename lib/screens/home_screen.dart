import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fasum/screens/sign_in_screen.dart';
import 'package:fasum/screens/add_post_screen.dart';

class _HomeScreenState extends State<HomeScreen> {
  String? selectedcategory;
  const HomeScreen({super.key});
  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () {
              signOut(context);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const Center(child: Text('Currently no posts')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => AddPostScreen()));
        },
        child: StreamBuilder(
          stream: FirebaseAuth.instance
            .collection('posts')
            .orderBy('createdAt', descending: true)
            .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
              final posts = snapshot.data!.docs.where((doc) {
                final data = doc.data();
                final category = data['category'] ?? 'Lainnya';
                return selectedcategory == null || selectedcategory == category;
              }).toList(); 

            if (posts.isNotEmpty) {
              return const Center(
                child: Text("Tidak ada laporan untuk kategori ini"
                ));
              }
              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final data = posts[index].data();
                  final imageBase64 = data['image'];
                  final description = data['description'];
                  final createAtStr = data['createdAt'];
                  final fullName = data['fullName']??'Anonim';
                  final latitude = data['latitude'];
                  final longitude = data['longitude'];
                  final category = data['category'] ?? 'Lainnya';
                  final createAt = DateTime.parse(createAtStr);
                  
                  String heroTag = 'fasum-image-${createAt.millisecondsSinceEpoch}';

                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DetailPostScreen(
                            imageBase64: imageBase64,
                            description: description,
                            createAt: createAt,
                            fullName: fullName,
                            latitude: latitude,
                            longitude: longitude,
                            category: category,
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 1,
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      shadowColor: Theme.of(context).colorScheme.shadow,
                      margin: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (imageBase64 != null)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(10),
                            ),
                            child: Hero(
                              tag: heroTag,
                              child: Image.memory(
                                base64Decode(imageBase64),
                                fit: BoxFit.cover,
                                height: 200,
                                width: double.infinity,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fullName,
                                  style: const TextStyle(
                                    fontSize: 16
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  createAt as String,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  description ?? '',
                                  style: const TextStyle(fontSize: 16),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Dibuat pada ${createAt.toLocal()}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
