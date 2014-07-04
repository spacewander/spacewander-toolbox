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
}

OddsDialog::~OddsDialog()
{

}

/**
 * @brief OddsDialog::updateOdds
 *
 *
 */
void OddsDialog::updateOdds()
{
    
}

void OddsDialog::setCenterAndFixedHalfSide(QLabel *label, unsigned int eachSide)
{
    label->setFixedWidth(eachSide);
    label->setAlignment(Qt::AlignHCenter);
}

void OddsDialog::updateLeftSide(const QString &left)
{

}

void OddsDialog::updateRightSide(const QString &right)
{

}

void OddsDialog::switchSides()
{

}
