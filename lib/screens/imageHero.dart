
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageHero extends StatefulWidget {
  final List<Image> images;
  final List<String> tags;


  ImageHero(this.images, this.tags);

  @override
  _ImageHeroState createState() => _ImageHeroState(images,tags);
}

class _ImageHeroState extends State<ImageHero> {

  List<Image> images;
  List<String> tags;

  _ImageHeroState(this.images, this.tags);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          builder: (BuildContext context, int index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: images[index].image,
              heroAttributes: PhotoViewHeroAttributes(tag: tags[index]),
            );
          },
          itemCount: images.length,
        )
      ),
    );
  }
}
