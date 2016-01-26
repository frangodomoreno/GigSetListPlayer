#ifndef BACKUPATTRIB_H
#define BACKUPATTRIB_H

#include <QObject>

class backupAttrib : public QObject
{
    Q_OBJECT
private:

public:
    explicit backupAttrib(QObject *parent = 0);
    ~backupAttrib();
    Q_INVOKABLE bool setAttribExclude(QString);

signals:

public slots:

private:
    void *m_delegate;

};

#endif // BACKUPATTRIB_H
