#include "mainwindow.h"
#include "./ui_mainwindow.h"
#include "asmer.h"
#include <QDebug>
#include <QFileDialog>

Highlighter::Highlighter(QTextDocument *parent) : QSyntaxHighlighter(parent) {
  HighlightingRule rule;

  /****************************************************************************
   *  首先，我们定义关键字规则，该规则可以识别最常见的C++关键字。
   * 我们为keywordFormat提供了深蓝色粗体。
   * 对于每个关键字，将关键字和指定的格式分配给HighlightingRule对象，然后将该对象附加到规则列表中。
   *
   * 使用QRegularExpression类的正则，对于正则需要有点了解就行。
   * "\\bchar\\b"：\\b就是\b的转移序列,意识为单词的边界，中间的char就是关键词
   */
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

  /***************************************************************************
   * 然后，我们创建一种将应用于Qt类名称的格式。类名将以深洋红色和粗体显示。
   * 我们指定一个字符串模式，它实际上是一个捕获所有Qt类名的正则表达式。
   * 然后，我们将正则表达式和指定的格式分配给HighlightingRule对象，并将该对象附加到规则列表中。*/
  classFormat.setFontWeight(QFont::Bold);
  classFormat.setForeground(Qt::darkMagenta);
  rule.pattern = QRegularExpression(QStringLiteral("\\bQ[A-Za-z]+\\b"));
  rule.format = classFormat;
  highlightingRules.append(rule);

  /* 定义引号高亮规则：模式具有正则表达式的形式 例如： "......"
   * 并以相关格式存储在HighlightingRule对象中。 */
  quotationFormat.setForeground(Qt::darkGreen);
  rule.pattern = QRegularExpression(QStringLiteral("\".*\""));
  rule.format = quotationFormat;
  highlightingRules.append(rule);

  /* 定义函数的高亮规则：模式具有正则表达式的形式，例如：My_func(
   * 并以相关格式存储在HighlightingRule对象中。
   * regex 只检测了左括号的存在，即认为是函数名*/
  functionFormat.setFontItalic(true);
  functionFormat.setForeground(Qt::blue);
  rule.pattern = QRegularExpression(QStringLiteral("\\b[A-Za-z0-9_]+(?=\\()"));
  rule.format = functionFormat;
  highlightingRules.append(rule);

  // 单行注释的高亮（//）
  singleLineCommentFormat.setForeground(Qt::red);
  rule.pattern = QRegularExpression(QStringLiteral("//[^\n]*"));
  rule.format = singleLineCommentFormat;
  highlightingRules.append(rule);

  // 多行注释的高亮（/*...*/）
  multiLineCommentFormat.setForeground(Qt::red);
  // 多行注释的开始：/*
  commentStartExpression = QRegularExpression(QStringLiteral("/\\*"));
  // 多行注释的结束：/*
  commentEndExpression = QRegularExpression(QStringLiteral("\\*/"));

  /* 由于QSyntaxHighlighter类的设计，多行注释需要特别注意。
   * 创建QSyntaxHighlighter对象后，富文本引擎会在需要时自动调用其highlightBlock()函数，突出显示给定的文本块。
   * 当注释跨越多个文本块时，将出现问题。
   * 解决方法放在 Highlighter :: highlightBlock()函数的实现时，
   * 此时，我们仅指定多行注释的颜色。*/
}

/* highlightBlock()函数会在富文本引擎需要时自动调用，例如，当文本块发生变化时。*/
void Highlighter::highlightBlock(const QString &text) {
  /* 首先，应用存储在highlightingRules向量中的语法高亮显示规则。*/

  // 检索每个规则(即每个HighlightingRule对象)
  for (const HighlightingRule &rule : qAsConst(highlightingRules)) {

    // 使用QRegularExpression::globalMatch()函数在给定的文本块中搜索模式。
    QRegularExpressionMatchIterator matchIterator =
        rule.pattern.globalMatch(text);

    while (matchIterator.hasNext()) {

      // 当发现模式出现时，获取该模式
      QRegularExpressionMatch match = matchIterator.next();

      // 使用
      // QRegularExpressionMatch::capturedStart()函数来确定将要格式化的字符串的起始位置。
      // 使用
      // QRegularExpressionMatch::capturedLength()返回匹配字符串的长度，如果没有匹配，则返回0。
      // 使用 QSyntaxHighlighter类提供了setFormat()函数执行格式化

      setFormat(match.capturedStart(), match.capturedLength(), rule.format);

      /* 为了执行实际的格式化，QSyntaxHighlighter类提供了setFormat()函数。这个函数对作为参数传递给highlightBlock()函数的文本块进行操作。
       * 指定的格式将从给定的起始位置应用于给定长度的文本。在显示时，以给定格式设置的格式化属性将与直接存储在文档中的格式化信息合并。
       * 注意，文档本身不会被这个函数设置的格式修改。
       * 重复此过程，直到在当前文本块中找到该模式的最后一次出现为止。*/
    }
  }

  /******************************************************************************************************
   * 要处理可以跨越多个文本块的构造(如c++多行注释)，有必要知道前一个文本块的结束状态(例如，注释)。在highlightBlock()中，
   * 使用QSyntaxHighlighter::previousBlockState()函数查询前一个文本块的结束状态。
   * 解析块之后，可以使用QSyntaxHighlighter::setCurrentBlockState()保存最后的状态。
   *
   * 这个previousBlockState()函数返回一个int值。
   * 如果未设置任何状态，则返回值为-1。
   * 使用setCurrentBlockState()函数指定任何其他值来标识任何给定状态。
   * 设置状态后，QTextBlock会保留该值，直到再次设置该值或删除相应的文本段落为止。
   *
   * 在本例中，我们选择使用0表示“不在注释中”状态，使用1表示“在注释中”状态。当应用存储的语法高亮显示规则时，我们将当前块状态初始化为0。*/

  setCurrentBlockState(0);

  /******************************************************************************************************
   * 查找起始表达式的位置
   *
   * 如果先前的块状态为“处于注释中”（previousBlockState()==
   * 1），则在文本块的开头开始搜索结束表达式。
   * 如果previousBlockState()返回0，则查找首次出现起始表达式的位置*/
  int startIndex = 0;
  if (previousBlockState() != 1)
    startIndex = text.indexOf(commentStartExpression);

  // 接着查找结束表达式的位置，因为跨行，所以需要循环查找。
  while (startIndex >= 0) {
    QRegularExpressionMatch match =
        commentEndExpression.match(text, startIndex);
    int endIndex = match.capturedStart();
    int commentLength = 0;
    // 如果在当前文本块中找不到结束表达式，则将当前块状态设置为1，并计算当前注释文本的长度
    if (endIndex == -1) {
      setCurrentBlockState(1);
      commentLength = text.length() - startIndex;
    }
    // 如果在当前文本块中找到结束表达式，则计算注释文本的实际长度
    else {

      commentLength = endIndex - startIndex + match.capturedLength();
    }
    // 应用多行注释格式。
    setFormat(startIndex, commentLength, multiLineCommentFormat);
    // 然后，我们搜索下一个出现的开始表达式并重复该过程。
    startIndex =
        text.indexOf(commentStartExpression, startIndex + commentLength);
    /* 这样就完成了Highlighter类的实现。*/
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
  Asmer asmer;
  QString dir_name = QFileDialog::getExistingDirectory(this, "Store Position");
  asmer.path = dir_name;
  try {
    auto result = asmer.Run(ui->textEdit_2->document()->toPlainText());
    bc_hex = result;
    ui->plainTextEdit->appendPlainText("Assemble succeeded.");
  } catch (std::exception &e) {
    ui->plainTextEdit->appendPlainText(e.what());
  }
}

