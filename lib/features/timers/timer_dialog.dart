import 'package:flutter/material.dart';
import '../../data/models.dart';

class TimerSettings {
  final int seconds;
  final String name;
  final int? stepIndex;
  TimerSettings({
    required this.seconds,
    required this.name,
    this.stepIndex,
  });
}

class TimerInstance {
  final int originalSeconds;
  int remainingSeconds;
  final String name;
  final int? stepIndex;
  bool isRunning;
  TimerInstance({
    required this.originalSeconds,
    required this.remainingSeconds,
    required this.name,
    required this.stepIndex,
    this.isRunning = true,
  });
}

class TimerDialog extends StatefulWidget {
  final String Function(String) t;
  final List<String> steps;
  const TimerDialog({required this.t, required this.steps});

  @override
  State<TimerDialog> createState() => _TimerDialogState();
}

class _TimerDialogState extends State<TimerDialog> {
  final _nameCtrl = TextEditingController();
  final _customTimeCtrl = TextEditingController();
  int? _selectedSeconds;
  int? _selectedStepIndex;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _customTimeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final presetTimers = [
      {'label': '1 min', 'seconds': 60},
      {'label': '5 min', 'seconds': 300},
      {'label': '10 min', 'seconds': 600},
      {'label': '15 min', 'seconds': 900},
    ];

    return AlertDialog(
      title: Text(t('start_timer')),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: InputDecoration(labelText: t('timer_name')),
            ),
            const SizedBox(height: 12),
            Text(
              t('quick_timers'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8,
              children: presetTimers.map((preset) {
                return ChoiceChip(
                  label: Text(preset['label'] as String),
                  selected: _selectedSeconds == preset['seconds'],
                  onSelected: (_) => setState(() {
                    _selectedSeconds = preset['seconds'] as int;
                    _customTimeCtrl.clear();
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _customTimeCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: t('custom_timer'),
                suffixText: t('seconds'),
              ),
              onChanged: (value) => setState(() {
                _selectedSeconds = int.tryParse(value);
              }),
            ),
            const SizedBox(height: 12),
            if (widget.steps.isNotEmpty)
              DropdownButton<int>(
                isExpanded: true,
                value: _selectedStepIndex,
                hint: Text(t('no_step')),
                items: [
                  DropdownMenuItem<int>(
                    value: null,
                    child: Text(t('no_step')),
                  ),
                  ...widget.steps.asMap().entries.map((entry) {
                    return DropdownMenuItem<int>(
                      value: entry.key,
                      child: Text('Step ${entry.key + 1}: ${entry.value}'),
                    );
                  }),
                ],
                onChanged: (int? value) => setState(() {
                  _selectedStepIndex = value;
                }),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t('cancel')),
        ),
        FilledButton(
          onPressed: _selectedSeconds == null || _selectedSeconds! <= 0
              ? null
              : () {
                  Navigator.pop(
                    context,
                    TimerSettings(
                      seconds: _selectedSeconds!,
                      name: _nameCtrl.text.trim().isEmpty
                          ? (_selectedStepIndex != null
                              ? 'Step ${_selectedStepIndex! + 1}'
                              : t('timer_name'))
                          : _nameCtrl.text.trim(),
                      stepIndex: _selectedStepIndex,
                    ),
                  );
                },
          child: Text(t('start_timer')),
        ),
      ],
    );
  }
}
