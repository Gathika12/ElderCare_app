import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReceiptPage extends StatelessWidget {
  final String billId;
  final String elderId;
  final String paymentType;
  final String service;
  final double amount;
  final String paidBy;
  final String date;

  const ReceiptPage({
    Key? key,
    required this.billId,
    required this.elderId,
    required this.paymentType,
    required this.service,
    required this.amount,
    required this.paidBy,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Receipt'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        color: Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildHeader(), // Add the header
                Divider(color: Colors.grey),
                SizedBox(height: 10),
                _buildDetailTable(),
                SizedBox(height: 20),
                Divider(color: Colors.grey),
                Center(
                  child: Text(
                    'Thank you for choosing ElderCare Services!',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () => generatePdf(context),
                    child: Text('Print Receipt'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo and company details on the left
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/logo.png', // Add your logo here
              height: 80,
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ElderCare (PVT) LTD',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '"Care Today, Ease Tomorrow."',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'No.69 Kandy Road, Gelioya.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  'Contact: 0763480192 / 0706917676',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ],
        ),
        // INVOICE label on the right
        Text(
          'INVOICE',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailTable() {
    return Table(
      border: TableBorder.all(color: Colors.grey, width: 1),
      children: [
        _buildTableRow('Field', 'Details', isHeader: true),
        _buildTableRow('Receipt ID', billId),
        _buildTableRow('Elder ID', elderId),
        _buildTableRow('Payment Type', paymentType),
        _buildTableRow('Service', service),
        _buildTableRow('Amount', '\$${amount.toStringAsFixed(2)}'),
        _buildTableRow('Paid By', paidBy),
        _buildTableRow('Date', date),
        _buildTableRow('Total', '\$${amount.toStringAsFixed(2)}',
            isTotal: true),
      ],
    );
  }

  TableRow _buildTableRow(String label, String value,
      {bool isHeader = false, bool isTotal = false}) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            label,
            style: TextStyle(
              fontWeight:
                  isHeader || isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isHeader || isTotal ? 16 : 14,
              color: isHeader
                  ? Colors.white
                  : isTotal
                      ? Colors.teal
                      : Colors.black,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            value,
            style: TextStyle(
              fontWeight:
                  isHeader || isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isHeader || isTotal ? 16 : 14,
              color: isHeader
                  ? Colors.white
                  : isTotal
                      ? Colors.teal
                      : Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> generatePdf(BuildContext context) async {
    final Uint8List logoData = await _loadLogo();
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.all(16),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              buildPdfHeader(logoData), // Add the header
              pw.Divider(color: PdfColors.grey),
              pw.SizedBox(height: 10),
              buildPdfTable(),
              pw.SizedBox(height: 20),
              pw.Divider(color: PdfColors.grey),
              pw.Center(
                child: pw.Text(
                  'Thank you for choosing ElderCare Services!',
                  style: pw.TextStyle(
                    fontStyle: pw.FontStyle.italic,
                    fontSize: 14,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget buildPdfHeader(Uint8List logoData) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Image(
              pw.MemoryImage(logoData),
              height: 50,
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'IMAGE SUPPLIERS (PVT) LTD',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              '"LEADING IN COPIER BUSINESS"',
              style: pw.TextStyle(
                fontSize: 14,
                fontStyle: pw.FontStyle.italic,
                color: PdfColors.grey700,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'No.69 Kandy Road, Gelioya.',
              style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
            pw.Text(
              'Contact: 0763480192 / 0706917676',
              style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
          ],
        ),
        pw.Text(
          'INVOICE',
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  pw.Widget buildPdfTable() {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey, width: 1),
      children: [
        _buildPdfTableRow('Field', 'Details', isHeader: true),
        _buildPdfTableRow('Receipt ID', billId),
        _buildPdfTableRow('Elder ID', elderId),
        _buildPdfTableRow('Payment Type', paymentType),
        _buildPdfTableRow('Service', service),
        _buildPdfTableRow('Amount', '\$${amount.toStringAsFixed(2)}'),
        _buildPdfTableRow('Paid By', paidBy),
        _buildPdfTableRow('Date', date),
        _buildPdfTableRow('Total', '\$${amount.toStringAsFixed(2)}',
            isTotal: true),
      ],
    );
  }

  pw.TableRow _buildPdfTableRow(String label, String value,
      {bool isHeader = false, bool isTotal = false}) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: pw.EdgeInsets.all(8.0),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: isHeader || isTotal
                  ? pw.FontWeight.bold
                  : pw.FontWeight.normal,
              fontSize: isHeader || isTotal ? 16 : 14,
              color: isHeader
                  ? PdfColors.white
                  : isTotal
                      ? PdfColors.teal
                      : PdfColors.black,
            ),
          ),
        ),
        pw.Padding(
          padding: pw.EdgeInsets.all(8.0),
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontWeight: isHeader || isTotal
                  ? pw.FontWeight.bold
                  : pw.FontWeight.normal,
              fontSize: isHeader || isTotal ? 16 : 14,
              color: isHeader
                  ? PdfColors.white
                  : isTotal
                      ? PdfColors.teal
                      : PdfColors.black,
            ),
          ),
        ),
      ],
    );
  }

  Future<Uint8List> _loadLogo() async {
    final ByteData data = await rootBundle.load('assets/images/logo.png');
    return data.buffer.asUint8List();
  }
}
