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


@section{coll? sequential? seq? 간의 차이}

coll?, sequential?, seq? 간의 차이를 먼저 도표를 통해 설명하면 다음과 같다.

@descblock|{
          coll?   sequential?   seq?
---------------------------------------
list       O          O          O
vector     O          O          X
map        O          X          X
set        O          X          X
---------------------------------------
}|

클로저의 collection 자료형에 위의 4 종류가 있다. 햇갈리는 것은 아마도 sequential 자료형과
seq 자료형일 것이다. sequential(순차적인) 자료형은 이름 자체에서 이미 알수 있듯이 자료형의
성격 자체가 순서가 있는 자료형을 말한다.  리스트나 벡터는 원래부터 순서가 있는 자료형인데
반해, map이나 set 자료형은 자료형 자체가 순서가 없는 개념이라는 것을 이미 알고 있다면,
이해에 큰 문제는 없으리라 보인다.

문제는 seq 자료형인데, clojure.lang.ISeq 프로토콜을 구현한 자료형이 이에 해당한다. 그리고
이 ISeq 프로토콜은 first와 rest 함수를 구현할 것을 요구한다. 그런데 이 두 함수는 리스트
자료형 구현에 필수적인 요소들이다. 위의 표에서도 seq? 함수 적용 결과가 리스트 자료형에서만
'O'로 표시된 것을 보더라도 알 수 있다.

그런데, seq 자료형이 아닌 vector, map, set 자료형들도, seq 함수를 적용하면 seq 자료형으로
변환이 된다.

@coding|{
(map seq? ['(1 2) [3 4] {5 6} #{7 8}])
; => (true false false false)

(map seq? ['(1 2) (seq [3 4]) (seq {5 6}) (seq #{7 8})])
; => (true true true true)
}|

실제로 클로저의 core 함수들 중 상당수(100개 이상)가, 그 함수의 인자로 collection 자료형을
받은 후에, 그 결과값으로 seq 자료형을 반환한다. 그래서 4가지 collection 자료형이 있지만,
이 함수들을 거치고 나면 seq 자료형으로 변환되어, 실제로는 거의 seq 자료형만을
다루게 된다. 클로저 언어는 타 언어들에 비해 제공하는 자료형이 무척 적은 데, 제공되는
이 4개의 collection 자료형마저도 더 추상화해서, 마치 하나의 자료형을 다루듯이 쓸 수 있게 해
줌으로써, 각각의 자료형마다 별개의 함수를 호출해야 하는 번거로움을 없애 주게 된다. 만약
이 4개의 collection 자료형마다 따로 따로 함수를 만들었다면, 위에서 말한 100개의 함수가
아니라 400개 이상의 함수를 제공해야만 했을테니까.

한 마디로 요약하자면, seq 자료형은 리스트가 아닌 자료형(vector, map, set)들을, 리스트처럼
다룰 수 있게 해 주는 장치라고 이해하면 된다.
