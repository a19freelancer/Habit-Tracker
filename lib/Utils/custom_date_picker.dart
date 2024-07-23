import 'package:flutter/material.dart';

class MultipleDatePickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final List<DateTime> selectedDates;

  MultipleDatePickerDialog({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.selectedDates,
  });

  @override
  _MultipleDatePickerDialogState createState() => _MultipleDatePickerDialogState();
}

class _MultipleDatePickerDialogState extends State<MultipleDatePickerDialog> {
  late List<DateTime> _selectedDates;

  @override
  void initState() {
    super.initState();
    _selectedDates = widget.selectedDates;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Dates'),
      content: Container(
        width: double.maxFinite,
        height: 300,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
          itemBuilder: (context, index) {
            final date = widget.firstDate.add(Duration(days: index));
            final isSelected = _selectedDates.any((selectedDate) =>
            selectedDate.year == date.year &&
                selectedDate.month == date.month &&
                selectedDate.day == date.day);

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedDates.removeWhere((selectedDate) =>
                    selectedDate.year == date.year &&
                        selectedDate.month == date.month &&
                        selectedDate.day == date.day);
                  } else {
                    _selectedDates.add(date);
                  }
                });
              },
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          },
          itemCount: widget.lastDate.difference(widget.firstDate).inDays + 1,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(_selectedDates);
          },
          child: Text('Done'),
        ),
      ],
    );
  }
}
