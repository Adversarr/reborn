#ifndef ASMER_H
#define ASMER_H
#include <QString>

class Asmer
{
public:
  Asmer();

  QString Run(QString str);


  int kbs{64};
  
  int verbose{false};

  QString path;

};

#endif // ASMER_H
