import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'navigation_bar_item.dart';

const double DEFAULT_BAR_HEIGHT = 60;

const double DEFAULT_INDICATOR_HEIGHT = 2;

// ignore: must_be_immutable
class TitledBottomNavigationBar extends StatefulWidget {
  final bool reverse;
  final Curve curve;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? inactiveTextColor;
  final Color? inactiveStripColor;
  final Color? indicatorColor;
  final bool enableShadow;
  final bool staticWidget;
  final bool hideActiveIndicator;
  final int? overrideActiveIndicator;
  int currentIndex;

  /// Called when a item is tapped.
  ///
  /// This provide the selected item's index.
  final ValueChanged<int> onTap;

  /// The items of this navigation bar.
  ///
  /// This should contain at least two items and five at most.
  final List<TitledNavigationBarItem> items;

  /// The selected item is indicator height.
  ///
  /// Defaults to [DEFAULT_INDICATOR_HEIGHT].
  final double indicatorHeight;

  /// Change the navigation bar's size.
  ///
  /// Defaults to [DEFAULT_BAR_HEIGHT].
  final double height;

  TitledBottomNavigationBar({
    Key? key,
    this.reverse = false,
    this.curve = Curves.linear,
    required this.onTap,
    required this.items,
    this.activeColor,
    this.inactiveColor,
    this.inactiveStripColor,
    this.indicatorColor,
    this.inactiveTextColor,
    this.enableShadow = true,
    this.staticWidget = false,
    this.hideActiveIndicator = false,
    this.overrideActiveIndicator,
    this.currentIndex = 0,
    this.height = DEFAULT_BAR_HEIGHT,
    this.indicatorHeight = DEFAULT_INDICATOR_HEIGHT,
  })  : assert(items.length >= 2 && items.length <= 5),
        super(key: key);

  @override
  State createState() => _TitledBottomNavigationBarState();
}

class _TitledBottomNavigationBarState extends State<TitledBottomNavigationBar> {
  bool get reverse => widget.reverse;

  Curve get curve => widget.curve;

  List<TitledNavigationBarItem> get items => widget.items;

  double width = 0;
  Color? activeColor;
  Duration duration = Duration(milliseconds: 270);

  double _getIndicatorPosition(int index) {
    var isLtr = Directionality.of(context) == TextDirection.ltr;
    if (isLtr)
      return lerpDouble(-1.0, 1.0, index / (items.length - 1))!;
    else
      return lerpDouble(1.0, -1.0, index / (items.length - 1))!;
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    activeColor = widget.activeColor ?? Theme.of(context).indicatorColor;

    return Container(
      height: widget.height + MediaQuery.of(context).viewPadding.bottom,
      width: width,
      decoration: BoxDecoration(
        color: widget.inactiveStripColor ?? Theme.of(context).cardColor,
        boxShadow: widget.enableShadow
            ? [
                BoxShadow(color: Colors.black12, blurRadius: 10),
              ]
            : null,
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: widget.indicatorHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: items.map((item) {
                var index = items.indexOf(item);
                return GestureDetector(
                  onTap: () {
                    return _select(index);
                  },
                  child: widget.staticWidget
                      ? _buildStaticItemWidget(
                          item, index == widget.currentIndex)
                      : _buildItemWidget(item, index == widget.currentIndex),
                );
              }).toList(),
            ),
          ),
          if (!widget.hideActiveIndicator)
            Positioned(
              top: 0,
              width: width,
              child: AnimatedAlign(
                alignment: Alignment(
                    _getIndicatorPosition(
                        widget.overrideActiveIndicator ?? widget.currentIndex),
                    0),
                curve: curve,
                duration: duration,
                child: Container(
                  width: width / items.length,
                  // width: 48,
                  height: widget.indicatorHeight,
                  child: Center(
                    child: Container(
                      width: 48,
                      decoration: BoxDecoration(
                          color: widget.indicatorColor ?? activeColor,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(100),
                              bottomRight: Radius.circular(100))),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _select(int index) {
    widget.currentIndex = index;
    widget.onTap(widget.currentIndex);

    setState(() {});
  }

  Widget _buildIcon(TitledNavigationBarItem item) {
    return IconTheme(
      data: IconThemeData(
        color: reverse ? widget.inactiveColor : activeColor,
      ),
      child: item.icon,
    );
  }

  Widget _buildText(TitledNavigationBarItem item) {
    return DefaultTextStyle.merge(
      child: item.title,
      style: TextStyle(color: reverse ? activeColor : widget.inactiveColor),
    );
  }

  Widget _buildIconText(TitledNavigationBarItem item, bool active) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconTheme(
          data: IconThemeData(
            color: active ? activeColor : widget.inactiveColor,
          ),
          child: item.icon,
        ),
        SizedBox(height: 6),
        DefaultTextStyle.merge(
          child: item.title,
          style:
              TextStyle(color: active ? activeColor : widget.inactiveTextColor),
        )
      ],
    );
  }

  Widget _buildItemWidget(TitledNavigationBarItem item, bool isSelected) {
    return Container(
      color: item.backgroundColor,
      height: widget.height,
      width: width / items.length,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          AnimatedOpacity(
            opacity: isSelected ? 0.0 : 1.0,
            duration: duration,
            curve: curve,
            child: reverse ? _buildIcon(item) : _buildText(item),
          ),
          AnimatedAlign(
            duration: duration,
            alignment: isSelected ? Alignment.center : Alignment(0, 5.2),
            child: reverse ? _buildText(item) : _buildIcon(item),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticItemWidget(TitledNavigationBarItem item, bool isSelected) {
    return Container(
        color: item.backgroundColor,
        height: widget.height,
        width: width / items.length,
        child: widget.hideActiveIndicator
            ? _buildIconText(item, false)
            : isSelected
                ? _buildIconText(item, true)
                : _buildIconText(item, false));
  }
}
