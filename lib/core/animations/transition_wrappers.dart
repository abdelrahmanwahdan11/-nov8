import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class FadeThroughPage extends PageRouteBuilder {
  FadeThroughPage({required this.builder})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeThroughTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          },
        );

  final WidgetBuilder builder;
}

class SharedAxisPageRoute extends PageRouteBuilder {
  SharedAxisPageRoute({required this.builder, this.axis = SharedAxisTransitionType.horizontal})
      : super(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SharedAxisTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              transitionType: axis,
              child: child,
            );
          },
        );

  final WidgetBuilder builder;
  final SharedAxisTransitionType axis;
}
