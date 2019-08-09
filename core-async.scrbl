#lang scribble/manual
@(require "../my-utils.rkt" "memo.rkt")

@title[#:tag "core-async"]{core.async}

Clojure(Script)에 구현되어 있는 core.async는, Non-blocking IO 용도로도 활용이 가능하지만,
더 중요한 용도는, 비동기적으로 처리되는 것들(쓰레드나 콜백함수)을, 마치 동기식
프로그래밍하듯이, 자신이 원하는 순서대로 실행시킬 수 있다는 데 있다.

예를 들어, 하나의 일을 처리하는 데, 쓰레드 A가 처리한 결과를 쓰레드 B가 받아, 다시 그
결과를 쓰레드 C에 넘기는 식으로 프로그래밍 하는 것이 가능하다. (아래의 그림들에서 문자 A,
B, C, 등등은 각각의 쓰레드 혹은 콜백함수를 표시하고, 화살표는 처리 순서를 표시한다)

@descblock|{
A --> B --> C --> D --> E --> F
}|


다음의 경우에서처럼, 쓰레드 C의 처리 결과에 따라 쓰레드 F로 곧바로 점프하는 것도
가능하다.

@descblock|{
A --> B --> C --> D --> E --> F
            |                 ^
            |                 |
            -------------------
}|

다음의 경우에서처럼, 쓰레드 C의 처리 결과에 따라 다른 파이프 라인을 타는 것도 가능하다.

@descblock|{
A --> B --> C --> D --> E --> F
            |
            ----> G --> H --> I  
}|

다음의 경우에서처럼, 쓰레드 D의 처리 결과에 따라 루프를 타는 것도 가능하다.

@descblock|{
A --> B --> C --> D --> E --> F
      ^           |
      |           |
      -------------
}|

위에서 든 모든 사례를, 순수하게 자바스크립트의 콜백함수 스타일로만 구현하는 것은 거의
불가능하거나, 가능하더라도 아주 복잡하게 구현될 것이고, 콜백함수 안에 콜백 함수가 중첩되는
방식으로 구현할 수 밖에 없어, 그 코드는 이미 이해하기 어려운 거의 난장판 수준이 되어
있을 것이다.

위에 든 예들 중에서, 두 번째 경우를 core.async로 구현한 예는 다음과 같다.

@coding|{
(ns async.test
  (:refer-clojure :exclude [map reduce into partition
                            partition-by take merge])
  (:require [clojure.core.async :refer :all])

(defn async-sample
  [init]
  (let [ch1 (chan)
        ch2 (chan)
        ch3 (chan)
        ch4 (chan)
        ch5 (chan)
        ch6 (chan)]
    (thread                  ;; thread A
      (let [val (<!! ch1)]
        (println "inside thread A: val =" val)
        (>!! ch2 (+ val 1)) ))

    (thread                  ;; thread B
      (let [val (<!! ch2)]
        (println "inside thread B: val =" val)
        (>!! ch3 (+ val 1)) ))

    (thread                  ;; thread C
      (let [val (<!! ch3)]
        (println "inside thread C: val =" val)
        (if (< val 10)
          (>!! ch4 (+ val 1))
          (>!! ch6 (+ val 100)) )))

    (thread                  ;; thread D
      (let [val (<!! ch4)]
        (println "inside thread D: val =" val)
        (>!! ch5 (+ val 1)) ))

    (thread                  ;; thread E
      (let [val (<!! ch5)]
        (println "inside thread E: val =" val)
        (>!! ch6 (+ val 1)) ))
        
    (thread                  ;; thread F
      (let [val (<!! ch6)]
        (println "inside thread F: val =" val) ))

    (println "ch1 initialized.")
    (>!! ch1 init) ))

   
(async-sample 1)
; >> ch1 initialized.
; >> inside thread A: val = 1
; >> inside thread B: val = 2
; >> inside thread C: val = 3
; >> inside thread D: val = 4
; >> inside thread E: val = 5
; >> inside thread F: val = 6

(async-sample 10)
; >> ch1 initialized.
; >> inside thread A: val = 10
; >> inside thread B: val = 11
; >> inside thread C: val = 12
; >> inside thread F: val = 112
}|

다음은 위의 코드 이해를 위한 약간의 설명이다.

@itemlist[
  @item{(chan): 채널을 하나 생성한다.}
  @item{(>!! ch 1): 채널 ch에 1이라는 값을 집어 넣는다.}
  @item{(<!! ch): 채널 ch에 담겨 있는 값 한 개를 빼낸다. 채널에 아무런 값도 없을 때에는
        실행을 멈추고, 채널에 값이 들어 올 떄까지 무한정 기다린다(이로 인해 동기적인
        처리가 가능해진다).}
]

위의 예에서 볼 수 있듯이, core.async에서는 channel이라는 중계 수단을 거쳐 비동기적인
쓰레드들간의 동기화를 이훈다. 코드가 대단히 직관적이고 단순하다. 클로저 프로그래밍의
핵심적인 가치인 '단순함'의 추구의 결과물이다. 무엇보다도 코드는 구조가 단순해야
한다. 그래야 프로그래머가 버그를 양산하지 않게 된다. 이것을 자바스크립트로 구현하려면
콜백 함수 안에 콜백 함수를 여러 번 중첩해야만 해서 대단히 복잡한 구조의 코딩을 해야만
한다. callback hell이라는 말이 그냥 나왔겠는가?
 
Rich Hickey가 go 언어의 go block의 영향을 받아 Clojure의 core.async를 먼저 구현했고, David
Nolen이 그의 뒤를 이어 ClojureScript의 core.async를 구현했다(참고로, 이 두 사람은 현재
Cognitect라는 회사에서 함께 일하고 있어, 서로 간에 시너지 효과를 낼 수 있으리라 여겨진다).

Clojure의 core.async에 있는 함수들은 크게 두 종류로 나쥔다. API 문서를 보면 알겠지만,
함수 이름 뒤에 !!(느낌표 2개)가 붙은 것들은 쓰레드 안에서만 사용하라는 것이고, !(느낌표
1개)가 붙은 것들은 go block 안에서만 사용하라는 것이다. ClojureScript는,
자바스크립트상에서 돌아가므로, 당연히 단일 쓰레드 상에서만 돌아가는 느낌표 하나 붙은
함수들만 사용해야 한다. 그리고 go block은 경량 쓰레드라고 보면 되는데, Node.js에서의 async
callback 함수를 구현할 때와 마찬가지로, 하나의 쓰레드 안에서 여러 개의 go block을
관리/수행하도록 구현되어 있다.

위에서 든 코드를 자바스크립트에서 수행하려면, 다음과 같이 코드를 약간 수정해야 한다.

@coding|{
(ns async.test
  (:refer-clojure :exclude [map filter distinct remove])
  (:require-macros [cljs.core.async.macros :refer [go]])
  (:require [cljs.core.async :refer [>! <! chan put!]]))

;; 이 함수를 호출해야, println의 출력 결과가 웹 브라우저의 console 창에
;; 제대로 출력된다.
(enable-console-print!)

(defn async-sample
  [init]
  (let [ch1 (chan)
        ch2 (chan)
        ch3 (chan)
        ch4 (chan)
        ch5 (chan)
        ch6 (chan)
        result 0]
    (go                  ;; go block A
      (let [val (<! ch1)]
        (println "inside go A: val =" val)
        (>! ch2 (+ val 1)) ))

    (go                  ;; go block B
      (let [val (<! ch2)]
        (println "inside go B: val =" val)
        (>! ch3 (+ val 1)) ))

    (go                  ;; go block C
      (let [val (<! ch3)]
        (println "inside go C: val =" val)
        (if (< val 10)
          (>! ch4 (+ val 1))
          (>! ch6 (+ val 100) ))))

    (go                  ;; go block D
      (let [val (<! ch4)]
        (println "inside go D: val =" val)
        (>! ch5 (+ val 1)) ))

    (go                  ;; go block E
      (let [val (<! ch5)]
        (println "inside go E: val =" val)
        (>! ch6 (+ val 1)) ))
        
    (go                  ;; go block F
      (let [val (<! ch6)]
        (println "inside go F: val =" val) ))

    (println "ch1 initialized.")
    (put! ch1 init) ))
}|
