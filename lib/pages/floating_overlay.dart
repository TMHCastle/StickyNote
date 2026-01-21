import 'dart:io';
import '../widgets/custom_reorderable_listener.dart';
import 'dart:ui'; 
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
         
      if (log != null && sourceKey != null) {
        final RenderBox? box =
            sourceKey.currentContext?.findRenderObject() as RenderBox?;
        if (box != null) {
          final offset = box.localToGlobal(Offset.zero);
          final size = box.size;
          _editorTop = offset.dy + size.height;
          _editorBottom = null;
        }
      } else {
        _editorTop = null;
        _editorBottom = 50;
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
                borderRadius: BorderRadius.circular(provider.borderRadius),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), 
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(provider.borderRadius),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.1), width: 1),
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

          // ===== Log List + Footer Button =====
          Positioned.fill(
            top: 52,
            bottom: 12,
            child: IgnorePointer(
              ignoring: provider.locked,
              child: ReorderableListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                // Disable default handles to control which items are draggable
                buildDefaultDragHandles: false, 
                onReorder: provider.reorderLogs,
                itemCount: provider.logs.length + 1, // +1 for Add Button
                itemBuilder: (context, index) {
                  if (index == provider.logs.length) {
                    // === Footer: Add Button ===
                    // Not wrapped in ReorderableDragStartListener -> Not Draggable
                    return Container(
                      key: const ValueKey('add_button_footer'),
                      margin: const EdgeInsets.only(top: 8, bottom: 20),
                      alignment: Alignment.center,
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => _openEditor(null),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.2)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add_circle,
                                        size: 16,
                                        color: Colors.white.withOpacity(0.9)),
                                    const SizedBox(width: 8),
                                    Text(
                                      AppStrings.get(context, 'addLog'),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  
                  final log = provider.logs[index];
                  // Wrapped in listener -> Draggable
                  return CustomReorderableDelayedDragStartListener(
                    key: ValueKey(log.id),
                    index: index,
                    child: Builder( 
                      builder: (ctx) => LogItemWidget(
                        log: log,
                        noteOpacity: provider.noteBgOpacity,
                        fontSize: provider.fontSize,
                        onEdit: (l) {
                          final RenderBox? box =
                              ctx.findRenderObject() as RenderBox?;
                          if (box != null) {
                            final offset = box.localToGlobal(Offset.zero);
                            final size = box.size;
                            setState(() {
                              _editingLog = l;
                              _showEditor = true;
                              _showSettings = false;
                              _editorTop = offset.dy + size.height + 4;
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
                    top: 50,
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

          // ===== Top Left Lock Button =====
          Positioned(
            top: 16,
            left: 16,
            child: GestureDetector(
              onPanStart: (_) => windowManager.startDragging(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      key: _lockButtonKey,
                      onTap: () async {
                        await provider.toggleLocked();
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Colors.white.withOpacity(0.2)),
                          boxShadow: const [
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
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 70,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        provider.locked
                            ? AppStrings.get(context, 'unlockInTray')
                            : AppStrings.get(context, 'clickToLock'),
                        key: ValueKey('lock_text_${provider.locked}'),
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
          
          // ===== Top Right Settings Button =====
          Positioned(
            top: 16,
            right: 16,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
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
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 4)
                    ],
                  ),
                  child: const Icon(
                    Icons.settings,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
