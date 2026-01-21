import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../providers/log_provider.dart';
import '../widgets/log_item_widget.dart';
import '../utils/app_strings.dart';
import '../services/mouse_polling_service.dart';
import '../widgets/settings_popup.dart';
import '../widgets/log_editor_popup.dart';
import '../models/log_entry.dart';

class FloatingOverlay extends StatefulWidget {
  const FloatingOverlay({super.key});

  @override
  State<FloatingOverlay> createState() => _FloatingOverlayState();
}

class _FloatingOverlayState extends State<FloatingOverlay> {
  final GlobalKey _lockButtonKey = GlobalKey();
  MousePollingService? _pollingService;
  
  bool _showSettings = false; 
  LogEntry? _editingLog; // If non-null (or special flag), show Editor.
  bool _showEditor = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initService();
    });
  }

  void _initService() {
    final provider = context.read<LogProvider>();
    _pollingService = MousePollingService(
      onHoverChanged: (isHovering) {
        provider.setTempUnlock(isHovering);
      },
      getHotArea: () {
        final renderBox =
            _lockButtonKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final offset = renderBox.localToGlobal(Offset.zero);
          final size = renderBox.size;
          return offset & size;
        }
        return Rect.zero;
      },
    );

    provider.addListener(_onLockedChanged);
    if (provider.locked) {
      _pollingService?.start();
    }
  }

  void _onLockedChanged() {
    if (!mounted) return;
    final provider = context.read<LogProvider>();
    if (provider.locked) {
      _pollingService?.start();
    } else {
      _pollingService?.stop();
      provider.setTempUnlock(false); 
    }
  }

  @override
  void dispose() {
    context.read<LogProvider>().removeListener(_onLockedChanged);
    _pollingService?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LogProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ===== Background =====
          Positioned.fill(
            child: Listener(
              onPointerDown: (_) => windowManager.startDragging(),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(provider.borderRadius),
                  image: provider.useBackgroundImage &&
                          provider.backgroundImage != null
                      ? DecorationImage(
                          image: FileImage(File(provider.backgroundImage!)),
                          fit: BoxFit.cover,
                          opacity: provider.bgOpacity,
                        )
                      : null,
                  color: Color(provider.layoutBackgroundColor)
                      .withOpacity(provider.bgOpacity),
                ),
              ),
            ),
          ),

          // ===== Log List =====
          Positioned.fill(
            top: 52,
            bottom: 60, 
            child: IgnorePointer(
              ignoring: provider.locked,
              child: ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                buildDefaultDragHandles: false,
                onReorder: provider.reorderLogs,
                itemCount: provider.logs.length,
                itemBuilder: (context, index) {
                  final log = provider.logs[index];
                  return ReorderableDelayedDragStartListener(
                    key: ValueKey(log.id),
                    index: index,
                    child: LogItemWidget(
                      log: log,
                      noteOpacity: provider.noteBgOpacity,
                      fontSize: provider.fontSize,
                      onEdit: (l) {
                        setState(() {
                          _editingLog = l;
                          _showEditor = true;
                          _showSettings = false; // Close settings if open
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ),

          // ===== Add Log Button (Bottom) =====
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _editingLog = null; // Add mode
                    _showEditor = true;
                    _showSettings = false;
                  });
                },
                icon: Icon(Icons.add,
                    size: 16,
                    color: Colors.white.withOpacity(provider.controlOpacity)),
                label: Text(
                  AppStrings.get(context, 'addLog'),
                  style: TextStyle(
                      color: Colors.white.withOpacity(provider.controlOpacity)),
                ),
                style: TextButton.styleFrom(
                  backgroundColor:
                      Colors.white.withOpacity(0.2 * provider.controlOpacity),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),

          // ===== Settings Popup Layer =====
          if (_showSettings)
            Positioned.fill(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _showSettings = false),
                    behavior: HitTestBehavior.opaque,
                    child: Container(color: Colors.transparent),
                  ),
                  Positioned(
                    top: 80,
                    right: 16,
                    width: 300,
                    child: const SettingsPopup(),
                  ),
                ],
              ),
            ),

          // ===== Log Editor Popup Layer =====
          if (_showEditor)
            Positioned.fill(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _showEditor = false),
                    behavior: HitTestBehavior.opaque,
                    child:
                        Container(color: Colors.black12), // Dimmed background
                  ),
                  Positioned(
                    // Dynamic position: Center or bottom aligned?
                    // User said "adjust position based on existing tags bottom".
                    // If we center it, it's safe.
                    // Or we can put it at the bottom above the button.
                    bottom: 70,
                    left: 16,
                    right: 16,
                    child: LogEditorPopup(
                      log: _editingLog,
                      onClose: () => setState(() => _showEditor = false),
                    ),
                  ),
                ],
              ),
            ),

          // ===== Top Left Lock Button =====
          Positioned(
            top: 16,
            left: 16,
            child: GestureDetector(
              onPanStart: (_) => windowManager.startDragging(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    key: _lockButtonKey,
                    onTap: () async {
                      await provider.toggleLocked();
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.black
                            .withOpacity(0.6 * provider.controlOpacity),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        provider.locked ? Icons.lock : Icons.lock_open,
                        size: 16,
                        color:
                            Colors.white.withOpacity(provider.controlOpacity),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 120,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      switchInCurve: Curves.easeIn,
                      switchOutCurve: Curves.easeOut,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          provider.locked
                              ? AppStrings.get(context, 'unlockInTray')
                              : AppStrings.get(context, 'clickToLock'),
                          key: ValueKey('fill-${provider.locked}'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white
                                .withOpacity(provider.controlOpacity),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // ===== Top Right Settings Button =====
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showSettings = !_showSettings;
                  _showEditor = false; // Close editor if open
                });
              },
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color:
                      Colors.black.withOpacity(0.4 * provider.controlOpacity),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white
                          .withOpacity(0.2 * provider.controlOpacity)),
                ),
                child: Icon(
                  Icons.settings,
                  size: 16,
                  color: Colors.white.withOpacity(provider.controlOpacity),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
