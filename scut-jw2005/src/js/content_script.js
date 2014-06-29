//var storage = {
  //course : ['hunting...', 'ok']
//};

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

(function () {
  // 刷课功能
  if (document.getElementsByTagName('form')[0].name !== "xsxjs_form") {
    // no the target page, return
    return;
  }

  var courseState = localStorage.getItem('course');
  if (courseState !== 'hunting...') {
      writeRunBtn();
  }
  else {
      huntCourse();
  }
   
})();

function writeRunBtn() {
  /* jshint multistr: true */
  var runBtn = "\
  <div id='runBtn' style='color:#11449e;font-size: 18px;font-weight:bold; cursor:pointer'>\
    开始刷课\
    </div>";
  document.getElementsByTagName('body')[0].innerHTML += runBtn;
  document.getElementById('runBtn').onclick = function () {
    try {
      localStorage.setItem('course', 'hunting...');
    }
    catch (exception) {
      error(exception);
    }
    huntCourse();
  };
}

function huntCourse() {
  if (document.getElementById('runBtn') !== null) {
    document.getElementById('runBtn').innerHTML = "刷课中";
  }

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
    }
    else {
      // click the delete button, which will cause a POST request
      // and avoid the 3 seconds limit
      //document.querySelector('input[name=Button3]').click(); 
      // 经过测试，只需70～80秒就能返回响应……所以得使用setTimeOut来控制才行
      
      // 现在改用GET方法来刷新页面
      var clickMe = "<a href='" + window.url + "' id='clickme'></a>";
      document.getElementsByTagName('body').innerHTML += clickMe;
      setTimeout(function () {
        document.getElementById('clickme').click();
      }, 3000);
      return;
    }
  }

  try {
    localStorage.setItem('course', 'ok');
  }
  catch(exception) {
    error(exception);
  }
}

