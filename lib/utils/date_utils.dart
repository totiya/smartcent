import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../receipt.dart';

class DateUtils {
  // Get unique years and months from receipts
  static Map<int, List<int>> getReceiptMonths(List<Receipt> receipts) {
    Map<int, List<int>> yearMonths = {};
    for (var receipt in receipts) {
      if (receipt.timestamp != null) {
        final year = receipt.timestamp!.year;
        final month = receipt.timestamp!.month;
        if (!yearMonths.containsKey(year)) {
          yearMonths[year] = [];
        }
        if (!yearMonths[year]!.contains(month)) {
          yearMonths[year]!.add(month);
        }
      }
    }
    // Sort years and months
    yearMonths.forEach((year, months) {
      months.sort();
    });
    return Map.fromEntries(
      yearMonths.entries.toList()..sort((a, b) => b.key.compareTo(a.key))
    );
  }

  static Future<void> showYearMonthPicker(
    BuildContext context,
    Map<int, List<int>> yearMonths,
    Function(DateTime) onMonthSelected,
  ) async {
    if (yearMonths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No receipts found to select a month')),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Year'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: yearMonths.length,
            itemBuilder: (context, index) {
              final year = yearMonths.keys.elementAt(index);
              return ListTile(
                title: Text(year.toString()),
                onTap: () {
                  Navigator.pop(context);
                  showMonthPicker(context, year, yearMonths[year]!, onMonthSelected);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  static Future<void> showMonthPicker(
    BuildContext context,
    int year,
    List<int> months,
    Function(DateTime) onMonthSelected,
  ) async {
    if (months.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No months available for this year')),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Month'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: months.length,
            itemBuilder: (context, index) {
              final month = months[index];
              return ListTile(
                title: Text(DateFormat('MMMM').format(DateTime(year, month))),
                onTap: () {
                  onMonthSelected(DateTime(year, month, 1));
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }
} 