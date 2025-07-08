import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

// class CustomImageProvider extends ImageProvider<CustomImageProvider> {
//   final String? imageUrl;
//   final String defaultImagePath;
//
//   CustomImageProvider({
//     required this.imageUrl,
//     this.defaultImagePath = 'assets/default_image.png',
//   });
//
//   @override
//   ImageStreamCompleter loadBuffer(ImageProvider key, DecoderBufferCallback decode) {
//     if (imageUrl == null || imageUrl!.isEmpty) {
//       return AssetImage(defaultImagePath).resolve(ImageConfiguration.empty);
//     } else {
//       return CachedNetworkImageProvider(imageUrl!).loadBuffer(key, decode);
//     }
//   }
//
//   @override
//   Future<CustomImageProvider> obtainKey(ImageConfiguration configuration) {
//     return SynchronousFuture<CustomImageProvider>(this);
//   }
//
//   @override
//   bool operator ==(Object other) {
//     if (other.runtimeType != runtimeType) return false;
//     return other is CustomImageProvider &&
//         other.imageUrl == imageUrl &&
//         other.defaultImagePath == defaultImagePath;
//   }
//
//   @override
//   int get hashCode => Object.hash(imageUrl, defaultImagePath);
// }
