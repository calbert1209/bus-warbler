import 'package:bus_warbler/models/schedule_stop.dart';
import 'package:bus_warbler/state/app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bus_warbler/extensions/indexed_map.dart';

class BottomNavTextBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final typeIndex = appState.stopType.index;
    return BottomNavigationBar(
      items: ['平', '土', '祝']
          .indexedMap(
            (item, index) => TextNavBarItem(item, selected: typeIndex == index),
          )
          .toList(),
      currentIndex: appState.stopType.index,
      backgroundColor: Colors.grey.shade900,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap: (index) => appState.stopType = StopType.values[index],
    );
  }
}

class TextNavBarItem extends BottomNavigationBarItem {
  TextNavBarItem(String text, {Key? key, bool? selected})
      : super(
          icon: Text(
            text,
            style: TextStyle(
              color: selected != null && selected
                  ? Colors.green.shade300
                  : Colors.grey.shade800,
              fontSize: 24.0,
              fontFamily: 'MPlusRounded',
              fontWeight: FontWeight.w900,
            ),
          ),
          label: text,
        );
}
