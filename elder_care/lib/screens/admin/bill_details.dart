import 'package:flutter/material.dart';
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8.0,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Text(
                      'Your Company Logo',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'ElderCare Services',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    Divider(color: Colors.grey),
                  ],
                ),
              ),
              SizedBox(height: 10),
              _buildDetailRow('Receipt ID:', billId),
              _buildDetailRow('Elder ID:', elderId),
              _buildDetailRow('Payment Type:', paymentType),
              _buildDetailRow('Service:', service),
              _buildDetailRow('Amount:', '\$${amount.toStringAsFixed(2)}'),
              _buildDetailRow('Paid By:', paidBy),
              _buildDetailRow('Date:', date),
              SizedBox(height: 20),
              Divider(color: Colors.grey),
              Center(
                child: Text(
                  'Thank you for using ElderCare Services!',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () => generatePdf(context), // Call to generate PDF
                  child: Text('Print Receipt'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(value, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Future<void> generatePdf(BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.all(16),
        build: (pw.Context context) {
          return pw.Container(
            padding: pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'Your Company Logo',
                        style: pw.TextStyle(
                            fontSize: 20, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'ElderCare Services',
                        style: pw.TextStyle(
                            fontSize: 16, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Divider(color: PdfColors.grey),
                    ],
                  ),
                ),
                pw.SizedBox(height: 10),
                _buildDetailRowPdf('Receipt ID:', billId),
                _buildDetailRowPdf('Elder ID:', elderId),
                _buildDetailRowPdf('Payment Type:', paymentType),
                _buildDetailRowPdf('Service:', service),
                _buildDetailRowPdf('Amount:', '\$${amount.toStringAsFixed(2)}'),
                _buildDetailRowPdf('Paid By:', paidBy),
                _buildDetailRowPdf('Date:', date),
                pw.SizedBox(height: 20),
                pw.Divider(color: PdfColors.grey),
                pw.Center(
                  child: pw.Text(
                    'Thank you for using ElderCare Services!',
                    style: pw.TextStyle(
                        fontStyle: pw.FontStyle.italic, fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  pw.Widget _buildDetailRowPdf(String label, String value) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 4.0),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
          ),
          pw.Text(value, style: pw.TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
