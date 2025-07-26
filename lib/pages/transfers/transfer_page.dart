import 'package:flutter/material.dart';
import 'package:pocket_eleven/components/option_button.dart';
import 'package:pocket_eleven/components/custom_appbar.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/pages/transfers/class/scouting_view.dart';
import 'package:pocket_eleven/pages/transfers/class/transfers_view.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({super.key, required this.onCurrencyChange});
  final VoidCallback onCurrencyChange;

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  // Cache expensive computations
  static const List<String> _tabLabels = ['Transfers', 'Scouting'];
  static const double _horizontalPadding = 0.04;
  static const double _verticalPadding = 0.02;
  static const double _buttonSpacing = 0.04;

  int _selectedIndex = 0;
  late final List<Widget> _pages;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  // Cache screen dimensions
  Size? _cachedScreenSize;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller for smooth transitions
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Pre-initialize pages to avoid rebuilding
    _pages = [
      const TransfersView(),
      ScoutingView(onCurrencyChange: widget.onCurrencyChange),
    ];

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  Size _getScreenSize(BuildContext context) {
    return _cachedScreenSize ??= MediaQuery.of(context).size;
  }

  void _onOptionSelected(int index) {
    if (_selectedIndex == index) return; // Avoid unnecessary rebuilds

    setState(() {
      _selectedIndex = index;
    });

    // Smooth transition animation
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final Size screenSize = _getScreenSize(context);
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

    return Scaffold(
      appBar: ReusableAppBar(),
      body: RepaintBoundary(
        child: Container(
          color: AppColors.primaryColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with tab buttons
              _buildHeaderSection(screenWidth, screenHeight),

              // Content area with optimized transitions
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: RepaintBoundary(
                    child: IndexedStack(
                      index: _selectedIndex,
                      children: _pages,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(double screenWidth, double screenHeight) {
    return RepaintBoundary(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * _horizontalPadding,
          vertical: screenHeight * _verticalPadding,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < _tabLabels.length; i++) ...[
              if (i > 0) SizedBox(width: screenWidth * _buttonSpacing),
              OptionButton(
                index: i,
                text: _tabLabels[i],
                onTap: () => _onOptionSelected(i),
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                selectedIndex: _selectedIndex,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
