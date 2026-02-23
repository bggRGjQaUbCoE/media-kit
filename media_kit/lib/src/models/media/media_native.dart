/// This file is a part of media_kit (https://github.com/media-kit/media-kit).
///
/// Copyright © 2021 & onwards, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
/// Use of this source code is governed by MIT license that can be found in the LICENSE file.
// ignore_for_file: library_private_types_in_public_api
import 'dart:io';
import 'dart:collection';

import 'package:media_kit/src/models/playable.dart';

/// {@template media}
///
/// Media
/// -----
///
/// A [Media] object to open inside a [Player] for playback.
///
/// ```dart
/// final player = Player();
/// final playable = Media('https://user-images.githubusercontent.com/28951144/229373695-22f88f13-d18f-4288-9bf1-c3e078d83722.mp4');
/// await player.open(playable);
/// ```
///
/// {@endtemplate}
class Media extends Playable {
  /// URI of the [Media].
  final String uri;

  /// Additional optional user data.
  ///
  /// Default: `null`.
  final Map<String, dynamic>? extras;

  /// Start position.
  ///
  /// Default: `null`.
  final Duration? start;

  /// End position.
  ///
  /// Default: `null`.
  final Duration? end;

  /// {@macro media}
  Media(String resource, {this.extras, this.start, this.end})
    : uri = normalizeURI(resource);

  /// Normalizes the passed URI.
  static String normalizeURI(String uri) {
    if (uri.startsWith(_kAssetScheme)) {
      // Handle asset:// scheme. Only for Flutter.
      throw UnimplementedError(_kAssetScheme);
    }
    // content:// URI support for Android.
    if (Platform.isAndroid) {
      if (uri.startsWith('content://')) {
        throw UnimplementedError('content://');
      }
    }
    return uri;
  }

  /// For comparing with other [Media] instances.
  @override
  bool operator ==(Object other) {
    if (other is Media) {
      return other.uri == uri;
    }
    return false;
  }

  /// For comparing with other [Media] instances.
  @override
  int get hashCode => uri.hashCode;

  /// Creates a copy of [this] instance with the given fields replaced with the new values.
  Media copyWith({
    String? uri,
    Map<String, dynamic>? extras,
    Duration? start,
    Duration? end,
  }) {
    return Media(
      uri ?? this.uri,
      extras: extras ?? this.extras,
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }

  @override
  String toString() => 'Media($uri, extras: $extras, start: $start, end: $end)';

  /// URI scheme used to identify Flutter assets.
  static const String _kAssetScheme = 'asset://';

  /// Previously created [Media] instances' reference count.
  static final HashMap<String, int> ref = HashMap<String, int>();
}
