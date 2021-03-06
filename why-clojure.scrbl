#lang scribble/manual
@(require "../my-utils.rkt" "memo.rkt")

@title[#:tag "why-clojure"]{Why Clojure?}


@section{Clojure는 왜 OOP가 아닌가?}

내가 보기에 Clojure의 창시자인 Rich Hickey는, 프로그래밍의 본질적인 문제(복잡성에 대한
해결)에 대한 해법을 Clojure라는 언어를 통해 제시했다는 점에서, 프로그래머가 아니라
철학자이다. 진정한 철학자는 시대의 '본질적 문제'을 정확히 읽고 그 해법을 제시한다는 한다는
점에서, 유사점이 있기 때문이다. 오늘날 소프트웨어 업계가 당면한 문제들의 대부분은 주로
프로그램의 구조가 복잡하다는 데서 기인한다. 그런데 이 복잡성은 필연적(본질적)인 복잡성과
우연적인(불필요한) 복잡성으로 나누어 볼 수 있는데, Clojure 언어 설계의 가장 중요한 철학은
바로 이 불필요한 복잡성을 최대한 제거하는 데 있다. 그런 점에서, Clojure는 단순히 또 다른
Lisp 이라기 보다는, Lisp의 강점과 Functional Language의 강점을 결합한, Thomas Kuhn이 <과학
혁명의 구조>라는 책에서 언급한 것과 같은, '새로운 패러다임(차원)'의 Lisp이다.

프로그램의 구조가 '복잡'해서 개발 기간이 늘어나고, 버그도 늘어나고, 그에 따라 개발 기간과
개발 비용도 늘어난다. 당연히 유지/보수도 힘들어진다. 문제는 현 소프트웨어 업계가 이
복잡성을 '당연한 것'으로 받아들이고 있다는 데 더 큰 문제가 있다. 문제를 문제로 인식하지
못하는 것, 이것이 바로 가장 큰 문제이다. 예를 들어, 어떤 사람은 나는 디자인 패턴을 20개
이상 알고 있다고 자랑한다. 그런데 그 디자인 패턴이라는 것이, 클래스라는 개념 자체가 없으면
아예 필요조차 하지 않는 것들이다. 디자인 패턴의 정확한 의미가 '클래스 디자인 패턴' 아닌가?
나에게는 클래스의 도입으로 야기된 우연적 복잡성을, 더 복잡한 형태로 극복하려는 시도로 보일
뿐이다.

내가 객체 지향 프로그래밍(Object-Oriented Programming)이 무조건 나쁘다는 취지로 이야기하는
것은 물론 아니다. 객체 지향 방식이 유용한 분야는 당연히 있을 것이다. 단지 그것이
프로그래밍의 모든 것인 양 여기고, 모든 문제를 객체 지향 방식으로 처리하려고만 할뿐, 더
나은 방식의 해결책을 추구하지 않으려는 자세를 지적하고 싶은 것이다.

나는 불변 데이터의 강점은, 불변 데이터의 도입으로 프로그래밍이 단순화되었다는 점에서 찾고
있다. 디버깅 단위가 함수 하나로 국한되니, 문제의 원인을 함수 하나의 내부에서 찾아서
처리하면 그것으로 끝이다. 객체 지향의 경우에는 클래스 전체를 염두에 두어야 하지 않는가?
게다가 상속이 있는 경우, 상위 클래스의 소스 코드까지 이해해야 하는데, 이 모든 것이 가변
데이터(멤버 변수)의 상태를 이 메서드, 저 메서드가 건드려서 생기는 문제들이다. 프로그래밍
단위가 함수 하나만으로 좁혀지는 것 자체가 프로그래밍의 복잡성을 상당 부분 제거해 준다고
보기 때문에, 나는 함수형 언어를 특히 리습 계열 언어인 Clojure를 높게 평가한다.

예를 들어, 동일한 일을 수행하는데, Python과 Clojure로 작성했다고 가정해 보자. 공교롭게도
라인 수도 거의 같다. 그러면 이 두 프로그램은 등가인가? 나는 그렇지 않다고 본다. 파이썬은
객체 지향 언어이어서, 프로그래밍 단위가 클래스일 수밖에 없다는 점에서, 프로그래밍 단위가
함수 단위인 클로저 코드에 비해 복잡성은 훨씬 큰 것이다. 복잡성이라는 기준에서 볼 때는 큰
차이가 있는 것이고, 아마도 클래스의 크기가 늘어날 수록 그 복잡성은 기하급수적으로 늘어날
수 있다는 점에서, Clojure로 작성된 코드가 더 우월하다고 나는 판단한다.

나도 처음엔 불변 데이터를 다루는 것이 매우 짜증스러웠다. 그냥 값을 바꾸면 쉽게 해결될 일을
굳이 이렇게 어렵게 처리할 필요가 있을까 하는 의구심이 많이 들었던 것도 사실이었지만,
요즘에는 거꾸로 mutable 데이터로 문제롤 해결해야 하는 경우에도, 이것을 불변 데이터로
처리할 수는 없을까 고민하게 되는 정도로 바뀌었다. 결국은 익숙해지기까지 시간이 걸릴 수밖에
없는 문제인 것 같다. 굳이 왜 이렇게 하느냐고 반문할 수도 있겠지만, 그렇게 하는 것이
프로그램의 복잡도를 줄여, 결과적으로 개발 기간의 단축이나 유지/보수의 수월함이라는
이익으로 다가오기 때문이다. 한 마디로 말하자면 그것이 궁극적으로 '생산성'을 높여주기
때문이지, 다른 이유는 없다.

결론적으로, Clojure의 장점은 'Immutable data + Lisp macro + JVM Library'를 모두 이용할 수
있다는 데 있다. 게다가 Clojure는 STM(Software Transaction Memory)이 구현되어 있어서,
Thread 관리를 자동으로 해 준다는 점도 무시할 수 없는 강점이다. Clojure 프로그래머들은
Thread 관리를 직접 하지 않는다. 이건 마치 Garbage Collection을 언어 자체가 대신 처리해
줌으로써, 프로그래머가 메모리를 직접 관리해야 하는 부담으로부터 해방되었듯이,
Multi-threads 관련 처리를 언어가 대신해 줌으로써, 프로그래머가 직접 쓰레드를 관리해야 하는
부담으로부터 해방된 것으로 이해하면 된다.


@section{Common Lisp은 함수형 언어인가?}

Clojure는 리습 계열 언어이기도 하다. 그래서 리습 계열 언어의 원조라 할 수 있는 Common
Lisp과의 비교를 통해 '함수형 프로그래밍이란 무엇인가'에 대한 이야기를 풀어 나가겠다. 많은
사람들이 Common Lisp을 함수형 프로그래밍 언어로 알고 있는 것 같다. 이런 견해는 함수형
언어를 어떻게 정의하느냐에 따라, 맞는 견해일 수도 있고, 부적절한 표현일 수도 있다.

먼저 함수형 언어를 '넓은' 의미에서 정의하면, Common Lisp은 함수형 언어의 조건을 다 갖추고
있다.

다음의 조건 4 가지를 충족시키면, 그 함수는 일급 함수(fisrt-class function)라고 부르고,
일급 함수를 지원하는 언어는 '전통적인 의미'에서의 함수형 언어라고 부를 수 있다.

@itemlist[#:style 'ordered
  @item{함수 객체를 변수에 대입할 수 있다.
    @coding|{
    (def double (fn [a]
                  (* 2 a)))

    (double 10)    ; => 20

    (def double2 double)
    
    (double2 10)   ; => 20
    }| }
    
  @item{함수 객체를 함수의 인수로 전달할 수 있다.
    @coding|{
    (defn calc [op a b]
      (op a b))

    (calc + 10 20)   ; => 30
    (calc * 10 20)   ; => 200
  }| }
  
  @item{함수 객체를 함수의 반환값으로 반환할 수 있다.
    @coding|{
    (defn operator [op]
      (cond
        (= op :plus)  +
        (= op :minus) -))

    ((operator :plus) 10 20)    ; => 30
    ((operator :minus) 10 20)   ; => -10
    }| }
    
  @item{함수 객체를 동적으로 생성할 수 있다.
    @coding|{
    (defn multiple [n]
      (fn [a]
        (* n a)))

    (def double (multiple 2))
    ; => #<Var@4340684b: #object[user$multiple$fn__12286 0x26a894a2]>

    (def triple (multiple 3))
    ; => #<Var@fc4d31e: #object[user$multiple$fn__12286 0x1a4b7c5d]>

    (double 10)   ; => 20
    (triple 10)   ; => 30
    }| }
]

@itemlist[
  @item{침고: 특히 위의 두 번째와 세 번째 조건을 충족시키는 함수를 고차 함수(higher-order
        function)라고 부른다.}
]

Common Lisp은 위의 네 가지 조건 모두를 만족시킨 최초의 언어이다. 그런데 문제는 요즘 새로
등장하는 언어들 거의 대부분이(Python, Ruby, ...) 위의 네 조건을 모두 충족시키고 있다는
것이다(결론적으로, 리습을 흉내내고 있다고 봐도 무방하다). JavaScript마저도 위의 네 조건을
모두 충족시키고 있는데, 그렇다면 JavaScript도 함수형 언어라고 불러야 한다(좀더 정확히는,
Python이나 Ruby보다 더 함수적인 언어이다).

그러면 지금부터는 요즘 각광받기 시작하고 있는 '엄격한' 의미에서의 함수형 언어에 대해 말해
보겠다. 객체지향 프로그래밍이 갖는 문제점을 극복하고자 하는 대안으로서 요즘 주목받고 있는
'함수형 언어'는 위의 4가지 조건에 더해서, immutable 자료형을 기본(default)으로 제공해야
한다. 이 조건을 하나 더 충족시켜야, 요즘에 말하는 진정한 의미의 함수형 언어라 말할 수
있다. Clojure도 이 범주에 속하는 함수형 프로그래밍 언어이다. immutable 자료형을 기본으로
하면, 메모리 소요량도 많아지고 처리 시간도 길어지는데, 왜 굳이 immutable 자료형을 기본으로
할까? 그것은 immutable 자료형을 기반으로 연산을 수행하면, 프로그램의 복잡도가 엄청나게
줄어들기 때문이다.

과거에 절차지향 프로그래밍의 문제점을 극복할 수 있는 대안으로 객체지향 프로그래밍이 등장한
이유가 무엇이었나? 전역 변수의 사용을 줄이고, 변수를 클래스 안에 가두어 놓은 후에, 클래스
내의 멤버 변수만 접근 가능하도록 '강제'한 이유가 무엇일까? 그 이유는, 전역 변수의 경우에는
프로그래밍 내의 어떤 함수에서도 접근이 가능해서, 그에 따라 어떤 함수가 그 변수를
건드렸는지 추적하기 무지무지 어렵기 때문이지 않았던가? 물론 전역 변수를 많이 사용해서
프로그래밍한다 해도, 프로그래머가 아주 아주 조심스럽고 세심하게 프로그래밍하면 그
프로그램은 잘 돌아갈 수 있을 것이다. 하지만 그렇게 세심하고 꼼꼼한 프로그래머도, 자신이 짠
프로그래밍 소스 코드를 2개월 정도 지나 들여다 봐도 자신이 짠 코드를 잘 이해하지 못하는데,
하물며 다른 사람이 짠 코드를 유지/보수해야 하는 입장에서는, 전역 변수의 남발이 악의
화신으로 느껴졌을 것이다. 그래서 사람들이 객체지향 프로그래밍으로 많이 돌아섰다.  그런데
객체 지향 프로그래밍도, 설계하고자 하는 클래스의 크기가 커지거나, 다른 클래스에 의존하는
내부 변수들의 수가 증가할수록, 그리고 상속 관계가 복잡해질수록, 클래스 내부 변수를
건드리는 멤버 함수들의 수가 더불어 증가하기 마련이다. 그래서 그 클래스 내부의 변수들을
어떤 멤버 함수 내에서 건드리는지 추적하는 일도 만만치 않은 일이 되어 버린다. 전역 변수
관리할 때와 비슷한 현상이 나타나기 시작한다는 것이다.

여기서 한 가지 중요한 원리가 발견된다.  그것은 프로그램의 복잡도를 줄이기 휘해, 변수의
값을 변경할 수 있는 함수들의 범위를 점점 더 제한해 가고 있다는 것이다. 그렇다면 상태를
유지하는 변수가 아예 없다면 어떻게 될까? 바로 이것이 요즘에 등장한 함수형 언어들이
추구하는 목표이다.

여기서 함수형 언어에서의 immutable 자료형의 진가가 드러나게 된다. 함수형 언어에서는
상태(state)를 저장하는 변수의 사용을 최대한 없애는 것을 목표로 한다. 하지만, 상태를
저장하는 변수를 전혀 안쓸 수는 없다. 그래서 상태값을 변경하는 겻을 허용하는 장치를 두기는
하지만, 이것은 오히려 예외적인 상황으로 간주된다.  그렇게 되면 디버깅할 때 디버깅의 단위가
함수 하나로 국한된다. 객체 지향 프로그래밍에서와는 달리, 클래스 내의 다른 멤버 함수가
클래스의 내부 변수를 언제 어떻게 건드리는지 전혀 신경쓸 필요가 없게 된다.

따라서 '프로그램의 복잡도를 줄여준다'는 의미로, 그리고 그것을 실현하기 위해 immutable
자료형을 기본으로 제공해야 한다는 의미로 함수형 언어를 정의한다면, Clojure나 Hsaskell이
진정한 의미의 함수형 언이라고 할 수 있다. 그런 의미에서 Common Lisp은 엄밀한 의미에서의
함수형 언어는 아니다.


@section{나는 왜 Clojure를 주력 언어로 선택했나?}

내가 Clojure를 처음 접했을 때의 느낌은, 그때까지 함께 스터디하면서 익힌 Common Lisp에 비해
뭔가 허접하고, 많이 다르다는 이질감이 강하게 느껴져서 거부감이 심했던 것도 사실이지만,
함수형 언어의 가치와 중요성에 눈 뜬 지금은 생각이 많이 다르다.

요즘에는 오히려 같은 리습 계열 언어인 Common Lisp이나 Racket보다 Clojure가 낫다는 생각을
많이 하게 되는데, 그 이유는 크게 두 가지이다.

첫 번째로 가장 큰 이유는, Clojure가 'immutable' 자료형을 기본으로 하는 '함수형' 언어이고,
게다가 '리습 계열' 언어라는 점이다. Clojure가 'immutable' 자료형을 기본으로 하는 '함수형'
언어가 아니면서, 단순히 '리습 계열' 언어일 뿐이었다면, 나는 Clojure를 지금처럼 대단히
매력적인 언어라고 생각하지는 않았을 것이다. 단순히 Common Lisp, Racket, ... 등등의 그
수많은 리습 계열 언어들 중의 하나라고 여겼을 것이고, 따라서 별 매력을 느끼지 못했을
것이다. 지금 Clojure가 Common Lisp이나 Racket보다 낫다고 생각하는 이유가 바로, Clojure가
'immutable' 자료형을 기본으로 하는 '함수형' 언어라는 점이다.

같은 조건을 충족하는 언어로 Haskell 같은 함수형 언어도 있기는 하다. 하지만 Haskell은 그
태생이 교수 사회의 학문적 관심사에서 출발한 언어여서 더 엄밀한 맛은 있지만, 타입을 일일이
맞추어 주여야 하는 등, 형식성이 너무 강해 프로그래머의 관점에서 볼 때 실용성은 클로저에
비해 현저히 떨어진다. 클로저의 창시자인 Rich Hickey 자신이 수십년간 대규모 프로젝트에서
활동해 온 현업 프로그래머였다는 점에서, 클로저는 소규모의 프로젝트를 수행하는 대학
연구실의 상황과는 다른 실전 프로그래머들을 위해 설계된 언어이다.

절차 지향의 프로그래밍을 극복하기 위한 대안으로 객체지향 프로그래밍이 나왔다면, 함수형
프로그래밍은 객체지향 프로그래밍에서 나타나는 문제잠들을 극복하기 위한 대안으로 등장했기에, 
리습 계열 언어들도 이 개념을 도입할 필요가 있다고 본다. 그런데 이 함수형 프로그래밍 패러다임은, 
기존의 프로그래밍 패러다임과는 너무나 달라서, '상태(state)를 유지하는 것을 기본 전제로 해서 
만들어진 기존의 리습 언어들'을 확장하는 방식보다는, Clojure처럼 새로운 리습 언어를 만드는 것이 
낫다고 본다.

함수형 언어의 특징이, 리습의 장점과 결합될 수 있다는 점은 Clojure만이 지닌 엄청난
잠재력이다. 그리고 함수형 프로그래밍을 지원하는 리습 계열 언어가, 현재로서는 Clojure
하나밖에 없다는 점이 내가 Clojure를 주력 언어로 선택해야겠다고 결심을 굳히게 한 이유이기도
하다.
 
역으로, Clojure가 리습계열 언어가 아닌 단순히 함수형 언어일 뿐이었다면, 역시 눈여겨 보지
않았을 것이다. 솔직히 이야기하면, 매크로라는 리습의 장점이 없다면, 제 아무리 좋은 언어라도
눈길이 가지를 않는다. 그리고 매크로를 지원하려면, 리습 언어에 등장하는 그 수많은 괄호
없이는 불가능하다고 보기에, 괄호가 없으면서 리습 계열 언어임을 표방하는 자칭 리습 계열
언어들에게도 심드렁해진다.

두 번째로 Clojure가 다른 리습계열 언어들에 비해 좋다고 생각하는 점은, 바로 이용 가능한
라이브러리의 수다. Clojure는 JVM에서 돌아가기에, 그 엄청나게 많은 자바 라이브러리들을
그대로 불러다 쓸 수 있다. 그동안 Common Lisp이나 Racket이 언어 자체로는 좋다고 하면서도,
라이브러리의 부족 때문에 실제로 이 언어들을 활용하는 데에는 한계가 있지 않았던가? 언어가
아무리 좋아도 이용 가능한 라이브러리의 수가 적으면, 그 활용 가치는 급격히 떨어지게
마련인데, Clojure는 그 한계를 극복할 수 있게 해주는 유일한 리습 계열 언어이기 때문에, 나는
Clojure를 다른 리습계열 언어보다 더 선호한다.


@section{Clojure는 얼마나 빠른가?}

Java는 C++에 비해 평균적으로 3배 느리고, Clojure는 Java에 비해 평균적으로 3배 느리다고
한다. 결과적으로 클로저는 C++에 비해 9배 정도 느리다고 보면 된다. 하지만 Python에 비해서는
30배 이상 빠르다). 클로저는 Compiler 언어이기 때문에 실행 속도가 인터프리터 언어에 비해
빠를 수 밖에 없다. 클로저 언어에 내장되어 있는 클로저 컴파일러는 클로저 소스 코드를 자바
코드를 거치지않고 JVM 바이트 코드로 직접 컴파일한다. 그리고 병목을 일으키는 부분을
profiling을 실행해 찾아낸 후, type hinting 정보를 추가해 주면 실행 속도를 향상시킬 수도
있다. 참고로, 자바 코드를 직접 호출하는 부분은 자바와 실행 속도가 동일하다.

과거에 C 언어로 프로그래밍을 시작한 사람들은, 일반적으로 프로그램의 실행 속도에 목을 매는
경향이 있는 데, 싱글 코어 세대에서 멀티 코어 시대로 넘어가고 있는 이 시대에는 실행 속도의
개념 자체가 바뀔 필요가 있다. C++로 짠 프로그램이 빠르다고는 해도, 싱글 코어에서 돌아 갔을
때의 이야기일 뿐이다. 예를 들어 64 코어 서버에서 C++ 프로그램을 돌려도, 1개의 코어만 100%
가까이 돌아갈 뿐, 나머지 코어들은 대부분 놀고 있는게 현실이다. 단순 계산이기는 하지만,
위에서 든 속도 비교로 계산만 해도, 한 개의 클로저 프로그램은 64 코어 모두를 활용할 수
있으므로, 전체적으로는 C++보다 '9배가 느린' 것이 아니라, '7배 이상 빠른'
것이다. 하드웨어의 성능은 나날이 높아지고, 가격은 나날이 떨어지고 있으므로, 멀티 코어를
이용할 수 있는 프로그래밍 언어가 결과적으로 더 빠른 언어인 것이다. CPU의 코어 수가 늘어날
수록 격차는 더 벌어질 것이다. 이와 같이 프로그램의 '속도'라는 개념 자체를 바꾸어야
하는데도 불구하고, 사람들의 생각은 늘 관성적이어서, 좀처럼 바뀌지 않는 것 같다. 이렇게
클로저 프로그램이 멀티 코어 모두를 이용할 수 있는 이유는, 1차적으로는 immutable 데이터
때문이고, 2차적으로는 클로저 언어 자체가 쓰레드를 자동으로 관리해주는 STM(Software
Transaction Memeory) 기능 때문이다.

물론 64 코어 모두를 이용할 수 있는 C++ 프로그램을 짤 수도 있지 않느냐 반문하는 사람들도
있을텐데, 글쎄 과연 실제적으로 가능할까 극히 의심스럽다. 설사 구현할 수 있다 해도 엄청
복잡한 코드가 나와서, 극소수의 전문가가 아니면 유지/보수/개선이 정상적으로 이루어지기는
어려울 것이다.


@section{단순함(Simple)과 쉬움(Easy)의 차이}

나는 복잡함을 어떻게 다루는가에 따라 프로그래머를 세 부류로 구분한다. 하급 프로그래머는
복잡한 문제를 아예 풀지조차 못한다. 중급 프로그래머는 복잡한 문제를 '복잡하게'
해결한다. 고급 프로그래머는 복잡한 문제를 '단순하게' 풀어낸다. 그래서 프로그램의 버그가
적은 것이다.

Clojure가 생산성 있는 단순한 코드를 작성하게 해 주지만, 그런 코드를 작성하기 위해서는 꽤
많은 시간과 노력을 투자할 각오를 해야 한다. Clojure 언어에 대한 이해가 높아야 그만큼
간결하면서도 수준 높은 코드가 나오기 때문이다. 한 마디로 공짜 점심은 없다.

나도 그랬었지만, Clojure를 잘하기 위해서는 먼저 함수형 프로그래밍이라는 벽을 넘어야
하고, 그 다음으로는 Lisp의 매크로라는 벽이 여러분을 기다리고 있을 것이다. Rich Hickey도
이미 지적했지만, 우리는 흔히 '단순함'과 '쉬움'을 혼동한다. 대체적으로 단순한 것은 쉽지만,
항상 그런 것은 아니다. 한 마디로 표현하자면, Clojure는 단순하지만 쉽지는 않다.

단순함은 '구조'에 관한 것이다. 단순함은 나의 주관의 세계가 아닌, 객관의 세계와 관련된
것이다. 프로그램 구조의 단순화를 추구하는 것이 Clojure 언어가 추구하는 일관된
철학이다. 그에 반해 쉬움은 나의 주관적 평가와 관련되는 것이다. 모두가 어렵다고 하는 상대성
이론도 아인시타인 자신에게는 '쉬운' 것이다. 흔히 드는 예이지만, 9개의 공을 저글링 하는
사람에게 6개의 공을 저글링하는 것은 '쉬운' 일이다. 결국 쉬움은 상대적이고 주관적인
것이다. '숙련됨'의 또 다른 표현이라고도 할 수 있다. 그런 의미에서 내가 위에서 쉽지 않다고
한 것은, Clojure라는 언어에 숙련되어 가는 과정에 시간이 걸린다는 의미로 말한 것이다.

예를 들어 보자. Ruby on Rails의 경우 처음에 튜토리얼에 나온 대로 따라할 때는 무지하게
쉽다. 하라는 대로 하다 보면 금방 결과물이 나온다. 하지만, 기존에 작성되어 있는 코드를
수정해야 할 필요가 생겼다고 해 보자. 실제로 이런 일은 비일비재하다. 그때부터는 고난의
행군이 시작된다. 무엇 하나 고치려 해도 클래스 전체의 구조를 알아야 하는데, 하나의 멤버
변수를 이 메소드 저 메소드가 건드리고 있고(즉, 메소드 간의 상호 의존성이 심하다), 또 멤버
변수들 간의 복잡한 관계도 파악해야 한다. 게다가 남이 쓴 코드를 이해하는 것이 어디 쉬운
일인가? 한 마디로, 조금만 깊이 들어가게 되면 그때부터는 급격히 어려워진다. 왜 그런가?
프로그램의 구조가 복잡하기 때문이다. 객체 지향 프로그램이 절차 지향 프로그램보다
우월하다고는 하지만, 역시 상태(state)를 변경하면서 작업한다는 점에서는 오십보 백보이기
때문이다. 클로저에서는 이런 일이 상대적으로 더 쉽다. immutable 데이터를 다루기 때문에
함수들 간에 의존성이 없어서, 자신이 기존의 소스에서 무엇인가 변경하고자 할 때, 대개의 경우
함수 하나만 변경하면 된다. 결과적으로 프로그램의 '구조'가 간단하기 때문에 가능한 일이다.



@section{Clojure의 발음과 의미}


Rich Hickey는 Clojure의 발음과 의미에 대한 질문을 받고, 다음과 같이 대답했다.

@margin-note{
Clojure is pronounced exactly like closure, where the s/j has the zh sound as in azure,
pleasure etc.

The name was chosen to be unique. I wanted to involve c (c#), l (lisp) and j(java).

Once I came up with Clojure, given the pun on closure, the available domains and vast
emptiness of the googlespace, it was an easy decision.
}

발음은 closure와 같다고 하니, 영어 발음을 우리말로 가장 가깝게 옮기면 '클로우줘' 정도
되겠는데, 우리나라 사람들은 그냥 편의상 '클로저'라고 많이 읽는다. 나도 Clojure
발음이 영어 발음과 반드시 일치해야 한다고는 생각하지 않아서 그냥 클로저라고 발음하는 것에
동의하는 쪽이다.

그리고 의미는 C#, Lisp, Java의 첫 글자를 따 온 것이고, 구글 검색에 쉽게 검색되도록 하기
위해, 그리고 closure와 발음이 같은 일종의 말장난으로 CLoJure라고 지었다고 한다.
