import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatefulWidget {
  const CustomButton({
    super.key,
    required this.text,
    this.onTap,
    this.isLoading,
  });
  final String text;
  final VoidCallback? onTap;
  final bool? isLoading;
  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  final ValueNotifier<double> scale = ValueNotifier<double>(1);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: widget.isLoading ?? false,
      child: ValueListenableBuilder(
        valueListenable: scale,
        builder: (context, scaleValue, child) {
          return GestureDetector(
            onTapUp: (details) {
              scale.value = 1;
              if (widget.onTap != null) {
                return widget.onTap!();
              }
              log('message');
            },
            onTapDown: (details) => scale.value = 0.98,
            onTapCancel: () => scale.value = 1,

            child: AnimatedScale(
              duration: Duration(milliseconds: 100),
              scale: scaleValue,
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: widget.isLoading == true
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            widget.text,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
