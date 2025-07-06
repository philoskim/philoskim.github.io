String.prototype.format = function()
{
  var args = arguments;
  return this.replace(/{(\d+)}/g, function(match, number) {
    return typeof args[number] != 'undefined'
      ? args[number]
      : match
    ;
  });
};

function setCookie(cname, cvalue, exdays)
{
    var d = new Date();
    d.setTime(d.getTime() + (exdays*24*60*60*1000));
    var expires = "expires="+d.toString();
    document.cookie = cname + "=" + cvalue + "; " + expires + ";";
    console.log(document.cookie);
}

function getCookie(cname)
{
    var name = cname + "=";
    var ca = document.cookie.split(';');
    for(var i=0; i<ca.length; i++)
    {
        var c = ca[i];
        while (c.charAt(0)==' ')
	  c = c.substring(1);
        if (c.indexOf(name) != -1)
	  return c.substring(name.length,c.length);
    }
    return "";
}

$(document).ready(function() {

  var buttonInfos =
  // id : [url, inputKind, isIframed]    inputKind : "space", "plus", "minus"
  { guide      : ["guide.html", "space", true],
    home       : ["http://www.english4u.kr/", "space", false],

    daum       : ["https://dic.daum.net/search.do?q={0}", "space", false],
    naver      : ["http://endic.naver.com/search.nhn?sLn=kr&searchOption=all&query={0}",
                  "space", false],
    sisa       : ["http://www.ybmallinall.com/stylev2/dicview.asp?kwdseq=0" +
                  "&kwdseq2=0&DictCategory=DictAll&DictNum=0&ById=0&PageSize=5&StartNum=0" +
                  "&GroupMode=0&cmd=0&kwd={0}&x=0&y=0", "plus", true],
    bluedic    : ["http://www.bluedic.com/{0}", "plus", true],
    impact     : ["http://dic.impact.pe.kr/ecmaster-cgi/search.cgi?bool=and&word=yes&kwd={0}",
                  "plus", true],

    idiom      : ["https://www.google.co.kr/search?&q={0}+~meaning+OR+~definition", "plus", false],
    origin     : ["https://www.google.co.kr/search?&q={0}+origin+OR+root+OR+etymology",
                  "plus", false],
    colloc     : ["https://ozdic.com/collocation/{0}", "space", true],
    slang      : ["http://www.urbandictionary.com/define.php?term={0}", "plus", false],
    ngram      : ["http://books.google.com/ngrams/graph?content={0}&year_start=1500"
                  + "&year_end=2000&corpus=0&smoothing=0", "plus", true],
    regex      : ["http://www.visca.com/regexdict/", "plus", true],
    name       : ["https://www.howtopronounce.com/search/{0}/?f", "space", false],
    corpus     : ["http://www.wordandphrase.info/frequencyList.asp", "space", true],
    google     : ["https://www.google.co.kr/search?&q={0}", "plus", false],

    collins    : ["https://www.collinsdictionary.com/dictionary/english/{0}", "minus", false],
    longman    : ["https://www.ldoceonline.com/dictionary/{0}", "minus", false],
    cambridge  : ["https://dictionary.cambridge.org/dictionary/english/{0}", "plus", false],
    vocabulary : ["https://www.vocabulary.com/dictionary/{0}", "space", false],
    webster    : ["https://www.merriam-webster.com/dictionary/{0}", "space", true],
    etymology  : ["https://www.etymonline.com/index.php?allowed_in_frame=0"
                  + "&search={0}&searchmode=none", "plus", false],
    yourdic    : ["https://www.yourdictionary.com/{0}", "minus", true],
    wiktionary : ["https://en.wiktionary.org/wiki/{0}", "space", true],
    dictionary : ["https://dictionary.reference.com/browse/{0}", "plus", true],
    free       : ["https://www.thefreedictionary.com/{0}", "plus", true],
    thesaurus  : ["https://thesaurus.com/browse/{0}?s=t", "plus", true],
    onelook    : ["https://www.onelook.com/?w={0}&ls=a", "plus", true],
    math       : ["https://www.kms.or.kr/mathdict/list.html?key=ename&keyword={0}", "plus", true],
    naver2     : ["https://dict.naver.com/dict.search?query={0}", "space", false]
   };

  function handleButtonClick(e)
  {
    var inputValue = $("#words").val();
    var spaceInput =  inputValue;
    var plusInput = inputValue.split(" ").join("+");
    var minusInput = inputValue.split(" ").join("-");
    var input;

    var value = buttonInfos[e.target.id];

    if (value[1] == "space")
      input = spaceInput;
    else if (value[1] == "plus")
      input = plusInput;
    else
      input = minusInput;

    var url = value[0].format(input);

      setCookie('search-words', inputValue, 1);
      //console.log(document.cookie);

    if (value[2])   // iframe에 담길 수 있으면
    {
      $("#iframe")[0].src = url;
    }
    else
    {
      window.location.href = url;
    }

    $("#words").focus();
  }

  function handleKeydown(e)
  {
    if (e.keyCode == 13)   // 13 == Enter Key
    {
      $("#daum").click();
    }
    else if (e.keyCode == 38)  // 38 == UpArrow Key
    {
      $(this).val(getCookie('search-words'));
    }
    else if (e.keyCode == 40 || e.keyCode == 27)  // 40 == DownArrow Key
    {                                             // 27 == Esc Key
       $(this).val("");
    }
  }

  function handleLoad(e)
  {
    // console.log("handleLoad called.");
    $("#words").focus();
    // console.log(getCookie('search-words'));
    $("#words").val( getCookie('search-words') );
  }

  $("button").click(handleButtonClick);
  $("#words").keydown(handleKeydown);
  $("#words").click(function (e) {$(this).val("");} );

  window.onload = handleLoad;
});
