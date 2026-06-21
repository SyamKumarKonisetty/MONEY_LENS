import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../features/transactions/domain/models.dart';

/// Premium report exporter for CSV, JSON, and PDF statements sharing.
class ExportService {
  static String _sanitize(String title) {
    return title.replaceAll(' ', '_').toLowerCase();
  }

  /// Exports the given transactions to a CSV format and shares it.
  static Future<void> shareCSV(BuildContext context, String title, List<Transaction> transactions) async {
    try {
      final buffer = StringBuffer();
      buffer.write('\uFEFF'); // UTF-8 BOM
      buffer.writeln('Date,Type,Category,Title,Amount,Notes');

      for (final t in transactions) {
        final dateStr = DateFormat('yyyy-MM-dd HH:mm').format(t.date);
        final typeStr = t.type.name.toUpperCase();
        final catStr = AppCategories.findById(t.categoryId).name;
        final titleClean = t.title.replaceAll('"', '""');
        final notesClean = (t.note ?? '').replaceAll('"', '""');
        buffer.writeln('"$dateStr","$typeStr","$catStr","$titleClean",${t.amount},"$notesClean"');
      }

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/moneylens_report_${_sanitize(title)}.csv');
      await file.writeAsString(buffer.toString());

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'MoneyLens Statement (CSV) - $title',
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to share CSV: $e')));
      }
    }
  }

  /// Exports the given transactions to a JSON format and shares it.
  static Future<void> shareJSON(BuildContext context, String title, List<Transaction> transactions) async {
    try {
      final data = transactions.map((t) {
        return {
          'id': t.id,
          'title': t.title,
          'amount': t.amount,
          'type': t.type.name,
          'category': AppCategories.findById(t.categoryId).name,
          'date': t.date.toIso8601String(),
          'note': t.note,
        };
      }).toList();

      final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/moneylens_report_${_sanitize(title)}.json');
      await file.writeAsString(jsonStr);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'MoneyLens Statement (JSON) - $title',
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to share JSON: $e')));
      }
    }
  }

  /// Exports a beautifully styled PDF summary and transaction list and shares it.
  static Future<void> sharePDF(
    BuildContext context,
    String title,
    List<Transaction> transactions,
    double totalIncome,
    double totalExpenses,
  ) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('MoneyLens Financial Statement', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.Text(DateFormat.yMMMMd().format(DateTime.now())),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Statement Period: $title', style: pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 15),

              // Summary Section
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Total Income', style: const pw.TextStyle(color: PdfColors.green)),
                      pw.Text(CurrencyFormatter.full(totalIncome), style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Total Expenses', style: const pw.TextStyle(color: PdfColors.red)),
                      pw.Text(CurrencyFormatter.full(totalExpenses), style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Net Savings', style: const pw.TextStyle(color: PdfColors.blue)),
                      pw.Text(CurrencyFormatter.full(totalIncome - totalExpenses), style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              pw.Text('Transactions Log', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),

              // Table
              pw.TableHelper.fromTextArray(
                headers: ['Date', 'Type', 'Category', 'Title', 'Amount'],
                data: transactions.map((t) {
                  return [
                    DateFormat('yyyy-MM-dd').format(t.date),
                    t.type.name.toUpperCase(),
                    AppCategories.findById(t.categoryId).name,
                    t.title,
                    CurrencyFormatter.full(t.amount),
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blueAccent),
                cellAlignment: pw.Alignment.centerLeft,
                cellAlignments: {4: pw.Alignment.centerRight},
              ),
            ];
          },
        ),
      );

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/moneylens_report_${_sanitize(title)}.pdf');
      final bytes = await pdf.save();
      await file.writeAsBytes(bytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'MoneyLens Statement (PDF) - $title',
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to share PDF: $e')));
      }
    }
  }
}
