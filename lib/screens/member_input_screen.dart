import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:laserauth/cubit/login_cubit.dart';
import 'package:virtual_keyboard_custom_layout/virtual_keyboard_custom_layout.dart';

const List<List> _englishLayout = [
  // Row 1
  ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
  // Row 2
  ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', 'BACKSPACE'],
  // Row 3
  ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'', 'RETURN'],
  // Row 4
  ['SHIFT', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 'SHIFT'],
  // Row 5
  ['SWITCHLANGUAGE', '@', 'SPACE', '&', '_'],
];

const List<List> _germanLayout = [
  // Row 1
  ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
  // Row 2
  ['q', 'w', 'e', 'r', 't', 'z', 'u', 'i', 'o', 'p', 'ü', 'BACKSPACE'],
  // Row 3
  ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'ö', 'ä', 'RETURN'],
  // Row 4
  ['SHIFT', 'y', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', '-', 'SHIFT'],
  // Row 5
  ['SWITCHLANGUAGE', '@', 'SPACE', '&', '_'],
];

class MemberInputScreen extends StatefulWidget {
  const MemberInputScreen({super.key});

  @override
  State<MemberInputScreen> createState() => _MemberInputScreenState();
}

class _MemberInputScreenState extends State<MemberInputScreen> {
  String _text = '';
  bool _shiftEnabled = false;
  bool _germanLayoutActive = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Member nickname:',
          style: theme.textTheme.labelMedium,
        ),
        Text(_text, style: theme.textTheme.displayLarge),
        VirtualKeyboard(
          type: VirtualKeyboardType.Custom,
          textColor: Colors.white,
          keys: _germanLayoutActive ? _germanLayout : _englishLayout,
          onKeyPress: (VirtualKeyboardKey key) {
            if (key.keyType == VirtualKeyboardKeyType.String && key.text != null) {
              setState(() {
                _text += _shiftEnabled ? key.text!.toUpperCase() : key.text!;
              });
            } else if (key.keyType == VirtualKeyboardKeyType.Action) {
              switch (key.action) {
                case VirtualKeyboardKeyAction.Backspace:
                  setState(() {
                    _text = _text.substring(0, _text.length - 1);
                  });
                case VirtualKeyboardKeyAction.Return:
                  context.read<LoginCubit>().loginMember(memberName: _text);
                case VirtualKeyboardKeyAction.Space:
                  if (key.text != null) {
                    setState(() {
                      _text += key.text!;
                    });
                  }
                case VirtualKeyboardKeyAction.Shift:
                  setState(() {
                    _shiftEnabled = !_shiftEnabled;
                  });
                case null:
                // ignore
                case VirtualKeyboardKeyAction.SwitchLanguage:
                  setState(() {
                    _germanLayoutActive = !_germanLayoutActive;
                  });
              }
            }
          },
        ),
      ],
    );
  }
}
