#lang scribble/doc
@(require scribble/manual)
@(require "../my-utils.rkt")

@title[#:tag "var"]{Vars}

@section{Var와 Binding}

다음은 var의 binding에 대한 설명이다.

Clojure에서 def로 선언된 변수명이나 defn으로 선언된 함수명은 해당 namespace의 심볼
테이블에 symbol이 var를 가리키는 형태(symbol --> var)로 등록되고 관리된다. 그리고 프로그램
실행 중에 이와 관련된 정보를 참조할 수도 있다.

그런데 var의 binding에는 크게 두 종류가 있다. 바로 root binding과 thread-local
binding이 그것이다.

root binding은 모든 쓰레드에서 접근 가능한 binding인 반면에, thread-local binding은
이름에서 짐작할 수 있듯이 해당 쓰레드에서만 접근 가능하다.

다음의 예는 root binding의 예이다.

@coding|{
(def a 10)
(def b 20)

;; 이 함수가 실행되고 있는 main thread에서도 접근 가능  
(+ a b)
; => 30

;; future에 의해 실행되는 별도의 쓰레드에서도 접근 가능 
@(future (+ a b))
; => 30
}|


이에 반해 thread-local binding을 이용하려면, 다음 두 가지 조건을 모두 충족시켜
주어야 한다.

@itemlist[#:style 'ordered
  @item{def 선언시 ^:dynamic을 반드시 포함해 주어야 한다.}
  @item{'binding 매크로 안'에서만 dynamic var를 참조해야 한다.}
]


@coding|{
(def ^:dynamic c 10)
(def ^:dynamic d 20)

;; 이 때는 dynamic으로 선언되어 있어도 binding 매크로 안에서
;; 참조가 이루어지고 있지는 않으므로 여전히 root binding이다. 
(+ c d)
; => 30

;; future에 의해 실행되는 별도의 쓰레드에서 접근하지만
;; binding 매크로 안에서 참조가 이루어지고 있지는 않으므로
;; 여전히 root binding이다. 
@(future (+ c d))
; => 30

;; 위의 두 가지 조건을 모두 만족시키므로 thread-local binding이다.
;; + 함수가 참조하고 있는 c와 d의 삾은, 이 함수가 실행되고 있는
;; main thread에서만 접근 가능. 다른 쓰레드는 이 100과 200의 값을
;; 볼 수 없다.
(binding [c 100 d 200]
  (+ c d))
; => 300

;; 위의 두 가지 조건을 모두 만족시키므로 thread-local binding이다.
;; + 함수가 참조하고 있는 c와 d의 값은, 이 함수가 실행되고 있는
;; future에 의해 실행되는 별도의 쓰레드 안에서만 접근 가능하다.
@(future
   (binding [c 300 d 400]
     (+ c d)))
; => 700

;; thread-local binding에서 binding된 값들은
;; root binding의 값에는 영향을 미치지 못한다.
(+ c d)
; => 30
}|



@section{Symbol의 평가와 Var의 평가}

Clojure에서는 top-level symbol(즉, def로 정의되는 심볼)이, Common Lisp에서와는 달리,
값(value)을 직접 가리키지 않고, var를 경유해 가리킵니다. 이 글에서는 그 작동 메카니즘을
제가 이해한 대로 설명해 보겠습니다.

@descblock|{
symbol --> var --> value
}|

인터넷을 검색해 봐도 symbol의 평가와 var의 평가에 대해 그 차이를 명쾌하게 설명한 글을 찾기
어려워, 제가 직접 테스트한 결과를 바탕으로 제 나름대로 분석한 내용입니다. 제가 이해한 바가
실제와 다를 수도 있음을 참고하시고, 잘못된 이해라고 판단되는 부분이 있으면 지적해 주시기
바랍니다. 아울러 이 글은 Clojure의 symbol이나 var에 대한 기본적인 이해가 선행되어야 제대로
이해할 수 있는데, 그 부분에 대한 기초적인 설명까지 덧붙이자면 글이 너무 길어질 것 같아서
그에 대한 설명을 다음 기회로 미루는 것을 미리 양해해 주시기 바라며, 따라서 이 글이 지금
당장 이해 안된다고 너무 자책하지 마시길 바랍니다. :)

@subsection{var가 가리키는 값이 함수가 아닌 경우}

@coding|{
; 이름공간를 ns-a로 변경한다.
user> (ns ns-a)
nil

; prompt가 ns-a로 변경된 것을 확인할 수 있다.
; ns-a 이름공간에서 심볼 a를 정의한다.
;
;  심볼   var          value
; ---------------------------
;  a -->  #'ns-a/a --> 10
ns-a> (def a 10)
#'ns-a/a

; top-level 심볼 a를 평가하면, 심볼 a가 가리키고 있는 var인
; #'ns-a/a를 거쳐 value를 가져오게 된다. 
ns-a> a
10

; 이름공간을 ns-b로 변경한다.
ns-a> (ns ns-b)
nil

; prompt가 ns-b로 바뀐 것을 확인할 수 있다.
; ns-b 이름공간에서 심볼 a1을, ns-a/a로 정의한다.
;
; 심볼    var           value
; ----------------------------
;  a1 --> #'ns-b/a1 --> 10
ns-b> (def a1 ns-a/a)
#'ns-b/a1

; a1을 평가하면 예상한 결과값이 나온다.
; top-level 심볼 a1를 평가하면, 심볼 a1이 가리키고 있는 var인
; #'ns-b/a1를 거쳐 value 10을 가져오게 된다.
ns-b> a1
10

; ns-b 이름공간에서 심볼 a2를 #'ns-a/a로 정의한다 (#'가 붙어있음에 주의).
;
; 심볼    var           var          value
; ------------------------------------------
;  a2 --> #'ns-b/a2 --> #'ns-a/a --> 10
ns-b> (def a2 #'ns-a/a)
#'ns-b/a2

; a2를 평가하면 #'ns-a/a가 나온댜.
ns-b> a2
#'ns-a/a

; @a2를 평가하면 10이 나온댜.
ns-b> @a2
10

; ns-a 이름공간으로 돌아간다.
ns-b> (ns ns-a)
nil

; ns-a 이름공간에서 심볼 a를 '재정의'한다.
;
;  심볼   var          value
; ---------------------------
;  a -->  #'ns-a/a --> 100
ns-a> (def a 100)
#'ns-a/a

; ns-b 이름공간으로 되돌아간다.
ns-a> (ns ns-b)
nil

; a1을 평가하면, 예전에 정의한 값 10이 반환된다.
;
; 심볼    var           value
; ----------------------------
;  a1 --> #'ns-b/a1 --> 10
ns-b> a1
10

; a2를 평가하면, #'ns-a/a가 반환된다.
;
; 심볼       var        var          value
; ------------------------------------------
;  a2 --> #'ns-b/a2 --> #'ns-a/a --> 100
ns-b> a2
#'ns-a/a

; @a2를 평가하면, 새로 정의한 값 100이 반환된다.
ns-b> @a2
100
}|


@subsection{var가 가리키는 값이 함수인 경우}

@coding|{
; 이름공간를 ns-a로 변경한다.
user> (ns ns-a)
nil

; prompt가 ns-a로 변경된 것을 확인할 수 있다.
; ns-a 이름공간에서 심볼 f를 함수로 정의한다.
;
;  심볼   var          value
; -------------------------------------
;  f -->  #'ns-a/f --> 함수 객체: (+ a b)
ns-a> (defn f [a b] (+ a b))
#'ns-a/f

; 이름공간을 ns-b로 변경한다.
ns-a> (ns ns-b)
nil

; prompt가 ns-b로 바뀐 것을 확인할 수 있다.
; ns-b 이름공간에서 f1을 ns-a/f로 정의한다.
;
; 심볼    var           value
; -------------------------------------
;  f1 --> #'ns-b/f1 --> 함수 객체: (+ a b)
ns-b> (def f1 ns-a/f)
#'ns-b/f1

; f1을 함수로 실행하면 예상한 결과값이 나온다.
ns-b> (f1 10 20)
30


; ns-b 이름공간에서 f2를 #'ns-a/f로 정의한다.
;
; 심볼    var           var          value
; -----------------------------------------------------
;  f2 --> #'ns-b/f2 --> #'ns-a/f --> 함수 객체: (+ a b)
ns-b> (def f2 #'ns-a/f)
#'ns-b/f2

; f2을 함수로 실행하면 예상한 결과값이 나온다.
; 참고로, Clojure에서는 var도 IFn 인터페이스가 구현되어 있어,
; 함수 자리에 곧바로 올 수 있다.
ns-b> (f2 10 20)
30

; 물론 @f2로 호출도 가능하다. 
ns-b> (@f2 10 20)
30


; ns-a 이름공간으로 돌아간다.
ns-b> (ns ns-a)
nil

; ns-a 이름공간의 함수 f를 '재정의'한다.
;
;  심볼   var          value
; -------------------------------------
;  f -->  #'ns-a/f --> 함수 객체: (* a b)
ns-a> (defn f [a b] (* a b))
#'ns-a/f


; ns-b 이름공간으로 되돌아간다.
ns-a> (ns ns-b)
nil

; f1을 함수로 실행하면, 예전에 정의한 함수 객체 (+ a b)가 실행된다.
;
; 심볼    var           value
; -------------------------------------
;  f1 --> #'ns-b/f1 --> 함수 객체: (+ a b)
ns-b> (f1 10 20)
30

; f2를 평가하면, 새로 정의한 함수 객체 (* a b)가 실행된다.
;
; 심볼       var        var          value
; -----------------------------------------------------
;  f2 --> #'ns-b/f2 --> #'ns-a/f --> 함수 객체: (* a b)
ns-b> (f2 10 20)
200
}|





