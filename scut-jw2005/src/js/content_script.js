// utility functions
var DEBUG = true;

function log (message) {
  if (DEBUG) {
    console.log(message);
  }
}

function error (exception) {
  log('catch an exception: ' + exception.message);
  if (chrome.extension.lastError) {
    log('An error occurred: ' + chrome.extension.lastError.message);
  }
}

function setItem(key, value) {
  try {
      sessionStorage.setItem(key, value);
    }
    catch (exception) {
      error(exception);
    }
}

// these functions do the dull job
function writeRunBtn(courseName) {
  /* jshint multistr: true */
  var runBtn = "\
  <div id='runBtn' style='color:#11449e;font-size: 18px;font-weight:bold; cursor:pointer'>\
    开始刷课\
    </div>";
  document.getElementsByTagName('body')[0].innerHTML += runBtn;
  document.getElementById('runBtn').onclick = function () {
    setItem(courseName, 'hunting');
    huntCourse();
  };
}

function huntCourse() {
  if (document.getElementById('runBtn') !== null) {
    document.getElementById('runBtn').innerHTML = "刷课中";
  }
  else {
    var runBtn = "\
        <div id='runBtn' style='color:#11449e;font-size: 18px;font-weight:bold; cursor:pointer'>\
          刷课中\
        </div>";
    document.getElementsByTagName('body')[0].innerHTML += runBtn;
  }
  
  try {
    var selected = document.querySelector('input[type=radio]').checked;
    // if the number of people selected this course is smaller than 
    // the limit of number of people
    var numOfSelected = parseInt(document.getElementById('td_bzyz').innerHTML);
    var numOfLimited = parseInt(document.getElementsByTagName('td')[27].innerHTML);
    var selectable =  numOfSelected < numOfLimited;

    if (!selected) {
      if (selectable) {
        document.querySelector('input[type=radio]').click();
        document.querySelector('input[type=submit]').click();// click ok and go away
        try {
          sessionStorage.setItem(courseName, 'ok');
          document.getElementById('runBtn').innerHTML = "开始刷课";
        }
        catch (exception) {
          error(exception);
        }
      }
      else {
        refresh();
        return;
      }
    }
  }
  catch (exception) {
    error(exception);
  }
}

function refresh () {
  try {
    // click the delete button, which will cause a POST request
    // and avoid the 3 seconds limit
    //document.querySelector('input[name=Button3]').click(); 
    // 经过测试，只需70～80秒就能返回响应……所以得使用setTimeOut来控制才行

    // 现在改用GET方法来刷新页面
    var clickMe = "<a href='" + window.location.href + "' id='clickme'></a>";
    document.getElementsByTagName('body')[0].innerHTML += clickMe;
    setTimeout(function () {
      document.getElementById('clickme').click();
    }, 3500);
    // jw2005是通过中间括号括起来的字符串来判断两个GET请求是否在3秒内
    //（其实不是完全是3秒内，原因未明）
    // 这个字符串是在登录时分配的，所以多登录几次，收集多个字符串，你就可以打破3秒限制了。
  }
  catch (exception) {
    error(exception);
    refresh();
  }
}

(function () {
  // 刷课功能
  var contents = document.getElementsByTagName('body')[0].innerHTML;
  if (contents !== '三秒防刷' && // first make sure it is not the 3秒防刷页面
      document.getElementsByTagName('form')[0].name !== "xsxjs_form" ) {
    // no the target page, return
  
    return;
  }

  if (contents === '三秒防刷') {
    refresh();
    return;
  }
  
  var courseName = document.getElementById('Label1').innerHTML.split('&')[0];
  var courseState = sessionStorage.getItem(courseName);
  if (courseState === null || courseState === 'ok') {
    writeRunBtn(courseName);
  }
  else {
      huntCourse();
  }
   
})();
