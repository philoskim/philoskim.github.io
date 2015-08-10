#lang scribble/doc
@(require scribble/manual)
@(require "../my-utils.rkt" "memo.rkt")

@title[#:tag "tips"]{Tips}

@section{array-map}

일반적으로 맵(map)은 순서가 보장되지 않는 자료형이지만, 클로저의 array-map 함수는 입력된
순서가 보장되는 맵을 생성해 준다. 그런데 이 함수를 into 함수 내에서 다음과 같이 사용하면
문제가 발생할 수 있다.

@coding|{
(def vec1 [[:a 1] [:b 2] [:c 3] [:d 4] [:e 5] [:f 6] [:g 7] [:h 8]])

(into (array-map) vec1)
; => {:a 1, :b 2, :c 3, :d 4, :e 5, :f 6, :g 7, :h 8}
}|

여기까지는 문제가 없다. 예상한 대로 출력된 맵이 입력한 순서대로 출력된다.

타입을 확인해 보면 PersistentArrayMap으로 출력된다.

@coding|{
(type (into (array-map) vec1))
; => clojure.lang.PersistentArrayMap
}|

하지만 입력되는 요소의 개수가 8개를 넘어서자 마자, 입력된 순서가 유지되지 않게 된다.

@coding|{
(def vec2
  [[:a 1] [:b 2] [:c 3] [:d 4] [:e 5] [:f 6] [:g 7] [:h 8] [:i 9]])

(into (array-map) vec2)
; => {:e 5, :g 7, :c 3, :h 8, :b 2, :d 4, :f 6, :i 9, :a 1}
}|

타입을 확인해 보면 PersistentHashMap으로 변해 있다.

@coding|{
(type (into (array-map) vec2))
; => clojure.lang.PersistentHashMap
}|

이러한 현상은 버그가 아니라 의도된 결과이다. array-map 함수로 생성되었더라도 요소의 수가
일정한 개수(8개)를 넘어서면, 연산의 효율성을 위해 hash-map으로 타입이 자동으로 바뀌도록
설계되어 있다.

하지만 개수에 상관없이 순서가 보장된 맵을 생성하기를 원한다면, array-map 함수로 직접
생성해 주면 된다.

@coding|{
(array-map :a 1 :b 2 :c 3 :d 4 :e 5 :f 6 :g 7 :h 8 :i 9)
; => {:a 1, :b 2, :c 3, :d 4, :e 5, :f 6, :g 7, :h 8, :i 9}
}|

실제 코드에서는 다음과 같은 형태로 많이 쓰이게 된다.

@coding|{
(def vec3 [:a 1 :b 2 :c 3 :d 4 :e 5 :f 6 :g 7 :h 8 :i 9])

(apply array-map vec3)
; => {:a 1, :b 2, :c 3, :d 4, :e 5, :f 6, :g 7, :h 8, :i 9}
}|

