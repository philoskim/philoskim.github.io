#lang scribble/manual
@(require "../my-utils.rkt")

@title{Clojure Memo}

@itemlist[
  @item{작성자: 김영태}
  @item|{e-mail: philos99@gmail.com}|
  @item{facebook: @url{https://www.facebook.com/philos.kim}}
]

이 글들은 클로저(Clojure) 프로그래밍 언어를 공부하면서 얻게 된 지식들 중 일부를 정리한
것이다. 글들 중에는 클로저를 공부하면서 지녔던 의문점들을 해결해 나가면서, 클로저 관련
서적들에도 자세한 설명이 없는 내용들도 일부 포함되어 있다. 인터넷을 검색해 모은 가능한 한
객관적인 자료를 바탕으로 내린 결론들이지만, 경우에 따라서는 제 개인의 주관적인 판단이
개입된 부정확한 분석 내용이 포함되어 있을 수 있음을 미리 밝힌다. 물론 그런 부분은
개인적으로 내린 추론임을 명시적으로 밝힐 것이다.

아울러 이 글들은 클로저의 기본 내용을 알고 있다는 전제 아래 쓰여져서, 클로저 초보자들이
이해하기에는 어려움이 있을 수 있지만, 클로저를 좀더 깊이 있게 이해하고자 하는 사람들에게는 
많은 도움이 될 것으로 믿는다.

코드 예제들은 다음의 표기법을 따른다. 참고로, 클로저에서 라인 코멘트(line comment) 기호인
';' 기호를 이용해서, 이곳의 예제들을 Copy & Paste 해서 실행해 볼 때 불편이 없게 했다.

@descblock|{

; >> 화면에 출력된 내용을 표시한다.
; << 키보드로 입력한 내용을 표시한다. 
; => 함수의 반환값을 표시한다.
}|

@coding|{
(defn get-name []
  (println "Enter Your Name:")
  (let [name (read-line)]
    (println "Hello," name)
    name))
 
(get-name)
; >> Enter Your Name:
; << Mr. Kim
; >> Hello, Mr. Kim
; => "Mr. Kim"
}|


@table-of-contents[]

@; ------------------------------------------------------------------------
@include-section["why-clojure.scrbl"]
@include-section["../clojure/recursions.scrbl"]
@include-section["../clojure/functional-patterns.scrbl"]
@include-section["vars.scrbl"]
@include-section["../clojure/testing.scrbl"]
@include-section["tips.scrbl"]
@include-section["core-async.scrbl"]
@include-section["clojurescript.scrbl"]

@index-section[]

