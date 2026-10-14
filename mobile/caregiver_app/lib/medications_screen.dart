import 'package:flutter/material.dart';

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  final List<Map<String, String>> medications = [];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController dosageController = TextEditingController();

  String selectedTime = 'Morning';

  @override
  void dispose() {
    nameController.dispose();
    dosageController.dispose();
    super.dispose();
  }

  void addMedication() => _showMedicationDialog();

  void _showMedicationDialog({int? medicationIndex}) {
    final isEditing = medicationIndex != null;
    final medication = isEditing ? medications[medicationIndex] : null;
    nameController.text = medication?['name'] ?? '';
    dosageController.text = medication?['dosage'] ?? '';
    selectedTime = medication?['time'] ?? 'Morning';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Medication' : 'Add Medication'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: nameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'Medication name',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Enter a medication name.'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: dosageController,
                            decoration: const InputDecoration(
                              labelText: 'Dosage (e.g. 1 tablet)',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Enter the medication dosage.'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            initialValue: selectedTime,
                            decoration: const InputDecoration(
                              labelText: 'Schedule',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Morning',
                                child: Text('Morning'),
                              ),
                              DropdownMenuItem(
                                value: 'Afternoon',
                                child: Text('Afternoon'),
                              ),
                              DropdownMenuItem(
                                value: 'Evening',
                                child: Text('Evening'),
                              ),
                              DropdownMenuItem(
                                value: 'Night',
                                child: Text('Night'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setDialogState(() {
                                  selectedTime = value;
                                });
                              }
                            },
                            validator: (value) => value == null || value.isEmpty
                                ? 'Choose a schedule.'
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }

                    final name = nameController.text.trim();
                    final dosage = dosageController.text.trim();

                    setState(() {
                      final updatedMedication = {
                        'name': name,
                        'dosage': dosage,
                        'time': selectedTime,
                        'taken': medication?['taken'] ?? 'false',
                      };
                      if (isEditing) {
                        medications[medicationIndex] = updatedMedication;
                      } else {
                        medications.add(updatedMedication);
                      }
                    });

                    Navigator.pop(dialogContext);
                  },
                  child: Text(isEditing ? 'Save changes' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medication Management')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Medication Schedule',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('${medications.length} medications added'),
            const SizedBox(height: 16),
            Expanded(
              child: medications.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.medication_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 12),
                          Text('No medications added yet.'),
                          Text('Tap + to add a medication.'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: medications.length,
                      itemBuilder: (context, index) {
                        final medication = medications[index];

                        return Card(
                          child: ListTile(
                            onTap: () =>
                                _showMedicationDialog(medicationIndex: index),
                            leading: const CircleAvatar(
                              child: Icon(Icons.medication),
                            ),
                            title: Text(medication['name']!),
                            subtitle: Text(
                              '${medication['dosage']} • ${medication['time']}'
                              '${medication['taken'] == 'true' ? ' • Taken' : ''}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    medication['taken'] == 'true'
                                        ? Icons.check_circle
                                        : Icons.check_circle_outline,
                                  ),
                                  tooltip: medication['taken'] == 'true'
                                      ? 'Mark dose as not taken'
                                      : 'Mark dose as taken',
                                  onPressed: () {
                                    setState(() {
                                      medication['taken'] =
                                          medication['taken'] == 'true'
                                          ? 'false'
                                          : 'true';
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  tooltip: 'Delete medication',
                                  onPressed: () =>
                                      _confirmDeleteMedication(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addMedication,
        icon: const Icon(Icons.add),
        label: const Text('Add Medication'),
      ),
    );
  }

  Future<void> _confirmDeleteMedication(int index) async {
    final medicationName = medications[index]['name']!;
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete medication?'),
        content: Text('Remove $medicationName from the medication schedule?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      setState(() {
        medications.removeAt(index);
      });
    }
  }
}
