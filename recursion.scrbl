#lang scribble/doc
@(require scribble/manual)
@(require "../my-utils.rkt")

@title[#:tag "recursion"]{Recursion}

@section[#:tag "tail-recursion"]{Tail Recursion(꼬리 재귀)}

재귀(recursion)라는 개념은, C, C++ 혹은 Java 같은 일반 프로그래밍 언어에서도 존재하지만,
실제적으로는 잘 쓰이지 않는데, 그 이유는 재귀 함수의 반복적인 호출이 stack overflow를
초래하기 쉽기 때문이다.

그런데 전통적으로 리습 계열의 언어에서는, 꼬리 호출 최적화(Tail Call Optimization)라는
기법을 통해, stack을 전혀 소비하지 않는 방식의 재귀 호출 방식을 고안해 냈는데, 이를 꼬리
재귀 (tail recursion)라고 부른다(단, 모든 종류의 재귀 함수를 꼬리 재귀 함수의 형태로 환원할
수 있는 것은 아니다). 따라서 꼬리 호출 최적화 기법을 적용할 수 있는 조건에 맞게
프로그래머가 재귀 함수를 작성하면, 컴파일러가 이 함수를, stack overflow를 일으키지 않는
함수로 변환해 준다. 이 과정을 TCO(Tail Call Optimization: 꼬리 호출 최적화)라고 부른다.

이 TCO 기법은 컴파일러 차원에서 지원되어야 하는 기능으로, Lisp 계열 언어들에서 최초로
시도된 이 기법은 최근에야 다른 언어들의 컴파일러에서도 지원하기 시작하고 있는데, 그 중에는
GNU gcc 컴파일러도 있다.

일단 재귀 함수의 예부터 살펴보자. 재귀 함수를 설명할 떄, 가장 많이 예로 드는 factorial
함수를 구현해 보면 다음과 같다.

@coding|{
(defn factorial-1
  [n]
  (if (< n 2)
      1                                 ; (1)
      (*' n (factorial-1 (dec n))) ))
      ;--                                 (2)
                        ;-------          (3)
           ;----------------------        (4)
      ;------------------------------     (5)

(factorial-1 5)
; => 120

(factorial-1 10000)
; =>  [Thrown class java.lang.StackOverflowError]
}|

@itemlist[

@item{(2)에서 곱셈을 수행할 때, 함수 @tt{*}를 사용하지 않고 @tt{*'}를 사용한 이유:
Clojure 1.3 version 이전에는 @tt{*'} 함수가 없었다. 그때에는 Clojure의 정수의 기본형은
Java의 Integer형(4바이트 정수형)이었고, 연산 도중에 이 Integer형의 범위를 넘어서는 값이
나오면, 자동으로 Java의 BigInteger형으로 변환이 이루어졌다. 그런데 Clojure 1.3 버전
이후로는, Clojure의 정수의 기본형이 Java의 Long형(8바이트 정수형)으로 바뀌었을 뿐만
아니라, 함수 @tt{*}는 연산 도중 overflow가 일어나면 integer overflow ArithmeticException이
발생할 뿐, Java의 BigInteger형으로의 변환이 자동으로 이루어지지 않게 변경되었다. 이는
Clojure의 전반적인 실행 속도를 끌어올리기 위한 조치의 일환으로 이해된다. 반면에 함수
@tt{*'}는 Java의 BigInteger형으로의 변환이 자동으로 일어나므로, Java의 Long형을 벗어나는 큰
수를 다루어야 하는 경우에는 @tt{*'} 함수를 사용하는 것이 바람직하다.}

]

그런데 위에서 정의한 @tt{factorial-1} 함수는, 꼬리 재귀 함수가 아니다. 흔히들 꼬리
부위라고 하면, 위의 코드 중에, (3) 또는 (4) 부분을 꼬리라고 생각하기 쉬운데, 함수의 말단
부분에 위치해 있다고 해서 그 부분을 꼬리라고 하지는 않는다는 점에 주의해야 한다. 꼬리
재귀에서, @tt{`꼬리'}의 가장 정확한 개념은 @tt{`함수가 최종적으로 리턴값을 반환하는 곳'}을
일컫는다. 정확히 말하자면, 위의 코드에서 꼬리 부분은 (1)과 (5)의 두 부분이다. 이 두 부분
모두 이 함수가 최종적으로 리턴값을 반환하는 곳이기 때문이다. 이 두 자리 중 어느 한 곳에,
@tt{factorial-1} 함수를 다시 호출하는 코드가 있어야, 꼬리 재귀 함수의 조건을 충족시키게
된다.따라서 예상한 대로, 10000과 같은 큰 수를 인수로 주고 함수를 실행하니,
StackOverflowError가 발생하였다.

그러면 위의 코드를 꼬리 재귀의 형태로 바꾸어 보자.

@coding|{
(defn factorial-2
  ([n] (factorial-2 n 1))   ; 인수의 개수가 한 개일 때 호출
  ([n acc]                  ; 인수의 개수가 두 개일 때 호출
    (if (< n 2)
        acc
        (factorial-2 (dec n) (*' n acc)) )))
       ;--------------------------------       (1)

(factorial-2 5)
; => 120

(factorial-2 10000)
; =>   [Thrown class java.lang.StackOverflowError]
}|

@itemlist[

  @item{라인 9에서 @tt{factorial-2}의 인수가 하나이므로, 라인 2의 함수를 호출하다. 그런데
라인 2에서는, 인수가 2개인 함수, 라인 3을 다시 호출한다. 이때 인수 @tt{acc}(accumulator)의
값이 1로 초기화된 상태로 라인 3을 호출하게 된다. Clojure에서는 인수의 개수에 따라 각각
다르게 함수를 정의할 수 있다. 이것은 C++/Java에서의 function overloading과 유사하지만,
인수의 데이터형과는 관계 없이, 오직 인수의 개수만을 따져 그에 상응하는 함수 정의를
호출한다는 점에서는, C++/Java의 function overloading과 다르다.}

]

위의 코드에서는, (1)로 표시된 꼬리의 위치에 @tt{factorial-2} 함수가 다시 위치해 있으므로,
이 함수는 꼬리 재귀 함수의 조건을 충족시킨 코드이다. 꼬리 재귀 함수 이해의 핵심은, 계산
중에 발생하는 모든 상태(state) 값을 @tt{`함수의 인수 형태'}로 건네줌으로써, 재귀 함수
내부에 어떠한 상태(state) 값도 지니지 않게 하는 데 있다. 위의 코드에서는, 재귀 호출
때마다의 계산 결과(상태 값 @tt{n}과 @tt{acc}) 값을, @tt{factorial-2}의 인수로 다시 전달하고
있음에 주목해야 한다.

그런데 라인 12의 실행 결과를 보면, 여전히 StackOverflowError가 발생하고 있다. 만약 위의
코드가 Common Lisp이나 Scheme 언어로 작성되었다면, 이 언어들의 컴파일러들은 (1)의 부분이
TCO를 적용할 수 있는 부분임을 알아채고, 이 함수를 stack을 소모하지 않는 함수로
@tt{`자동으로'} 변환하는 작업을 수행해 주므로, StackOverflowError가 발생하지 않는다. 하지만
Clojure에서는 프로그래머가 @tt{`수동으로'} 꼬리 재귀를 하는 부분이라는 것을 컴파일러에게
@tt{`명시적으로'} 알려 주어야 하는데, special-form인 @tt{recur}가 이 역을 맡는다.

그래서 다음과 같이 코드를 수정해야 StackOverflowError가 발생하지 않는다.

@coding|{
(defn factorial
  ([n] (factorial n 1))
  ([n acc]
   (if (< n 2)
       acc
       (recur (dec n) (*' n acc)) )))

(factorial 5)
; => 120

(factorial 10000)
;; => 28462596809170545189064132......
}|

앞에서도 언급했듯이, TCO 기능은 컴파일러 수준에서 지원해야 하는 기능이다. 그런데 Clojure가
기반하고 있는 Java의 컴파일러는 자체적으로 이 TCO 기능을 지원하지 않았다(Java 7.0부터는
지원한다고 한다). 그래서 이 기능은 'Clojure 컴파일러'가 별도로 지원할 수 밖에 없었는데,
Clojure 언어의 창시자인 Rich Hickey는, 프로그래머가 special-form인 @tt{recur}를 통해 직접
'수동으로' Tail Recursion을 지정하는 방식을 택했다. 이로부터 얻는 이점은, 코드를 분석할 때
@tt{recur} 호출이 있으면, 꼬리 재귀 함수임을 곧바로 파악할 수 있다는 데 있다. 반면에,
Common Lisp이나 Scheme의 경우에는, 꼬리 재귀 함수 최적화 기법이 실제로 적용되는 경우인지
아닌지를 파악하려면, 코드를 일일이 논리적으로 분석해 보아야 한다.


@section[#:tag "mutual-tail-recursion-and-trampoline"]{Mutual Tail Recursion(상호 꼬리 재귀)과 trampoline 함수}

프로그램을 짜다 보면 함수 A가 함수 B를 호출하고, 함수 B가 다시 함수 A를 호출해야 하는
경우가 발생하기도 한다. 이런 경우를 Mutual Recursion(상호 재귀)라고 하는데, 다음의 코드가
그 한 예이다.

@coding|{
(declare my-odd?-1)   ; 전방 선언

(defn my-even?-1 [n]
  (if (zero? n)
    true
    (my-odd?-1 (dec (Math/abs n))) ))

(defn my-odd?-1 [n]
  (if (zero? n)
    false
    (my-even?-1 (dec (Math/abs n))) ))

(my-even?-1 10)   ;=> true
(my-odd?-1  10)   ;=> false

(my-odd?-1 10000)
; =>   [Thrown class java.lang.StackOverflowError]
}|

인수의 값을 크게 높이자, 예외 없이 StackOverflowError가 발생하였다. 이 문제를 해결하려면,
Mutual Tail Recursion 함수를 작성해야 하는데, Clojure에서는, 위의 라인 6과 11을, 아래의
라인 6과 11처럼 익명 함수(anonymous function)의 형태로 변경해 준 후에, @tt{trampoline} 함수를
통해 호출해 주면 된다. 다시 말해, @tt{trampoline} 함수는 mutual tail recursion 호출을
구현하기 위해 Clojure에 도입된 함수다.

여기서 가장 중요한 점은, 위의 라인 6의 경우에 @tt{(my-odd?-1 ...)} 코드는, 이미 정의되어
있는 기존의 함수 @tt{my-odd?-1}을, 단지 반복해서 호출하는 것임에 반해, 아래의 라인 6의
@tt{#(my-odd?-2 ...)} 코드는, 실행될 때마다 매번 @tt{`새로 생성'}된 익명 함수 객체를
리턴값으로 반환하는 데 있다. 리습 계열 언어에서는 이와같이 코드 실행 중에 새로운 함수를
동적으로 생성할 수 있는데, 이 차이점을 정확하게 이해하지 못하면, 아래의 코드를 이해하는데
지장이 있을 것이다.

이 새로 생성된 함수 객체 안에, 이전 단계에서 처리한 state(상태 값)를 저장한 후에, 이 객체를
@tt{`다음 단계에 실행될 함수'}의 @tt{`인수'} 형태로 넘기게 되므로, stack을 사용하지 않게
만든다.

@coding|{
(declare my-odd?-2)   ; 전방 선언

(defn my-even?-2 [n]
  (if (zero? n)
    true
    #(my-odd?-2 (dec (Math/abs n))) ))

(defn my-odd?-2 [n]
  (if (zero? n)
    false
    #(my-even?-2 (dec (Math/abs n))) ))

(trampoline my-even?-2 10000)   ;=> true
(trampoline my-odd?-2  10000)   ;=> false
}|

그런데 @tt{my-even?-2} 또는 @tt{my-odd?-2} 함수를 호출할 때마다, @tt{trampoline} 함수를
경유해서 호출해야 한다면, 그것도 상당히 성가신 일임에 틀림없다. 그래서 위의
@tt{my-even?-2}와 @tt{my-odd?-2} 함수 정의부를, 다음과 같이 지역 함수 @tt{e?}와 @tt{o?}로
바꾼 후에, @tt{my-even?} 함수의 내부에서 @tt{trampoline} 함수를 호출하도록 하는 것이 더
나은 방식이다.

@coding|{
(defn my-even? [n]
  (letfn [(e? [n]
              (if (zero? n)
                true
                #(o? (dec (Math/abs n))) ))
          (o? [n]
              (if (zero? n)
                false
                #(e? (dec (Math/abs n))) ))]
    (trampoline e? n) ))

(defn my-odd? [n]
  (not (my-even? n)))

(my-even? 10000)   ;=> true
(my-odd?  10000)   ;=> false
}|

StackOverflowError가 발생하지 않음을 확인할 수 있다.


@section{재귀 방식의 분류}

@subsection{accumulator passing style}

재귀 함수의 인자에, 함수가 계산한 '결과 값'을 전달하는 방식이다.

@coding|{
(defn fact-aps 
  ([n] (fact-aps n 1))
  ([n acc]
   (if (zero? n)
     acc
     (recur (dec n) (* n acc)))))

(fact-aps 10)
; => 120

(fact-aps 100000N)
; => 2824229407960347874293421578024535518477494926091224850578...
}|

@subsection{continuation passing style}

재귀 함수의 인자에, 함수 객체(함수 객체 내부에 상태를 내장한 상태로) 자체를 전달하는
방식이다.

@coding|{
(defn fact-cps 
  ([n] (fact-cps n identity))
  ([n cont]
   (if (zero? n)
     (cont 1)
     (recur (dec n) (fn [x] (cont (* n x)))))))

(fact-cps 10)
; => 120

(fact-cps 10000N)
; => java.lang.StackOverflowError  
}|

그런데 이상하게도 StackOverflowError가 발생한다. 그 이유를 분석해 보면

@coding|{
(fact-cps 0)
; -> (fact-cps 0 identity)
; -> (identity 0)
; => 1

(fact-cps 1)
; -> (fact-cps 1 identity)
; -> (fact-cps 0 (fn [x] (identity (* 1 x))))
; -> ((fn [x] (identity (* 1 x))) 1)
; => 1

(fact-cps 2)
; -> (fact-cps 2 identity)
; -> (fact-cps 1 (fn [x] (identity (* 2 x))))
; -> (fact-cps 0 (fn [x] ((fn [x] (identity (* 2 x)))
;    		          (* 1 x))))
; -> ((fn [x] ((fn [x] (identity (* 2 x)))   ; (1)
;      	       (* 1 x)))
;     1)
; => 2
}|

위의 분석 과정을 통해 내린 결론은, fact-cps 함수도, (1) 이전 까지는 다른 tail recursion
함수와 마찬가지로 스택을 소모하지 않지만, 맨 마지막에 도달해 계산을 실제로 수행할 때,
중첩된 함수를 실행하게 되어서 이때 스택을 많이 사용하게 되어 StackOverflowError가 발생하게
된댜.

위의 cps 방식의 구현 예제도 Scheme 같은 tail call optimization을 자동으로 지원하는
언어에서는 스택오버플로 에러가 발생하지 않는다. 그러데 JVM에서는 tail call optimization을
지원하지 않아서 스택오버플로 에러가 발생한 것이다. 그래서 클로저에서 독자적으로 지원하는
tail call optimization을 사용해야 하는데, 명시적으로 recur를 호출해 주어야만 한다.

아래에 trampoline 함수를 사용해 factorial을 구하는 함수를 작성해 보았다.

@coding|{
(defn fact-tramp 
  ([n] (fact-tramp n 1))
  ([n acc]
   (if (zero? n)
     acc
     #(fact-tramp (dec n) (* n acc)))))

(trampoline fact-tramp 10)
; => 3628800

(trampoline fact-tramp 10000N)
; => 28462596809170545189064132......
}|

스택오버클로 에러가 발생하지 않고 제대로 결과를 반환합니디.

그 이유가 궁금해서 clojure.core의 trampoline 함수 코드(불필요한 부분은 생략)를
살펴보았습니다.

@coding|{
(defn trampoline
  ([f]
     (let [ret (f)]   ; (1)
       (if (fn? ret)
         (recur ret)  ; (2)
         ret)))
  ([f & args]
     (trampoline #(apply f args))))
}|

비결은 (1) 부분에 있었다. 함수 안에서 함수를 호출하면 스택에 쌓여 나가지만, 함수 호출을
'끝낸 후', 다시 새로이 리턴받츤 함수(여기서는 ret)를 호출하는 기법을 써서 스택 쌓이는 것을
피해 나가는 절묘한 기법을 사용하고 있다.

그래서 내린 결론은, trampoline도 recur의 인수로 함수(함수가 계산한 '결과'가 아닌) 자체를
넘겨주므로 cps로 볼 수 있다는 것이다. 다만, fact-cps처럼 cps를 직접 구현하면 스택오버플로
에러가 발생하기에, 이를 회피할 수 있는 방법으로 trampoline를 별도의 함수를 제공하고 있다는
것이다.


