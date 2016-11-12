(ns spec-guide.api
  (:require [clojure.spec :as s]
            [clojure.spec.gen :as gen]
            [clojure.spec.test :as stest] ))

(use 'debux.core)

;;; s/valid?

(s/valid? even? 10)            ; => true
(s/valid? string? "abc")       ; => true

(s/valid? #(> % 5) 10)         ; => true
(s/valid? #(> % 5) 0)          ; => false

(s/valid? #{10 20 30 40} 10)   ; => true
(s/valid? #{10 20 30 40} 50)   ; => false


;;; s/def

(s/def ::suit #{:club :diamond :heart :spade})
; => :spec-guide.api/suit

(s/valid? ::suit ::space)
; => false


;;; s/conform

(s/conform ::suit :club)    ; => :club
(s/conform ::suit :hello)   ; => :clojure.spec/invalid


;;; s/and

(s/def ::big-even (s/and int? even? #(> % 1000)))

(s/valid? ::big-even :foo)    ; => false
(s/valid? ::big-even 10)      ; => false
(s/valid? ::big-even 100000)  ; => true


;;; s/or

(s/def ::name-or-id (s/or :name string?
                          :id   int?))

(s/valid? ::name-or-id "abc")    ; => true
(s/valid? ::name-or-id 100)      ; => true
(s/valid? ::name-or-id :foo)     ; => false

(s/conform ::name-or-id "abc")   ; => [:name "abc"]
(s/conform ::name-or-id 100)     ; => [:id 100]
(s/conform ::name-or-id :foo)    ; => :clojure.spec/invalid


;;; s/explain

(when (= (s/conform ::name-or-id :foo)
         :clojure.spec/invalid)
  (s/explain ::name-or-id :foo))
; >> val: :foo fails
;    spec: :spec-guide.api/name-or-id
;    at: [:name] predicate: string?
;
;    val: :foo fails
;    spec: :spec-guide.api/name-or-id
;    at: [:id] predicate: int?
;
; => nil


(s/explain ::name-or-id "tom")
; >> Success!
; => nil


(s/explain-str ::name-or-id :foo)
; => "val: :foo fails spec: :spec-guide.api/name-or-id at: [:name] predicate: string?\nval: :foo fails spec: :spec-guide.api/name-or-id at: [:id] predicate: int?\n"

(s/explain-data ::name-or-id :foo)
; => #:clojure.spec{:problems ({:path [:name],
;                               :pred string?,
;                               :val :foo,
;                               :via [:spec-guide.api/name-or-id],
;                               :in []}
;                              {:path [:id],
;                               :pred int?,
;                               :val :foo,
;                               :via [:spec-guide.api/name-or-id],
;                               :in []})}


;;; s/keys

(s/def ::first-name string?)
(s/def ::last-name string?)
(s/def ::age int?)

(s/def ::person (s/keys :req [::first-name ::last-name]
                        :opt [::age]))


(s/valid? ::person
  {::first-name "Elon"
   ::last-name "Musk"
   ::age 45})
; => true

(s/conform ::person
  {::first-name "Elon"
   ::last-name "Musk"})
; => #:spec-guide.api{:first-name "Elon", :last-name "Musk"}

(s/explain ::person
  {::first-name "Elon"})
; >> val: #:spec-guide.api{:first-name "Elon"} fails
;    spec: :spec-guide.api/person
;    predicate: (contains? % :spec-guide.api/last-name)
; => nil


;;; unnamespaced keys

(s/def :unq/person
  (s/keys :req-un [::first-name ::last-name]
          :opt-un [::age]))


(s/conform :unq/person
  {:first-name "Elon"
   :last-name "Musk"})
; => {:first-name "Elon", :last-name "Musk"}

(s/explain :unq/person
  {:first-name "Elon" :age "45"})
; >> val: {:first-name "Elon", :sex :mail} fails
;    spec: :unq/person
;    predicate: (contains? % :last-name)
;
;    In: [:age]
;    val: "45" fails
;    spec: :spec-guide.api/age
;    at: [:age]
;    predicate: int?


;;; unnamespaced keys and defrecord

(defrecord Person [first-name last-name age])

(s/conform :unq/person
  (->Person "Elon" "Musk" 45))
; => #spec_guide.api.Person{:first-name "Elon", :last-name "Musk", :age 45}

(s/explain :unq/person
           (->Person "Elon" nil nil))
; >> In: [:last-name]
;    val: nil fails
;    spec: :spec-guide.api/last-name
;    at: [:last-name]
;    predicate: string?
;
;    In: [:age]
;    val: nilfails
;    spec: :spec-guide.api/age
;    at: [:age]
;    predicate: int?


;;; s/keys*: keyword arguments

(s/def ::port number?)
(s/def ::host string?)
(s/def ::id keyword?)

(s/def ::server (s/keys* :req [::id ::host] :opt [::port]))

(s/conform ::server [::id :s1 ::host "example.com" ::port 5555])
; => #:spec-guide.api{:id :s1, :host "example.com", :port 5555}


;;; s/merge: spec의 병합

(s/def :animal/kind string?)
(s/def :animal/says string?)
(s/def :animal/common (s/keys :req [:animal/kind :animal/says]))

(s/def :dog/tail? boolean?)
(s/def :dog/breed string?)

(s/def :animal/dog (s/merge :animal/common
                            (s/keys :req [:dog/tail? :dog/breed])))

(s/valid? :animal/dog
  {:animal/kind "dog"
   :animal/says "woof"
   :dog/tail? true
   :dog/breed "retriever"})
; => true



;; s/alt
(s/def ::str-or-kw (s/alt :str string?
                          :kw  keyword?))

(s/def ::my-spec (s/cat
                   :first ::str-or-kw
                   :second number?))

(s/conform ::my-spec '(:a 1))
; => {:first [:kw :a], :second 1}



(s/def ::big-even (s/and int? even? #(> % 1000)))

(s/valid? ::big-even :foo)     ; => false
(s/valid? ::big-even 11)       ; => false
(s/valid? ::big-even 100000)   ; => true


;;; Map

(def email-regex #"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,63}$")
(s/def ::email-type (s/and string? #(re-matches email-regex %)))

(s/def ::first-name string?)
(s/def ::last-name string?)
(s/def ::email ::email-type)

(s/def ::person (s/keys :req [::first-name ::last-name ::email]
                        :opt [::phone]))

(s/valid? ::person
  {::first-name "Elon"
   ::last-name "Musk"
   ::email "elon@example.com"})
; => true

(s/explain ::person
  {::first-name "Elon"})
; >> val: #:spec-guide.api{:first-name "Elon"} fails
;    spec: :spec-guide.api/person
;    predicate: (contains? % :spec-guide.api/last-name)
;
;    val: #:spec-guide.api{:first-name "Elon"} fails
;    spec: :spec-guide.api/person
;    predicate: (contains? % :spec-guide.api/email)

(s/explain ::person
  {::first-name "Elon"
   ::last-name "Musk"
   ::email "n/a"})
; >> In: [:spec-guide.api/email]
;    val: "n/a" fails
;    spec: :spec-guide.api/email-type
;    at: [:spec-guide.api/email]
;    predicate: (re-matches email-regex %)


;;; unqualified keys

(s/def :unq/person
  (s/keys :req-un [::first-name ::last-name ::email]
          :opt-un [::phone]))

(s/conform :unq/person
  {:first-name "Elon"
   :last-name "Musk"
   :email "elon@example.com"})
; => {:first-name "Elon", :last-name "Musk", :email "elon@example.com"}


(s/explain :unq/person
  {:first-name "Elon"
   :last-name "Musk"
   :email "n/a"})
; >> In: [:email]
;    val: "n/a" fails
;    spec: :spec-guide.api/email-type
;    at: [:email]
;    predicate: (re-matches email-regex %)

(s/explain :unq/person
  {:first-name "Elon"})
; >> val: {:first-name "Elon"} fails
;    spec: :unq/person
;    predicate: (contains? % :last-name)
;
;    val: {:first-name "Elon"} fails
;    spec: :unq/person
;    predicate: (contains? % :email)

;; Unqualified keys can also be used to validate record attributes:

(defrecord Person [first-name last-name sex])

(s/explain :unq/person
           (->Person "Elon" nil nil))
; >> In: [:last-name]
;    val: nil fails
;    spec: :spec-guide.detils/last-name
;    at: [:last-name]
;    predicate: string?

(s/conform :unq/person
  (->Person "Elon" "Musk" :male))
; => #spec_guide.api.Person{:first-name "Elon", :last-name "Musk", :sex :male}


;;; key*
;; keyword args where keyword keys and values are passed in a sequential data structure
;; as options. Spec provides special support for this pattern with the regex op keys*.

(s/def ::port number?)
(s/def ::host string?)
(s/def ::id keyword?)

(s/def ::server (s/keys* :req [::id ::host] :opt [::port]))

(s/conform ::server [::id :s1 ::host "example.com" ::port 5555])
; => #:spec-guide.api{:id :s1, :host "example.com", :port 5555}


;;; merge

(s/def :animal/kind string?)
(s/def :animal/says string?)

(s/def :animal/common (s/keys :req [:animal/kind :animal/says]))

(s/def :dog/tail? boolean?)
(s/def :dog/breed string?)

(s/def :animal/dog (s/merge :animal/common
                            (s/keys :req [:dog/tail? :dog/breed])))

(s/valid? :animal/dog
  {:animal/kind "dog"
   :animal/says "woof"
   :dog/tail? true
   :dog/breed "retriever"})
; => true


;;; multi-spec: 클로저의 multi method를 이용해 spec을 정의하는 것.

(s/def :event/type keyword?)
(s/def :event/timestamp int?)

(s/def :search/url string?)

(s/def :error/message string?)
(s/def :error/code int?)


(defmulti event-type :event/type)

(defmethod event-type :event/search [_]
  (s/keys :req [:event/type :event/timestamp :search/url]))

(defmethod event-type :event/error [_]
  (s/keys :req [:event/type :event/timestamp :error/message :error/code]))


(s/def :event/event (s/multi-spec event-type :event/type))

(s/valid? :event/event
  {:event/type :event/search
   :event/timestamp 1463970123000
   :search/url "http://clojure.org"})
; => true

(s/valid? :event/event
  {:event/type :event/error
   :event/timestamp 1463970123000
   :error/message "Invalid host"
   :error/code 500})
; => true

(s/explain :event/event
  {:event/type :event/restart})
; >> val: #:event{:type :event/restart} fails
;    spec: :event/event
;    at: [:event/restart]
;    predicate: event-type, no method

(s/explain :event/event
  {:event/type :event/search
   :search/url 200})
; >> val: {:event/type :event/search, :search/url 200} fails
;    spec: :event/event
;    at: [:event/search]
;    predicate: (contains? % :event/timestamp)
;
;    In: [:search/url]
;    val: 200 fails
;    spec: :search/url
;    at: [:event/search :search/url]
;    predicate: string?


;;; Collections:  coll-of, tuple, and map-of


(s/def ::point (s/tuple double? double? double?))

(s/conform ::point [1.5 2.5 -0.5])
; => [1.5 2.5 -0.5]

(s/explain ::point [1.5 2.5 5])
; >> In: [2]
;    val: 5 fails
;    spec: :spec-guide.api/point
;    at: [2]
;    predicate: double?

;; tuple: list 자료형을 대상으로는 작동하지 않는다.
;;        대상 자료형이 반드시 vector 형이어야 한다.
(s/conform ::point '(1.5 2.5 -0.5))
; => :clojure.spec/invalid


;;;; Sequences: Sequentials (vector와 list) 대상

;;; s/cat

(s/def ::ingredient (s/cat :quantity number? :unit keyword?))

(s/conform ::ingredient [2 :teaspoon])
; => {:quantity 2, :unit :teaspoon}

(s/conform ::ingredient '(2 :teaspoon))
; => {:quantity 2, :unit :teaspoon}


;; pass string for unit instead of keyword
(s/explain ::ingredient [11 "peaches"])
; >> In: [1]
;    val: "peaches" fails
;    spec: :spec-guide.api/ingredient
;    at: [:unit]
;    predicate: keyword?

;; leave out the unit
(s/explain ::ingredient [2])
; >> val: () fails
;    spec: :spec-guide.api/ingredient
;    at: [:unit]
;    predicate: keyword?,  Insufficient input


;;; s/* s/+ s/?

(s/def ::seq-of-keywords (s/* keyword?))

(s/conform ::seq-of-keywords [:a :b :c])
; => [:a :b :c]

(s/explain ::seq-of-keywords [10 20])
; >> In: [0]
;    val: 10 fails
;    spec: :spec.examples.guide/seq-of-keywords
;    predicate: keyword?

(s/def ::odds-then-maybe-even (s/cat :odds (s/+ odd?)
                                     :even (s/? even?)))

(s/conform ::odds-then-maybe-even [1 3 5 100])
; => {:odds [1 3 5], :even 100}

(s/conform ::odds-then-maybe-even [1])
; => {:odds [1]}

(s/explain ::odds-then-maybe-even [100])
; >> In: [0]
;    val: 100 fails
;    spec: ::odds-then-maybe-even
;    at: [:odds]
;    predicate: odd?


;; opts are alternating keywords and booleans
(s/def ::opts (s/* (s/cat :opt keyword? :val boolean?)))

(s/conform ::opts [:silent? false :verbose true])
; => [{:opt :silent?, :val false} {:opt :verbose, :val true}]


;;; s/alt

(s/def ::config (s/*
                  (s/cat :prop string?
                         :val  (s/alt :s string? :b boolean?))))

(s/conform ::config ["-server" "foo" "-verbose" true "-user" "joe"])
; => [{:prop "-server", :val [:s "foo"]}
;     {:prop "-verbose", :val [:b true]}
;     {:prop "-user", :val [:s "joe"]}]

(s/def ::config2 (s/*
                  (s/cat :prop string?
                         :val  (s/or :s string? :b boolean?))))

(s/conform ::config2 ["-server" "foo" "-verbose" true "-user" "joe"])
; => [{:prop "-server", :val [:s "foo"]}
;     {:prop "-verbose", :val [:b true]}
;     {:prop "-user", :val [:s "joe"]}]


;;; s/&

(s/def ::even-strings (s/& (s/* string?) #(even? (count %))))

(s/valid? ::even-strings ["a"])       ; => false
(s/valid? ::even-strings ["a" "b"])   ; => true


;;; s/descreibe

(s/describe ::seq-of-keywords))
; => (* keyword?)

(s/describe ::odds-then-maybe-even)
; => (cat :odds (+ odd?) :even (? even?))

(s/describe ::opts)
; => (* (cat :opt keyword? :val boolean?))


;;; s/fdef: function spec

(s/fdef ranged-rand
  :args (s/and (s/cat :start int? :end int?)
               #(< (:start %) (:end %)))
  :ret int?
  :fn (s/and #(>= (:ret %) (-> % :args :start))
             #(< (:ret %) (-> % :args :end))))

(defn ranged-rand
  "Returns random int in range start <= rand < end"
  [start end]
  (+ start (long (rand (- end start)))))

(s/exercise-fn `ranged-rand)
; => ([(-2 -1) -2] [(-2 0) -1] [(-2 0) -2] [(0 2) 1] [(-14 1) -3] [(-4 -1) -4] [(-9 2) -5] [(-4 -3) -4] [(-57 114) 2] [(-1 678) 195])

(stest/check `ranged-rand)


(ranged-rand 5 10)
; => 7

(ranged-rand 10 5)
; => 9

; (instrument symbol*)
(stest/instrument `ranged-rand)

(ranged-rand 5 10)
; => 7

; (ranged-rand 10 5)
; >> Call to #'spec-guide.api/ranged-rand did not conform to spec:
;    val: {:start 10, :end 5} fails
;    at: [:args]
;    predicate: (< (:start %) (:end %))
;    :clojure.spec/args (10 5)
;    :clojure.spec/failure :instrument
;    :clojure.spec.test/caller {:file "form-init7709795464976482689.clj",
;                               :line 400,
;                               :var-scope spec-guide.api/eval13655}


;;; f/fspec: anonymous function spec

(defn adder [x] #(+ x %))

(s/fdef adder
  :args (s/cat :x number?)
  :ret (s/fspec :args (s/cat :y number?)
                :ret number?)
  :fn #(= (-> % :args :x) ((:ret %) 0)))

;;; f/fedf: macro spec

(s/fdef clojure.core/declare
    :args (s/cat :names (s/* simple-symbol?))
    :ret any?)
....

[source]
....
(declare 100)
; >> Unhandled clojure.lang.ExceptionInfo
;      Call to clojure.core/declare did not conform to spec:
;      In: [0]
;      val: 100 fails 
;      at: [:args :names]
;      predicate: simple-symbol?
;     :clojure.spec/args (100)




(gen/generate (s/gen int?))
; => 11039

(gen/sample (s/gen int?))
; => (0 -1 0 -2 1 3 6 8 21 2)

(gen/sample (s/gen int?) 20)
; => (0 0 0 -4 6 14 -7 2 -6 -170 96 299 107 -17 -98 30 542 65497 -16 -2)

(gen/sample (s/gen #{:club :diamond :heart :spade}))
; => (:heart :diamond :heart :heart :heart :diamond :spade :spade :spade :club)

(gen/sample (s/gen (s/cat :k keyword? :ns (s/+ number?))))
; => ((:A 0)
;     (:EJ 1.0)
;     (:jJ_!/D9! 1.25 1.0 -2)
;     (:+* -2 -2.0 0)
;     (:Y/cy 0 0.5625 -0.625 0.5 -2)
;     (:_Z_.ZI/r1Zwy -1.6875 1)
;     (:rX7.da2g0R.t.m?!!sTC/+ -0.75 -0.6484375 0.0 -5)
;     (:n.t!YPn.Lgn?/?E74y? 1 -0.703125 -1 6)
;     (:j5.f?50.UlM.PF5J?.B.R40!J*2-o/KiJ? 13 0.484375)
;     (:K8y1P_.JY!.E5_.!b6.t._x_g/g3L -1.5625 5 33 -27 5 0.453125 -5 -60 5.375))

(s/exercise (s/cat :k keyword? :ns (s/+ number?))
            5)
; => ([(:* 0) {:k :*, :ns [0]}]
;     [(:d8/W 0) {:k :d8/W, :ns [0]}]
;     [(:J*/th 1.0) {:k :J*/th, :ns [1.0]}]
;     [(:_?0.*C*.-/! -4 -0.5 2 -3) {:k :_?0.*C*.-/!, :ns [-4 -0.5 2 -3]}]
;     [(:G9P*? -1.0 4 0.875 2.0) {:k :G9P*?, :ns [-1.0 4 0.875 2.0]}])

(s/exercise-fn `ranged-rand)
; => ([(-3 -1) -3]
;     [(-2 0) -2]
;     [(0 1) 0]
;     [(-1 2) -1]
;     [(-13 -1) -4]
;     [(3 59) 47]
;     [(2 7) 4]
;     [(-2 26) 16]
;     [(-36 -3) -5]
;     [(-190 8) -119])


;;; Using s/and Generators

; (gen/generate (s/gen even?))
; >> Unhandled clojure.lang.ExceptionInfo
;    Unable to construct gen at: [] for:
;    clojure.core$even_QMARK_@4e9331e8

(gen/generate (s/gen (s/and int? even?)))
; => 10680180


(defn divisible-by [n] #(zero? (mod % n)))

(gen/sample (s/gen (s/and int?
                     #(> % 0)
                     (divisible-by 3))))
; => (63 12 117 3 18 210 6 36 60 1109188944)


;;; Custom Generators

(gen/sample (s/gen (s/and string? #(clojure.string/includes? % "hello"))))
; >> Unhandled clojure.lang.ExceptionInfo
;    Couldn't satisfy such-that predicate after 100 tries.

n
; (with-gen <spec> <generator>) => <generator>
(s/def ::kws
  (s/with-gen (s/and keyword? #(= (namespace %) "my.domain"))
              #(s/gen #{:my.domain/name :my.domain/occupation :my.domain/id}) ))

(s/valid? ::kws :my.domain/name)  ;; true
(gen/sample (s/gen ::kws) 5)
; => (:my.domain/occupation :my.domain/id :my.domain/id :my.domain/occupation :my.domain/id)


; (fmap f generator) => generator

(def kw-gen-2 (gen/fmap #(keyword "my.domain" %)
                        (gen/string-alphanumeric) ))
(gen/sample kw-gen-2 5)
; => (:my.domain/ :my.domain/ :my.domain/ :my.domain/ :my.domain/w4jW)


; (such-that f generator) => generator 
(def kw-gen-3 (gen/fmap #(keyword "my.domain" %)
                        (gen/such-that #(not= % "")
                                       (gen/string-alphanumeric) )))
(gen/sample kw-gen-3 5)
; => (:my.domain/5C :my.domain/e :my.domain/2 :my.domain/EVgS0 :my.domain/1)



(s/def ::hello
  (s/with-gen #(clojure.string/includes? % "hello")
              #(gen/fmap (fn [[s1 s2]] (str s1 "hello" s2))
                         (gen/tuple (gen/string-alphanumeric)
                                    (gen/string-alphanumeric) ))))
(gen/sample (s/gen ::hello) 5)
; => ("hello" "hhellol" "wMhello" "Qv2hello62" "4Rhjhello0H")


;;; Range Specs and Generators

(s/def ::roll (s/int-in 0 11))

(gen/sample (s/gen ::roll))
; => (0 0 2 1 2 4 10 6 4 1)


(s/def ::the-aughts (s/inst-in #inst "2000" #inst "2010"))
(gen/sample (s/gen ::the-aughts) 5)
; => (#inst "2000-01-01T00:00:00.001-00:00"
;     #inst "2000-01-01T00:00:00.000-00:00"
;     #inst "2000-01-01T00:00:00.000-00:00"
;     #inst "2000-01-01T00:00:00.003-00:00"
;     #inst "2000-01-01T00:00:00.002-00:00")

(drop 50 (gen/sample (s/gen ::the-aughts) 55))
; => (#inst "2000-01-01T02:54:06.012-00:00"
;     #inst "2005-09-24T06:51:11.583-00:00"
;     #inst "2000-01-01T00:00:00.087-00:00"
;     #inst "2008-07-29T20:06:17.290-00:00"
;     #inst "2000-01-01T00:00:09.159-00:00")


(s/def ::dubs (s/double-in :min -100.0 :max 100.0 :NaN? false :infinite? false))

(s/valid? ::dubs 2.9)                        ; => true
(s/valid? ::dubs Double/POSITIVE_INFINITY)   ; => false

(gen/sample (s/gen ::dubs))
; => (-2.0 -1.0 -1.5 0.0 -2.875 -2.0 -3.5 -1.0 5.5 1.421875)


; (check symbol*)

(stest/check `ranged-rand)
; => ({:spec #object[clojure.spec$fspec_impl$reify__14270 0x11daa03f "clojure.spec$fspec_impl$reify__14270@11daa03f"],
;      :clojure.spec.test.check/ret {:result true,
;                                    :num-tests 1000,
;                                    :seed 1477538561577},
;                                    :sym spec-guide.api/ranged-rand})


(defn ranged-rand  ;; BROKEN!
  "Returns random int in range start <= rand < end"
  [start end]
  (+ start (long (rand (- start end)))))

(stest/abbrev-result (first (stest/check `ranged-rand)))
; => {:spec (fspec :args (and (cat :start int? :end int?)
;                                   (fn* [p1__13593#] (< (:start p1__13593#) (:end p1__13593#))))
;                        :ret int?
;                        :fn (and (fn* [p1__13594#] (>= (:ret p1__13594#) (-> p1__13594# :args :start)))
;                                 (fn* [p1__13595#] (< (:ret p1__13595#) (-> p1__13595# :args :end))))),
;           :sym spec-guide.api/ranged-rand,
;           :failure {:clojure.spec/problems [{:path [:fn],
;                                              :pred (>= (:ret %) (-> % :args :start)),
;                                              :val {:args {:start -4, :end 0},
;                                                    :ret -5},
;                                              :via [],
;                                              :in []}],
;                     :clojure.spec.test/args (-4 0),
;                     :clojure.spec.test/val {:args {:start -4, :end 0}, :ret -5},
;                     :clojure.spec/failure :check-failed}}

)  ; end of comment
