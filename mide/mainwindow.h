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


    struct HighlightingRule
    {
        QRegularExpression pattern;
        QTextCharFormat format;
    };

    QVector<HighlightingRule> highlightingRules;


    QRegularExpression commentStartExpression;
    QRegularExpression commentEndExpression;


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
  void on_actionUart_Transmit_triggered();

  
  void on_actionmias_triggered();
  void on_actionmua_triggered();
  void on_actionkrill_triggered();

private:
  Ui::MainWindow *ui;
  Highlighter *highlighter;

  QString bc_hex;

  QString krill_path;
  QString mua_path;
  QString mias_path;
  QString output_path;
};
#endif // MAINWINDOW_H
