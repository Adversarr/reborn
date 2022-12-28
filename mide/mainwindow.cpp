#include "mainwindow.h"
#include "./ui_mainwindow.h"
#include "asmer.h"
#include <QDebug>
#include <QFileDialog>
Highlighter::Highlighter(QTextDocument *parent) : QSyntaxHighlighter(parent) {
  HighlightingRule rule;

  keywordFormat.setForeground(Qt::darkBlue);
  keywordFormat.setFontWeight(QFont::Bold);
  const QString keywordPatterns[] = {
      QStringLiteral("\\bchar\\b"),      QStringLiteral("\\bclass\\b"),
      QStringLiteral("\\bconst\\b"),     QStringLiteral("\\bdouble\\b"),
      QStringLiteral("\\benum\\b"),      QStringLiteral("\\bexplicit\\b"),
      QStringLiteral("\\bfriend\\b"),    QStringLiteral("\\binline\\b"),
      QStringLiteral("\\bint\\b"),       QStringLiteral("\\blong\\b"),
      QStringLiteral("\\bnamespace\\b"), QStringLiteral("\\boperator\\b"),
      QStringLiteral("\\bprivate\\b"),   QStringLiteral("\\bprotected\\b"),
      QStringLiteral("\\bpublic\\b"),    QStringLiteral("\\bshort\\b"),
      QStringLiteral("\\bsignals\\b"),   QStringLiteral("\\bsigned\\b"),
      QStringLiteral("\\bslots\\b"),     QStringLiteral("\\bstatic\\b"),
      QStringLiteral("\\bstruct\\b"),    QStringLiteral("\\btemplate\\b"),
      QStringLiteral("\\btypedef\\b"),   QStringLiteral("\\btypename\\b"),
      QStringLiteral("\\bunion\\b"),     QStringLiteral("\\bunsigned\\b"),
      QStringLiteral("\\bvirtual\\b"),   QStringLiteral("\\bfor\\b"),
      QStringLiteral("\\bif\\b"),        QStringLiteral("\\belse\\b"),
      QStringLiteral("\\bvoid\\b"),      QStringLiteral("\\bvolatile\\b"),
      QStringLiteral("\\bbool\\b")};
  for (const QString &pattern : keywordPatterns) {
    rule.pattern = QRegularExpression(pattern);
    rule.format = keywordFormat;
    highlightingRules.append(rule);
  }
  classFormat.setFontWeight(QFont::Bold);
  classFormat.setForeground(Qt::darkMagenta);
  rule.pattern = QRegularExpression(QStringLiteral("\\bQ[A-Za-z]+\\b"));
  rule.format = classFormat;
  highlightingRules.append(rule);
  quotationFormat.setForeground(Qt::darkGreen);
  rule.pattern = QRegularExpression(QStringLiteral("\".*\""));
  rule.format = quotationFormat;
  highlightingRules.append(rule);
  functionFormat.setFontItalic(true);
  functionFormat.setForeground(Qt::blue);
  rule.pattern = QRegularExpression(QStringLiteral("\\b[A-Za-z0-9_]+(?=\\()"));
  rule.format = functionFormat;
  highlightingRules.append(rule);
  singleLineCommentFormat.setForeground(Qt::red);
  rule.pattern = QRegularExpression(QStringLiteral("//[^\n]*"));
  rule.format = singleLineCommentFormat;
  highlightingRules.append(rule);
  multiLineCommentFormat.setForeground(Qt::red);
  commentStartExpression = QRegularExpression(QStringLiteral("/\\*"));
  commentEndExpression = QRegularExpression(QStringLiteral("\\*/"));
}

void Highlighter::highlightBlock(const QString &text) {

  for (const HighlightingRule &rule : qAsConst(highlightingRules)) {

    QRegularExpressionMatchIterator matchIterator =
        rule.pattern.globalMatch(text);

    while (matchIterator.hasNext()) {

      QRegularExpressionMatch match = matchIterator.next();

      setFormat(match.capturedStart(), match.capturedLength(), rule.format);
    }
  }

  setCurrentBlockState(0);

  int startIndex = 0;
  if (previousBlockState() != 1)
    startIndex = text.indexOf(commentStartExpression);

  while (startIndex >= 0) {
    QRegularExpressionMatch match =
        commentEndExpression.match(text, startIndex);
    int endIndex = match.capturedStart();
    int commentLength = 0;
    if (endIndex == -1) {
      setCurrentBlockState(1);
      commentLength = text.length() - startIndex;
    } else {

      commentLength = endIndex - startIndex + match.capturedLength();
    }
    setFormat(startIndex, commentLength, multiLineCommentFormat);

    startIndex =
        text.indexOf(commentStartExpression, startIndex + commentLength);
  }
}

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent), ui(new Ui::MainWindow) {
  ui->setupUi(this);
  highlighter = new Highlighter(ui->textEdit->document());
}

MainWindow::~MainWindow() {
  delete highlighter;
  delete ui;
}

void MainWindow::on_actionOpen_triggered() {
  QString file_name = QFileDialog::getOpenFileName(
      this, tr("Open C File"), "", tr("C Source File (*.c *.h)"));

  QFile file(file_name);
  file.open(QFile::ReadOnly);
  if (file.isOpen()) {
    ui->textEdit->document()->setPlainText(file.readAll());
    ui->plainTextEdit->appendPlainText("Open " + file_name + " succeeded.\n");
  }
}

void MainWindow::on_actionQuit_triggered() { this->close(); }

void MainWindow::on_actionAssemble_triggered() {
  // Asmer asmer;
  // QString dir_name = QFileDialog::getExistingDirectory(this, "Store
  // Position"); asmer.path = dir_name; try {
  //   auto result = asmer.Run(ui->textEdit_2->document()->toPlainText());
  //   bc_hex = result;
  //   ui->plainTextEdit->appendPlainText("Assemble succeeded.");
  // } catch (std::exception &e) {
  //   ui->plainTextEdit->appendPlainText(e.what());
  // }
  output_path = QFileDialog::getExistingDirectory(this, "Working Directory");
  auto str = ui->textEdit_2->document()->toPlainText();
  QFile file(output_path + "/.temp.asm");
  file.open(QFile::WriteOnly);
  file.write(str.toStdString().c_str());
  file.close();
  if (QFile(mias_path).exists()) {
    ui->plainTextEdit->appendPlainText("Mias Launched, output at " + output_path);
    system((mias_path + " -i " + output_path + "/.temp.asm -o " + output_path +
            "/out.txt -c -v -f && pause")
               .toStdString()
               .c_str());
  } else {
    ui->plainTextEdit->appendPlainText("Mias path not set");
  }
}
// UART

void MainWindow::on_actionUart_Transmit_triggered() {
  if (QFile(mua_path).exists()) {
    ui->plainTextEdit->appendPlainText("Uart Launched.");
    system((mua_path + " -f " + output_path + "/out.txt && pause").toStdString().c_str());
  } else {
    ui->plainTextEdit->appendPlainText("mua path not set");
  }
}

void MainWindow::on_actionmua_triggered() {
  mua_path = QFileDialog::getOpenFileName(this, "Mua path", "", "*.exe");
  ui->plainTextEdit->appendPlainText("mua path = " + mua_path + "\n");
}


void MainWindow::on_actionmias_triggered() {
  mias_path = QFileDialog::getOpenFileName(this, "Mias path", "", "*.exe");
  ui->plainTextEdit->appendPlainText("mias path = " + mias_path + "\n");
}


void MainWindow::on_actionkrill_triggered() {
  krill_path = QFileDialog::getOpenFileName(this, "Krill path", "", "*.exe");
  ui->plainTextEdit->appendPlainText("krill path = " + krill_path + "\n");
}