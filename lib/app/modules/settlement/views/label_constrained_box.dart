import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// ignore: depend_on_referenced_packages
import 'package:print_image_generate_tool/print_image_generate_tool.dart';


///标签固定大小限制的容器 (生成尺寸 45 * 70 的标签)
class LabelConstrainedBox extends StatelessWidget with ATempWidget {
  final Widget child;
  final double pagerWidth;
  final double pagerHeight;

  const LabelConstrainedBox(this.child, {Key? key, this.pagerWidth = 384, this.pagerHeight = 232}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 384/8纸宽度 232、8纸高度 mm
    return Container(
      color: Colors.white,
      width: ScreenUtil().setWidth(pagerWidth),
      height: pagerHeight.w,
      child: ColorFiltered(
        colorFilter: const ColorFilter.mode(
          Colors.black,
          BlendMode.srcIn,
        ),
        child: child,
      ),
    );
  }

  @override
  int get pixelPagerWidth => 384;

  @override
  int get pixelPagerHeight => 232;

  @override
  double get pixelRatio => 1 / 1.w;
}
