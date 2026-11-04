import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../core/utils/currency_formatter.dart';

class PdfService {
  static Future<void> generateAndPrintReport(Map<String, dynamic> reportData) async {
    final pdf = pw.Document();

    final companyName = reportData['company_name'] ?? 'CV. Karya Amanah Sejati';
    final projectName = reportData['project_name'] ?? 'Proyek Pengadaan Meja Kursi';
    final target = reportData['funding_target'] != null
        ? double.parse(reportData['funding_target'].toString())
        : 0.0;
    final verified = reportData['total_verified'] != null
        ? double.parse(reportData['total_verified'].toString())
        : 0.0;
    final percentage = reportData['funding_percentage'] != null
        ? double.parse(reportData['funding_percentage'].toString())
        : 0.0;
    final List investors = reportData['investors'] ?? [];

    final dateFormatter = DateFormat('dd MMMM yyyy HH:mm', 'id_ID');
    final formattedDate = dateFormatter.format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(
                    'REKAPITULASI LAPORAN INVESTASI GOTONG ROYONG (IGOTO)',
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    companyName,
                    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    projectName,
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  ),
                ],
              ),
            ),
            pw.Divider(thickness: 1, height: 20),

            // Project Summary
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Target Plafon Proyek:', style: const pw.TextStyle(fontSize: 9)),
                      pw.Text(
                        CurrencyFormatter.format(target),
                        style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Total Dana Terverifikasi:', style: const pw.TextStyle(fontSize: 9)),
                      pw.Text(
                        CurrencyFormatter.format(verified),
                        style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.green800),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Persentase Pendanaan:', style: const pw.TextStyle(fontSize: 9)),
                      pw.Text(
                        CurrencyFormatter.formatPercent(percentage),
                        style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Table of Investors
            pw.Text(
              'Daftar Partisipasi Investor',
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),

            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
              columnWidths: {
                0: const pw.FixedColumnWidth(24),
                1: const pw.FlexColumnWidth(2.5),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(2.2),
                4: const pw.FlexColumnWidth(2.2),
                5: const pw.FixedColumnWidth(55),
              },
              children: [
                // Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('No', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Nama Investor', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Bank & Rekening', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Modal', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Total Return', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Status', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))),
                  ],
                ),
                // Rows
                ...investors.asMap().entries.map((entry) {
                  final idx = entry.key + 1;
                  final item = entry.value;
                  final amount = double.parse(item['amount'].toString());
                  final totalReturn = double.parse(item['total_return'].toString());
                  final status = item['status'].toString();

                  return pw.TableRow(
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('$idx', style: const pw.TextStyle(fontSize: 8))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(item['investor_name'] ?? '-', style: const pw.TextStyle(fontSize: 8))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('${item['bank_name']} - ${item['account_number']}', style: const pw.TextStyle(fontSize: 7))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(CurrencyFormatter.format(amount), style: const pw.TextStyle(fontSize: 8))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(CurrencyFormatter.format(totalReturn), style: const pw.TextStyle(fontSize: 8))),
                      pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(status.toUpperCase(), style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold))),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 24),

            // Footer note
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Dicetak pada: $formattedDate', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                  pw.SizedBox(height: 35),
                  pw.Text('Manajemen CV. Karya Amanah Sejati', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Laporan_IGOTO_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }
}

