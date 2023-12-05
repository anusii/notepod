// Elements of DataCell
import 'package:flutter/material.dart';

DataCell dataCell(String text, {bool isBold = false}) {
  return DataCell(
    Text(
      text,
      style: TextStyle(
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      ),
    ),
  );
}
