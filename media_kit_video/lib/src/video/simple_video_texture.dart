import 'dart:async';
import 'dart:io';

import 'package:flutter/gestures.dart' show DeviceGestureSettings;
import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';

class SimpleVideo extends StatefulWidget {
  final Color fill;
  final VideoController controller;
  final double? aspectRatio;
  final FilterQuality filterQuality;

  const SimpleVideo({
    super.key,
    this.fill = Colors.black,
    required this.controller,
    this.aspectRatio,
    this.filterQuality = FilterQuality.low,
  });

  @override
  State<SimpleVideo> createState() => SimpleVideoState();
}

class SimpleVideoState extends State<SimpleVideo> {
  static final videoMediaQueryData = MediaQueryData(
    gestureSettings: DeviceGestureSettings(touchSlop: Platform.isIOS ? 9 : 4),
  );

  late double _devicePixelRatio;
  late int? _width = widget.controller.player.state.width;
  late int? _height = widget.controller.player.state.height;
  late bool _visible = (_width ?? 0) > 0 && (_height ?? 0) > 0;

  final _subscriptions = <StreamSubscription>[];

  @override
  void initState() {
    super.initState();
    // --------------------------------------------------
    // Do not show the video frame until width & height are available.
    // Since [ValueNotifier<Rect?>] inside [VideoController] only gets updated by the render loop (i.e. it will not fire when video's width & height are not available etc.), it's important to handle this separately here.
    _subscriptions.addAll(
      [
        widget.controller.player.stream.width.listen(
          (value) {
            _width = value;
            final visible = (_width ?? 0) > 0 && (_height ?? 0) > 0;
            if (_visible != visible) {
              _visible = visible;
              widget.controller.notifier.value?.rect.refresh();
            }
          },
        ),
        widget.controller.player.stream.height.listen(
          (value) {
            _height = value;
            final visible = (_width ?? 0) > 0 && (_height ?? 0) > 0;
            if (_visible != visible) {
              _visible = visible;
              widget.controller.notifier.value?.rect.refresh();
            }
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PlatformVideoController?>(
      valueListenable: widget.controller.notifier,
      builder: (context, notifier, _) => notifier == null
          ? const SizedBox.shrink()
          : ListenableBuilder(
              listenable: Listenable.merge([notifier.id, notifier.rect]),
              builder: (context, _) {
                final id = notifier.id.value;
                final rect = notifier.rect.value;
                if (id != null && rect != null && _visible) {
                  return SizedBox(
                    width: widget.aspectRatio == null
                        ? rect.width / _devicePixelRatio
                        : rect.height / _devicePixelRatio * widget.aspectRatio!,
                    height: rect.height / _devicePixelRatio,
                    child: Stack(
                      children: [
                        Texture(
                          textureId: id,
                          filterQuality: widget.filterQuality,
                        ),
                        if (rect.width <= 1.0 && rect.height <= 1.0)
                          Positioned.fill(
                            child: ColoredBox(color: widget.fill),
                          ),
                      ],
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
    );
  }
}

extension on ChangeNotifier {
  @pragma("vm:perfer-inline")
  // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
  void refresh() => notifyListeners();
}
