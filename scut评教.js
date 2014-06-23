// 需要在http://222.201.132.114/这个网址下使用
// 如果你使用Chrome，在评教页面下，菜单 > 工具 > JS控制台，复制代码然后回车。其他浏览器同理，需要在JS控制台下运行
(function (){
    var contentDocument = document.getElementsByTagName('iframe')[0].contentDocument;
	var selectedInfo = [];
    var optionsSet = contentDocument.getElementById('DataGrid1__ctl2_JS1').options;
    for (var i = 0, n = optionsSet.length;i < n; i++) {
      if (optionsSet[i].value) selectedInfo.push(optionsSet[i].value);
    }
    var num = 1;
    var teachers = parseInt(contentDocument.getElementsByTagName('select').length / 7);
    if (teachers > 1) {
        num = prompt('还记得你的老师是第几位老师吗？',1);
        if (num === null || num > teachers || num < 1) 
            num = 1;
    }
    var hatred = confirm('要给他/她差评吗？');
    var boundary = 0;
    if (hatred === false) {
        boundary = 3;
    }
    else {
        boundary = optionsSet.length;
    }
    for (var i = 2; i < 9; i++) {
        if (num <= 2) {
            var id = 'DataGrid1__ctl' + i + '_JS' + num;
        }
        else {
            var id = 'DataGrid1__ctl' + i + '_js' + num;
        }
        var elem = contentDocument.getElementById(id);
        var rank = parseInt(Math.random() * 10 % boundary); // rank越高给的评价越差
        elem.value = selectedInfo[rank];
    }
    var advice = [
        '老师授课的方式非常适合我们，他根据本课程知识结构的特点，重点突出，层次分明。',
        '老师授课有条理，有重点，对同学既热情又严格。',
        '老师治学严谨，要求严格，能深入了解学生的学习和生活状况，循循善诱，平易近人',
        '老师对待教学认真负责，语言生动，条理清晰，举例充分恰当，对待学生严格要求'
        ];
    contentDocument.getElementById('pjxx').value = advice[parseInt(Math.random() * advice.length % advice.length)];
    contentDocument.querySelector('input[name=Button1]').click();
})()
