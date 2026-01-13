import 'package:tray_manager/tray_manager.dart';

Menu _menu = Menu(items: [
  MenuItem(label: '语文'),
  MenuItem(label: '数学', toolTip: '躲不掉的'),
  MenuItem.checkbox(
    label: '英语',
    checked: true,
    onClick: (menuItem) {
      menuItem.checked = !(menuItem.checked == true);
    },
  ),
  MenuItem.separator(),
  MenuItem.submenu(
    key: 'science',
    label: '理科',
    submenu: Menu(items: [
      MenuItem(label: '物理'),
      MenuItem(label: '化学'),
      MenuItem(label: '生物'),
    ]),
  ),
  MenuItem.separator(),
  MenuItem.submenu(
    key: 'arts',
    label: '文科',
    submenu: Menu(items: [
      MenuItem(label: '政治'),
      MenuItem(label: '历史'),
      MenuItem(label: '地理'),
    ]),
  ),
]);
