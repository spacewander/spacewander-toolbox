#ifndef DIALOG_H
#define DIALOG_H

#include <QDialog>

class QLabel;
class QLineEdit;
class QRadioButton;
class QGroupBox;

class OddsDialog : public QDialog
{
    Q_OBJECT

public:
    explicit OddsDialog(QWidget *parent = 0);
    ~OddsDialog();
private:
    QLineEdit *leftSide;
    QLineEdit *rightSide;
    QLineEdit *leftMoney;
    QLineEdit *rightMoney;
    QLabel *vs;

    QLabel *dealer;
    QLineEdit *fee;
    QLabel *percent;

    QGroupBox *switchBox;
    QRadioButton *leftVsRight;
    QRadioButton *rightVsLeft;

    QLabel *firstSide;
    QLabel *secondSide;
    QLabel *compare;
    QLabel *oddsFirst;
    QLabel *oddsSecond;

    void setCenterAndFixedHalfSide(QLabel *label, unsigned int eachSide);
    void clearOdds();

private slots:
    void switchSides();
    void updateOdds();
    void updateLeftSide(QString left);
    void updateRightSide(QString right);
};

#endif // DIALOG_H
