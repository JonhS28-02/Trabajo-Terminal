import 'dart:ui';

import 'package:flutter/material.dart';

import '../services/session_service.dart';
import '../theme/app_theme.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';
import 'specialist/patients_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  String _role = '';

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await SessionService.getRole() ?? '';
    if (mounted) setState(() => _role = role);
  }

  List<Widget> get _pages => _role == 'especialista'
      ? [HomeScreen(role: _role), const PatientsScreen(), const ProfileScreen()]
      : [HomeScreen(role: _role), const ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: _LiquidGlassNavBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        isSpecialist: _role == 'especialista',
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

class _LiquidGlassNavBar extends StatelessWidget {
  const _LiquidGlassNavBar({
    required this.currentIndex,
    required this.onTap,
    this.isSpecialist = false,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isSpecialist;

  List<_NavItem> get _items => isSpecialist
      ? const [
          _NavItem(Icons.home_outlined, 'HOME'),
          _NavItem(Icons.people_outline, 'PACIENTES'),
          _NavItem(Icons.person_outline, 'PERFIL'),
        ]
      : const [
          _NavItem(Icons.home_outlined, 'HOME'),
          _NavItem(Icons.person_outline, 'PERFIL'),
        ];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.only(left: 14, right: 14, bottom: bottom + 6, top: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(
            height: 74,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              // Liquid glass: layered translucent fills
              color: const Color(0xFF1A1230).withValues(alpha: 0.55),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.purpleDark.withValues(alpha: 0.25),
                  blurRadius: 24,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Specular highlight along top edge
                Positioned(
                  top: 0,
                  left: 20,
                  right: 20,
                  height: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0),
                          Colors.white.withValues(alpha: 0.12),
                          Colors.white.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
                // Subtle inner gradient for glass depth
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.04),
                          Colors.transparent,
                          AppColors.purpleDark.withValues(alpha: 0.08),
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                ),
                // Nav content
                LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = constraints.maxWidth / _items.length;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Animated liquid glass pill
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOutCubic,
                          left: currentIndex * itemWidth + 8,
                          top: 7,
                          bottom: 7,
                          width: itemWidth - 16,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.purpleDark.withValues(alpha: 0.85),
                                  AppColors.purple.withValues(alpha: 0.65),
                                ],
                              ),
                              border: Border.all(
                                color: AppColors.purple.withValues(alpha: 0.4),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.purple.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  spreadRadius: -2,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Stack(
                                children: [
                                  // Inner glass shine on pill
                                  Positioned(
                                    top: 0,
                                    left: 8,
                                    right: 8,
                                    height: 1,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white.withValues(alpha: 0),
                                            Colors.white.withValues(alpha: 0.2),
                                            Colors.white.withValues(alpha: 0),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Tab items
                        Row(
                          children: List.generate(_items.length, (i) {
                            final selected = i == currentIndex;
                            return Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => onTap(i),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _items[i].icon,
                                      color: selected
                                          ? Colors.white
                                          : Colors.white.withValues(alpha: 0.4),
                                      size: 24,
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      _items[i].label,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 9,
                                        fontWeight: selected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: selected
                                            ? Colors.white
                                            : Colors.white.withValues(alpha: 0.4),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
