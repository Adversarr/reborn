#ifndef MAINWINDOW_H
#define MAINWINDOW_H
#include <QSyntaxHighlighter>
#include <QMainWindow>
#include <QRegularExpression>
#include <QTextCharFormat>

QT_BEGIN_NAMESPACE
namespace Ui { class MainWindow; }
QT_END_NAMESPACE
class Highlighter : public QSyntaxHighlighter
{
    Q_OBJECT
public:
    Highlighter(QTextDocument *parent = 0);

protected:
    void highlightBlock(const QString &text) override;

private:

    /* 使用私有结构存储突出显示规则：规则由QRegularExpression和
     * QTextCharFormat的实例组成。
     * 并使用QVector存储各种规则。*/
    struct HighlightingRule
    {
        QRegularExpression pattern;
        QTextCharFormat format;
    };

    QVector<HighlightingRule> highlightingRules;

    // 跨行的表达式需要特殊处理
    QRegularExpression commentStartExpression;
    QRegularExpression commentEndExpression;

    /* QTextCharFormat类提供QTextDocument中字符的格式设置信息，
     * 以指定文本的视觉属性，以及有关其在超文本文档中的作用的信息。
     * QTextCharFormat::setFontWeight()定义字体粗细
     * QTextCharFormat::setForeground()函数定义颜色。*/
    QTextCharFormat keywordFormat;
    QTextCharFormat classFormat;
    QTextCharFormat singleLineCommentFormat;
    QTextCharFormat multiLineCommentFormat;
    QTextCharFormat quotationFormat;
    QTextCharFormat functionFormat;
};



class MainWindow : public QMainWindow
{
  Q_OBJECT

public:
  MainWindow(QWidget *parent = nullptr);
  ~MainWindow();

private slots:
  void on_actionOpen_triggered();

  void on_actionQuit_triggered();

  void on_actionAssemble_triggered();

private:
  Ui::MainWindow *ui;
  Highlighter *highlighter;
};
#endif // MAINWINDOW_H
