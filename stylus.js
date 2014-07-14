var stylus = require("stylus");
var fs = require('fs');
var str = require("fs").readFileSync(process.argv[2], 'utf8');

stylus.render(str,function (err, css) {
    if (err) throw err;
    fs.writeFileSync(process.argv[2].replace(/\.styl/, '.css'), css, 'utf8', 
    function (err) {
      if (err) throw err;
      console.log(css);
    });
});

