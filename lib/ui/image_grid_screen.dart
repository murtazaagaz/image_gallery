import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_gallery/ui/full_sceen_image.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/image_controller.dart';

class ImageGridScreen extends StatelessWidget {
  final ImageController controller = Get.put(ImageController());

  ImageGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Gallery'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: controller.searchController,
              onChanged: (value) {
                controller.searchQuery.value = value;
              },
              decoration: const InputDecoration(
                hintText: 'Search images...',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.images.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels ==
                scrollInfo.metrics.maxScrollExtent) {
              controller.loadMoreImages();
            }
            return true;
          },
          child: GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: (MediaQuery.of(context).size.width ~/ 150),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.7,
            ),
            itemCount: controller.images.length,
            itemBuilder: (context, index) {
              final image = controller.images[index];
              return GestureDetector(
                onTap: () => Get.to(() => FullScreenImage(image: image)),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CachedNetworkImage(
                        imageUrl: image.imageUrl,
                        placeholder: (context, url) => Shimmer(
                            gradient: LinearGradient(
                                colors: [Colors.grey[200]!, Colors.grey[400]!]),
                            child: Container(
                              color: Colors.red,
                            )),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                        bottom: 10,
                        left: 20,
                        right: 20,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(.2),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.favorite,
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 2),
                              Text('${image.likes}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  )),
                              const SizedBox(
                                width: 12,
                              ),
                              const Icon(
                                Icons.visibility,
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 2),
                              Text('${image.views}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  )),
                            ],
                          ),
                        )),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
