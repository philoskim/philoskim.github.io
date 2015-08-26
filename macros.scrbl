#lang scribble/manual
@(require "../my-utils.rkt" "memo.rkt")

@title[#:tag "macros"]{Macros}

@section{매크로에 사용되는 기호들의 명칭}

@descblock|{
`   backquote (= syntax-quote or quasi-quote)
'   quote
~   unquote (= tilde)
~@  unquote-splicing
}|


@section{macro 여부 확인하기}

프로그래밍을 하다 보면, 쓰고자 하는 form이 매크로인지 여부를 알고 싶을 때가 있는데, 다음과
같은 방식으로 확인해 볼 수 있다.

@coding|{
(:macro (meta #'when))
; => true

(meta #'when)
; => {:macro true, :ns #<Namespace clojure.core>, :name when, :added "1.0",
;     :file "clojure/core.clj", :column 1, :line 471, :arglists ([test & body]),
;     :doc "Evaluates test. If logical true, evaluates body in an implicit do."}
}|


@section{Macro 확장시 심볼 바인딩}

매크로가 확장될 때 매크로 내 심볼이 어떻게 바인딩되는 지에 대한 정확한 지식이 있어야
매크로 프로그래밍시 예기치 않은 에러를 피할 수 있다.

@subsection{해석 규칙}

결론부터 이야기하면 다음과 같다.

@itemlist[#:style 'ordered
  @item{` 내부에서 ~에 의해 평가되지 않으면, 그 심볼은 무조건 전역 심볼로 binding된다.}
  @item{평가될 때(` 외부에 있어 자동적으로 평가가 되든, ` 내부에 있으면서 ~에 의해
        강제적으로 평가가 되든), 그 심볼이 매크로의 인수로 이미 선언되어 있는 경우에는
        마치 함수의 인수처럼 binding되고, 그 심볼이 매크로의 인수로 선언되어 있지 않은
        경우에는, 그 외부에 선언된 심볼로 binding된다.}
]

위의 규칙을 더 단순화하면 다음과 같이 정리할 수 있다.

@itemlist[#:style 'ordered
  @item{매크로 내에서 심볼이 평가되는 경우에는, 함수 내 심볼 바인딩 규칙과 완전히 동일하다.}
  @item{매크로 내에서 심볼이 평가되지 않는 경우에는, 무조건 그 namespace내 전역 심볼로
        binding된다.}
]

@subsection{각종 예}

@coding|{
(def a 10)
(def b 100)

;; (2)의 심볼 a는 ` 기호 내부에 있지 않으므로, 자동으로 평가되는 자리에 놓여
;; 있다. 매크로의 인수인 (1)의 a에 바인딩된다. 즉, 함수의 인수인 것처럼 동작한다.
(defmacro m1 [a]   ; (1)
  (+ 5 a))         ; (2)

(m1 50) ; => 55
(macroexpand-1 '(m1 50)) ; => 55

;; 매크로 내의 b는 전역 심볼 b에 바인딩된다.
(defmacro m2 [a]
  (+ 5 a b))

(m2 50) ; => 155
(macroexpand-1 '(m2 50)) ; => 155

;; 매크로 내의 b는 지역 심볼 b에 바인딩된다.
(defmacro m3 [a]
  (let [b 200]
    (+ 5 a b)))

(m3 50) ; => 255
(macroexpand-1 '(m3 50)) ; => 255


;; ` 내부에서 ~에 의해 평가되지 않으면, 무조건 전역 심볼로 해석된다.
(defmacro m4 [a]
  `(+ 5 a b))

(m4 1000) ; => 115
(macroexpand-1 '(m4 1000))
; => (clojure.core/+ 5 user/a user/b)


;; ` 내부에서 ~에 의해 평가되지 않으면, 무조건 전역 심볼로 해석된다.
(defmacro m5 [a]
  (let [b 300]
    `(+ 5 a b)))

(m5 1000) ; => 115
(macroexpand-1 '(m5 1000))
; => (clojure.core/+ 5 user/a user/b)


;; ` 내부에서 ~에 의해 평가되면 함수의 인수인 것처럼 해석되지만,
;; ~에 의해 평가되지 않으면, 전역심볼로 해석된다.
(defmacro m6 [a]
  `(+ 5 ~a b))

(m6 1000) ; => 1105
(macroexpand-1 '(m6 1000))
; => (clojure.core/+ 5 1000 user/b)


;; ` 내부에서 ~에 의해 평가될때, 매크로의 인수로 이미 선언되어 있으면
;; 함수의 인수인 것처럼 해석되지만, 그렇지 않으면 그 외부의 심볼(아래의 경우는
;; 전역 심볼)로 해석된다.
(defmacro m7 [a]
  `(+ 5 ~a ~b))

(m7 1000) ; => 1105
(macroexpand-1 '(m7 1000))
; => (clojure.core/+ 5 1000 100) 


;; ` 내부에서 ~에 의해 평가될때, 매크로의 인수로 이미 선언되어 있으면
;; 함수의 인수인 것처럼 해석되지만, 그렇지 않으면 그 외부의 심볼(아래의 경우는
;; let의 지역 심볼)로  해석된다.
(defmacro m8 [a]
  (let [b 200]
   `(+ 5 ~a ~b)))

(m8 1000) ; => 1205
(macroexpand-1 '(m8 1000))
; => (clojure.core/+ 5 1000 200)


(def c 20)
(def d 40)

(defmacro m9 [a]
  `(+ 5 ~a))

(m9 (* c d)) ; => 805
(macroexpand-1 '(m9 (* c d)))
; => (clojure.core/+ 5 (* c d))

(defmacro m10 [a]
  `(+ 5 a))

(m10 (* c d)) ; => 15
(macroexpand-1 '(m10 (* c d)))
; => (clojure.core/+ 5 user/a)
}|


@section{매크로 내에서의 함수 호출}

@coding|{
(def a (* 2 5))


;; 매크로 내에서 함수를 직접 호출하는 경우
(defmacro m1
  [aa]
  `(+ ~aa 20))

(macroexpand-1 '(m1 (* 2 5)))
; => (clojure.core/+ (* 2 5) 20)


;; 함수 정의를 매크로 외부로 빼낸 경우
(defn f
  [aaa]
  `(+ aaa 20))

(defmacro m2
  [aa]
  (f aa))

(macroexpand-1 '(m2 (* 2 5)))
; => (clojure.core/+ (* 2 5) 20)
}|

결론적으로, 매크로내의 함수 호출 (f aa)는 모듈화의 한 방편이다.






