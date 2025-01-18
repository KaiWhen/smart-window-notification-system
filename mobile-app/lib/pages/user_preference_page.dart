import 'package:flutter/material.dart';
import 'package:smart_windows_app/api/sw_api.dart';
import 'package:smart_windows_app/util/helper.dart';

class UserPreferences extends StatefulWidget {
  const UserPreferences({super.key});

  @override
  State<UserPreferences> createState() => _UserPreferencesState();
}

class _UserPreferencesState extends State<UserPreferences> {
  List<bool> selectedDays = List.generate(4, (index) => false);
  List<bool> selectedDays2 = List.generate(3, (index) => false);
  List<int> intervalOptions = [5, 10, 15, 30, 60, 120];
  int selectedIntervalOption = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select days to receive notifications:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Wrap(alignment: WrapAlignment.center, children: [
              ToggleButtons(
                direction: Axis.horizontal,
                onPressed: (int index) {
                  setState(() {
                    selectedDays[index] = !selectedDays[index];
                  });
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                selectedBorderColor: const Color.fromARGB(255, 56, 142, 82),
                selectedColor: Colors.white,
                fillColor: const Color.fromARGB(255, 129, 199, 150),
                color: const Color.fromARGB(255, 102, 187, 120),
                constraints: const BoxConstraints(
                  minHeight: 40.0,
                  minWidth: 80.0,
                ),
                isSelected: selectedDays,
                children: const [
                  Text('Mon'),
                  Text('Tue'),
                  Text('Wed'),
                  Text('Thu'),
                ],
              ),
              ToggleButtons(
                direction: Axis.horizontal,
                onPressed: (int index) {
                  setState(() {
                    selectedDays2[index] = !selectedDays2[index];
                  });
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                selectedBorderColor: const Color.fromARGB(255, 56, 142, 82),
                selectedColor: Colors.white,
                fillColor: const Color.fromARGB(255, 129, 199, 150),
                color: const Color.fromARGB(255, 102, 187, 120),
                constraints: const BoxConstraints(
                  minHeight: 40.0,
                  minWidth: 80.0,
                ),
                isSelected: selectedDays2,
                children: const [
                  Text('Fri'),
                  Text('Sat'),
                  Text('Sun'),
                ],
              )
            ]),
            const SizedBox(height: 20),
            Container(
                height: 40,
                padding: const EdgeInsets.fromLTRB(120, 0, 120, 0),
                child: ElevatedButton(
                  child: const Text('Submit'),
                  onPressed: () async {
                    bool? success = await SmartWindowApi()
                        .setDays(selectedDays + selectedDays2);
                    if (success!) {
                      Helper.showToast("Update success");
                    } else {
                      Helper.showToast("Update failed");
                    }
                  },
                )),
            const SizedBox(height: 20),
            const Text(
              'Only receive notifications every:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(children: [
              const SizedBox(
                width: 10,
              ),
              DropdownButton<int>(
                value: selectedIntervalOption,
                onChanged: (newValue) async {
                  setState(() {
                    selectedIntervalOption = newValue!;
                  });
                  bool? success = await SmartWindowApi()
                      .setInterval(selectedIntervalOption);
                  if (success!) {
                    Helper.showToast("Update success");
                  } else {
                    Helper.showToast("Update failed");
                  }
                },
                items: intervalOptions.map((option) {
                  return DropdownMenuItem<int>(
                    value: option,
                    child: Text('$option minutes'),
                  );
                }).toList(),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
