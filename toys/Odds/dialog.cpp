#include <QLayout>
#include <QGroupBox>
#include <QLabel>
#include <QLineEdit>
#include <QRadioButton>

#include "dialog.h"

OddsDialog::OddsDialog(QWidget *parent)
    : QDialog(parent)
{
    setWindowTitle(tr("庄家总是稳赢不赔的啦"));
    vs = new QLabel(tr("VS"));

    leftSide = new QLineEdit;
    leftSide->setPlaceholderText(tr("左边"));
    rightSide = new QLineEdit;
    rightSide->setPlaceholderText(tr("右边"));
    leftMoney = new QLineEdit;
    leftMoney->setPlaceholderText(tr("注金"));
    rightMoney = new QLineEdit;
    rightMoney->setPlaceholderText(tr("注金"));

    dealer = new QLabel(tr("庄家抽成："));
    fee = new QLineEdit;
    percent = new QLabel(tr("%"));

    switchBox = new QGroupBox(tr(""));
    leftVsRight = new QRadioButton(tr("左比右"));
    leftVsRight->setChecked(true);
    rightVsLeft = new QRadioButton(tr("右比左"));

    QHBoxLayout *groupBoxLayout = new QHBoxLayout;
    groupBoxLayout->addWidget(leftVsRight);
    groupBoxLayout->addStretch();
    groupBoxLayout->addWidget(rightVsLeft);
    switchBox->setLayout(groupBoxLayout);

    int eachSide = 150;
    firstSide = new QLabel(tr("左边"));
    setCenterAndFixedHalfSide(firstSide, eachSide);
    secondSide = new QLabel(tr("右边"));
    setCenterAndFixedHalfSide(secondSide, eachSide);
    oddsFirst = new QLabel(tr("1"));
    setCenterAndFixedHalfSide(oddsFirst, eachSide);
    compare = new QLabel(tr(":"));
    compare->setAlignment(Qt::AlignHCenter);
    oddsSecond = new QLabel(tr("1"));
    setCenterAndFixedHalfSide(oddsSecond, eachSide);

    QVBoxLayout *leftSideLayout = new QVBoxLayout;
    leftSideLayout->addWidget(leftSide);
    leftSideLayout->addWidget(leftMoney);
    QVBoxLayout *vsSideLayout = new QVBoxLayout;
    vsSideLayout->addWidget(vs);
    vsSideLayout->addStretch();
    QVBoxLayout *rightSideLayout = new QVBoxLayout;
    rightSideLayout->addWidget(rightSide);
    rightSideLayout->addWidget(rightMoney);
    QHBoxLayout *inputArea = new QHBoxLayout;
    inputArea->addLayout(leftSideLayout);
    inputArea->addLayout(vsSideLayout);
    inputArea->addLayout(rightSideLayout);

    QHBoxLayout *dealerArea = new QHBoxLayout;
    dealerArea->addWidget(dealer);
    dealerArea->addWidget(fee);
    dealerArea->addWidget(percent);

    QVBoxLayout *firstSideLayout = new QVBoxLayout;
    firstSideLayout->addWidget(firstSide);
    firstSideLayout->addWidget(oddsFirst);
    QVBoxLayout *compareSideLayout = new QVBoxLayout;
    compareSideLayout->addWidget(compare);
    compareSideLayout->addStretch();
    QVBoxLayout *secondSideLayout = new QVBoxLayout;
    secondSideLayout->addWidget(secondSide);
    secondSideLayout->addWidget(oddsSecond);
    QHBoxLayout *outputArea = new QHBoxLayout;
    outputArea->addLayout(firstSideLayout);
    outputArea->addLayout(compareSideLayout);
    outputArea->addLayout(secondSideLayout);

    QVBoxLayout *mainLayout = new QVBoxLayout;
    mainLayout->addLayout(inputArea);
    mainLayout->addLayout(dealerArea);
    mainLayout->addWidget(switchBox);
    mainLayout->addLayout(outputArea);

    setLayout(mainLayout);

    connect(leftSide, SIGNAL(textChanged(QString)),this,
            SLOT(updateLeftSide(QString)));
    connect(rightSide, SIGNAL(textChanged(QString)),this,
            SLOT(updateRightSide(QString)));

    connect(leftMoney, SIGNAL(textChanged(QString)), this, SLOT(updateOdds()));
    connect(rightMoney, SIGNAL(textChanged(QString)), this, SLOT(updateOdds()));
    connect(fee, SIGNAL(textChanged(QString)), this, SLOT(updateOdds()));

    connect(leftVsRight, SIGNAL(toggled(bool)), this, SLOT(switchSides()));
    connect(rightVsLeft, SIGNAL(toggled(bool)), this, SLOT(switchSides()));
}

OddsDialog::~OddsDialog()
{

}

/**
 * @brief OddsDialog::updateOdds
 *
 * update the odds
 */
void OddsDialog::updateOdds()
{
    bool ok = true;
    double leftIn = leftMoney->text().isEmpty() ? 0 : leftMoney->text().toInt(&ok);
    double rightIn = rightMoney->text().isEmpty() ? 0 : rightMoney->text().toInt(&ok);
    if (!(ok && (leftIn != 0) && (rightIn != 0))) {
        clearOdds();
        return;
    }

    double cost = fee->text().isEmpty() ? 0 : fee->text().toInt(&ok);
    if (!ok || cost >= 100) {
        cost = 0;
        fee->setText("0");
    }

    bool isLeftLarger;
    double odds; // odds = max / min * (1 - cost / 100.0)
    if (leftIn >= rightIn) {
        isLeftLarger = true;
        odds = int(leftIn / rightIn * (1 - cost / 100.0) * 100) / 100.0;
    }
    else {
        isLeftLarger = false;
        odds = int(rightIn / leftIn * (1 - cost / 100.0) * 100) / 100.0;
    }

    QString str;
    if (leftVsRight->isChecked() == isLeftLarger) {
        oddsFirst->setText(str.setNum(odds));
        oddsSecond->setText(str.setNum(1));
    }
    else {
        oddsFirst->setText(str.setNum(1));
        oddsSecond->setText(str.setNum(odds));
    }
}

/**
 * set back to 1 : 1
 */
void OddsDialog::clearOdds()
{
    oddsFirst->setText("1");
    oddsSecond->setText("1");
}

/**
 * @brief OddsDialog::setCenterAndFixedHalfSide
 * @param label
 * @param eachSide
 *
 * set the style of QLabel and let it as wide as the QLineEdit above
 */
void OddsDialog::setCenterAndFixedHalfSide(QLabel *label, unsigned int eachSide)
{
    label->setFixedWidth(eachSide);
    label->setAlignment(Qt::AlignHCenter);
}

void OddsDialog::updateLeftSide(QString left)
{
    if (left.isEmpty()) {
        left = tr("左边");
    }
    if (leftVsRight->isChecked()) {
        firstSide->setText(left);
    }
    else {
        secondSide->setText(left);
    }
}

void OddsDialog::updateRightSide(QString right)
{
    if (right.isEmpty()) {
        right = tr("右边");
    }
    if (leftVsRight->isChecked()) {
        secondSide->setText(right);
    }
    else {
        firstSide->setText(right);
    }
}

void OddsDialog::switchSides()
{
    QString left = leftSide->text();
    QString right = rightSide->text();
    // the method below will change the value of [left|right]Side
    updateLeftSide(left);
    updateRightSide(right);

    updateOdds();
}
