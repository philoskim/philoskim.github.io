String.prototype.format = function() {
  var args = arguments;
  return this.replace(/{(\d+)}/g, function(match, number) {
    return typeof args[number] != 'undefined'
      ? args[number]
      : match
    ;
  });
};

var buttons = document.getElementsByTagName("button");
for (var i = 0; i < buttons.length; i++)
  buttons[i].onclick = handleClick;

var buttonInfos =
  // id : [url, isSpacedInput, isIframed]
   {clojure   : ["http://clojuredocs.org/search?q={0}", false, true],
    cljs      : ["http://cljs.github.io/api/cljs.core/", false, true],

    numpy     : ["https://numpy.org/doc/stable/search.html?q={0}", false, true],
    pandas    : ["https://pandas.pydata.org/docs/search.html?q={0}", false, true],
    mpl       : ["https://matplotlib.org/stable/search.html?q={0}", false, true],

    java       : ["https://docs.oracle.com/search/?q={0}&pg=1&size=10&product=en%2Fjava%2Fjavase%2F22&category=en%2Fjava&showfirstpage=true&lang=en",
                  false, false],
    javaex     : ["https://cse.google.com/cse?cx=partner-pub-1130008796007602%3Airi8be-v211&ie=ISO-8859-1&q={0}&sa=Search&siteurl=www.java2s.com%2FCode%2FJavaAPI%2F&ref=&ss=1360j372026j6",
                  false, false],
    antlr      : ["https://www.google.co.kr/#hl=ko&q={0}+site:antlr.org",
                  false, false],
    itext      : ["https://www.google.co.kr/#hl=ko&q={0}+site:api.itextpdf.com/itext/",
                  false, false],

    lua        : ["https://www.google.co.kr/#hl=ko&q={0}+site:lua-users.org/wiki/",
                  false, false],
    luajit     : ["https://www.google.co.kr/#hl=ko&q={0}+site:luajit.org", false, false],


    w3c        : ["https://www.google.co.kr/#hl=ko&q={0}+site:www.w3schools.com",
                  false, false],
    webapi     : ["https://developer.mozilla.org/en-US/search?q={0}", false, false],
    jquery     : ["http://api.jquery.com/?ns0=1&s={0}", false, true],

    context    : ["http://wiki.contextgarden.net/index.php?search={0}", false, true],
    contextapi : ["http://wiki.contextgarden.net/Command/{0}", false, true],

    emacs      : ["https://www.google.co.kr/#hl=ko&q=emacs+{0}", false, false],
    emacswiki  : ["https://www.google.co.kr/#hl=ko&q={0}+site:www.emacswiki.org/",
                  false, false],

    google     : ["https://www.google.co.kr/#hl=ko&q={0}", false, false],
    gas        : ["https://www.google.co.kr/#hl=ko&q={0}+site:https://developers.google.com/apps-script/reference",
                  false, false],

    d          : ["https://www.google.co.kr/#hl=ko&q={0}+site:dlang.org",
                  false, false]

 };

var oldInput = "";

/*
function handleLoad(e)
{
  var guide =  buttonInfos['guide'];
  var iframe = document.getElementById("iframe");
  iframe.src = guide[0];
}
*/

function handleClick(e)
{
  var inputValue = document.getElementById("entry").value;
      spacedInput =  inputValue;
      plusedInput = inputValue.split(" ").join("+");


  var value = buttonInfos[e.target.id];
  var url = value[0].format(value[1] ? spacedInput : plusedInput);

  if (value[2])   // iframe에 담길 수 있으면
  {
    var iframe = document.getElementById("iframe");
    iframe.src = url;
  }
  else
  {
    var anchor = document.getElementById("anchor");
    anchor.href = url;
    var evt = document.createEvent("MouseEvents");
    evt.initEvent("click", true, true);
    anchor.dispatchEvent(evt);
  }
}

function handleFocus(e) {
  oldInput = document.getElementById("entry").value;
  document.getElementById("entry").value = "";
}

function handleKeydown(e) {
  if (e.keyCode == 13) {   // 13 == Enter Key
    var voca = document.getElementById("clojure");
    var evt = document.createEvent("MouseEvents");
    evt.initEvent("click", true, true);
    voca.dispatchEvent(evt);
  }
  else if (e.keyCode == 38) {  // 38 == UpArrow Key
    e.target.value = oldInput;
  }
}

document.getElementById("entry").onkeydown = handleKeydown;
document.getElementById("entry").onfocus = handleFocus;
// document.getElementById("main").onload = handleLoad;
