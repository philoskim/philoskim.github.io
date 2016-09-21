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
  { naver      : ["http://dedic.naver.com/#search/all/q={0}&sm=de_key",
                  "space", false],
    dict_cc    : ["http://www.dict.cc/?s={0}", "plus", true],
    chemnitz   : ["http://dict.tu-chemnitz.de/dings.cgi?service=deen&opterrors=0&optpro=0&" +
                  "query={0}", "plus", true],
    collins    : ["http://www.collinsdictionary.com/dictionary/german-english/{0}",
                  "minus", false],
    reverso    : ["http://dictionary.reverso.net/german-english/{0}",
                  "plus", false]
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
      $("#naver").click();
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
    $("#words").focus();
    $("#words").val( getCookie('search-words') );
  }

  $("button").click(handleButtonClick);
  $("#words").keydown(handleKeydown);
  $("#words").click(function (e) {$(this).val("");} );

  window.onload = handleLoad;
});
