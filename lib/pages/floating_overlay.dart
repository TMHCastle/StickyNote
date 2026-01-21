import 'dart:io';
import 'dart:ui'; // For BackdropFilter
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
  LogEntry? _editingLog; 
  bool _showEditor = false;
  
  // Editor Position
  double? _editorTop;
  double? _editorBottom;

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
  
  void _openEditor(LogEntry? log, {GlobalKey? sourceKey}) {
    setState(() {
      _editingLog = log;
      _showEditor = true;
      _showSettings = false;

      // Calculate position
      if (log != null && sourceKey != null) {
        final RenderBox? box =
            sourceKey.currentContext?.findRenderObject() as RenderBox?;
        if (box != null) {
          // Get local position in the overlay stack?
          // The Overlay stack fills the screen (or window).
          // localToGlobal gives absolute.
          // We need relative to the Stack. Since Stack fills screen, global is fine.
          final offset = box.localToGlobal(Offset.zero);
          final size = box.size;

          // Target position: Immediately below the note.
          // We need to account for the window height to ensure it fits?
          // For now, simpler: Set top to offset.dy + size.height
          _editorTop = offset.dy + size.height;
          _editorBottom = null;
        }
      } else {
        // Add Mode: "Below the last note".
        // Finding the last note position is hard dynamically.
        // But we know the "Add" button is at the bottom.
        // The user wants it "sticking to the last note".
        // If we can't easily get the last note, putting it above the Add button
        // or effectively at the bottom of the list is a good approximation.
        // Let's position it at the bottom of the visible list area.
        _editorTop = null;
        _editorBottom = 60; // Just above the bottom bar area
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LogProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ===== Background with Blur =====
          Positioned.fill(
            child: Listener(
              onPointerDown: (_) => windowManager.startDragging(),
              child: ClipRRect(
                // Clip for blur
                borderRadius: BorderRadius.circular(provider.borderRadius),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: 10, sigmaY: 10), // Glassmorphism blur
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(provider.borderRadius),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1), // Thin glassy border
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
            ),
          ),

          // ===== Log List =====
          Positioned.fill(
            top: 52,
            bottom: 60, 
            child: IgnorePointer(
              ignoring: provider.locked,
              child: ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8), // More padding
                buildDefaultDragHandles: false,
                onReorder: provider.reorderLogs,
                itemCount: provider.logs.length,
                itemBuilder: (context, index) {
                  final log = provider.logs[index];
                  final GlobalKey itemKey =
                      GlobalKey(); // Unique key for position?
                  // Creating GlobalKey in build is suboptimal (recreates every frame),
                  // but we need a reference.
                  // Better: pass the context from the callback.
                  // Revised LogItemWidget to accept GlobalKey? No.
                  // We'll use a wrapper.
                  return Container(
                    key: ValueKey(log.id), // Reorderable needs Key
                    child: Builder(
                      // Builder to get context
                      builder: (ctx) => LogItemWidget(
                        log: log,
                        noteOpacity: provider.noteBgOpacity,
                        fontSize: provider.fontSize,
                        onEdit: (l) {
                          // Use ctx to find render object
                          final RenderBox? box =
                              ctx.findRenderObject() as RenderBox?;
                          // Pass box info? Or just calculate here.
                          // Getting offset here is safe.
                          if (box != null) {
                            final offset = box.localToGlobal(Offset.zero);
                            final size = box.size;
                            setState(() {
                              _editingLog = l;
                              _showEditor = true;
                              _showSettings = false;
                              _editorTop =
                                  offset.dy + size.height + 4; // + spacing
                              _editorBottom = null;
                            });
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ===== Add Log Button (Bottom) (Styled) =====
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: TextButton.icon(
                    onPressed: () => _openEditor(null),
                    icon: Icon(Icons.add_circle, // More prominent icon
                        size: 18,
                        color: Colors.white.withOpacity(0.9)),
                    label: Text(
                      AppStrings.get(context, 'addLog'),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      side: BorderSide(color: Colors.white.withOpacity(0.2)),
                    ),
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
                    child: Container(color: Colors.black12),
                  ),
                  Positioned(
                    top: _editorTop,
                    bottom: _editorBottom,
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

          // ===== Top Left Lock Button (Glassy) =====
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
                      width: 32, height: 32, // Slightly larger
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.white.withOpacity(0.2)),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 4)
                        ],
                      ),
                      child: Icon(
                        provider.locked ? Icons.lock : Icons.lock_open,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 120,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: provider.locked
                          ? const SizedBox()
                          : Text(
                              AppStrings.get(context, 'clickToLock'),
                              key: const ValueKey('hint'),
                          style: TextStyle(
                                fontSize: 14,
                            fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.8),
                                shadows: [
                                  Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 2)
                                ],
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // ===== Top Right Settings Button (Glassy) =====
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showSettings = !_showSettings;
                  _showEditor = false;
                });
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: const Icon(
                  Icons.settings,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
