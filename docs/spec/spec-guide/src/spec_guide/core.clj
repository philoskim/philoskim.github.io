(ns spec-guide.core
  (:require [clojure.spec :as s]
            [clojure.spec.gen :as gen]
            [clojure.spec.test :as stest] ))

(use 'debux.core)

(max 1 2 3 4)
; => 4

; (max)
; >> 1. Unhandled clojure.lang.ArityException
;       Wrong number of args (0) passed to: core/max
;    
;                      AFn.java:  429  clojure.lang.AFn/throwArity
;                   RestFn.java:  399  clojure.lang.RestFn/invoke
;                          REPL:    9  spec-guide.core/eval10839
;                          REPL:    9  spec-guide.core/eval10839
;                 Compiler.java: 6977  clojure.lang.Compiler/eval
;                 Compiler.java: 6940  clojure.lang.Compiler/eval
;                      core.clj: 3187  clojure.core/eval
;                      core.clj: 3183  clojure.core/eval
;                         ......

(defn my-max [coll]
  (apply max coll))

(my-max [1 2 3 4])
; => 4

; (my-max nil)
; >> 1. Unhandled clojure.lang.ArityException
;       Wrong number of args (0) passed to: core/max
;    
;                      AFn.java:  429  clojure.lang.AFn/throwArity
;                   RestFn.java:  399  clojure.lang.RestFn/invoke
;                      AFn.java:  152  clojure.lang.AFn/applyToHelper
;                   RestFn.java:  132  clojure.lang.RestFn/applyTo
;                      core.clj:  657  clojure.core/apply
;                      core.clj:  652  clojure.core/apply
;                          REPL:    7  spec-guide.core/my-max
;                          REPL:    6  spec-guide.core/my-max
;                          REPL:   28  spec-guide.core/eval10841
;                          REPL:   28  spec-guide.core/eval10841
;                 Compiler.java: 6977  clojure.lang.Compiler/eval
;                 Compiler.java: 6940  clojure.lang.Compiler/eval
;                      core.clj: 3187  clojure.core/eval
;                         ......


(s/fdef my-max2
  :args (s/cat :coll (s/coll-of number?))
  :ret number?)

(defn my-max2 [coll]
  (apply max coll))

(stest/instrument `my-max2)

(my-max2 [1 2 3 4])
; => 4

; (my-max2 nil)
; >> 1. Unhandled clojure.lang.ExceptionInfo
;       Call to #'spec-guide.core/my-max2 did not conform to spec:
;         In: [0]
;         val: nil fails
;         at: [:args :coll]
;         predicate: coll?
;       :clojure.spec/args (nil)
;       :clojure.spec/failure :instrument
;       :clojure.spec.test/caller {:file "form-init414233231437328049.clj",
;                                  :line 63, :var-scope spec-guide.core/eval10997}
;    
;       {:clojure.spec/problems [{:path [:args :coll],
;                                 :pred coll?,
;                                 :val nil,
;                                 :via [],
;                                 :in [0]}],
;        :clojure.spec/args (nil),
;        :clojure.spec/failure :instrument,
;        :clojure.spec.test/caller {:file "form-init414233231437328049.clj",
;                                   :line 63,
;                                   :var-scope spec-guide.core/eval10997}}


(s/fdef my-max3
  :args (s/and (s/cat :coll (s/coll-of number?))
               #(every? (fn [num]
                          (< num 10))
                        (:coll %) ))
  :ret number?)

(defn my-max3 [coll]
  (apply max coll))

(stest/instrument `my-max3)

; (my-max3 [1 2 3 14])
; >> 1. Unhandled clojure.lang.ExceptionInfo
;       Call to #'spec-guide.core/my-max3 did not conform to spec:
;         val: {:coll [1 2 3 14]} fails
;         at: [:args]
;         predicate: (every? (fn [num] (< num 10)) (:coll %))
;       :clojure.spec/args ([1 2 3 14])
;       :clojure.spec/failure :instrument
;       :clojure.spec.test/caller {:file "form-init414233231437328049.clj",
;                                  :line 97,
;                                  :var-scope spec-guide.core/eval11148}



(s/conform even? 1000)
; => 1000

(s/conform even? 1001)
; => :clojure.spec/invalid

(s/valid? even? 1000)
; => true

(s/valid? even? 1001)
; => false


(type (s/def ::str-or-kw (s/alt :str string?
                          :kw  keyword?)))

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
; >> val: #:spec-guide.core{:first-name "Elon"} fails
;    spec: :spec-guide.core/person
;    predicate: (contains? % :spec-guide.core/last-name)
;
;    val: #:spec-guide.core{:first-name "Elon"} fails
;    spec: :spec-guide.core/person
;    predicate: (contains? % :spec-guide.core/email)

(s/explain ::person
  {::first-name "Elon"
   ::last-name "Musk"
   ::email "n/a"})
; >> In: [:spec-guide.core/email]
;    val: "n/a" fails
;    spec: :spec-guide.core/email-type
;    at: [:spec-guide.core/email]
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
;    spec: :spec-guide.core/email-type
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

(defrecord Person [first-name last-name email phone])

(s/explain :unq/person
           (->Person "Elon" nil nil nil))
;; In: [:last-name] val: nil fails spec: :my.domain/last-name at: [:last-name] predicate: string?
;; In: [:email] val: nil fails spec: :my.domain/email at: [:email] predicate: string?

(s/conform :unq/person
  (->Person "Elon" "Musk" "elon@example.com" nil))
; => #spec_guide.core.Person{:first-name "Elon", :last-name "Musk",
;                            :email "elon@example.com", :phone nil}



;;; key*
;; keyword args where keyword keys and values are passed in a sequential data structure
;; as options. Spec provides special support for this pattern with the regex op keys*.

(s/def ::port number?)
(s/def ::host string?)
(s/def ::id keyword?)

(s/def ::server (s/keys* :req [::id ::host] :opt [::port]))

(s/conform ::server [::id :s1 ::host "example.com" ::port 5555])
; => #:spec-guide.core{:id :s1, :host "example.com", :port 5555}


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
;    spec: :spec-guide.core/point
;    at: [2]
;    predicate: double?

;; tuple: 반드시 vector 형이어야
(s/conform ::point '(1.5 2.5 -0.5))
; => :clojure.spec/invalid


;;; Sequences: Sequentials (vector와 list) 대상

(s/def ::ingredient (s/cat :quantity number? :unit keyword?))
(s/conform ::ingredient [2 :teaspoon])
; => {:quantity 2, :unit :teaspoon}

(s/conform ::ingredient '(2 :teaspoon))
; => {:quantity 2, :unit :teaspoon}


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



;;; Spec'ing functions: fdef

(defn ranged-rand
  "Returns random int in range start <= rand < end"
  [start end]
  (+ start (long (rand (- end start)))))

(s/fdef ranged-rand
  :args (s/and (s/cat :start int? :end int?)
               #(< (:start %) (:end %)))
  :ret int?
  :fn (s/and #(>= (:ret %) (-> % :args :start))
             #(< (:ret %) (-> % :args :end))))


(ranged-rand 5 10)
; => 7

(ranged-rand 10 5)
; => 9

(stest/instrument `ranged-rand)

(ranged-rand 5 10)
; => 7

; (ranged-rand 10 5)
; >> Call to #'spec-guide.core/ranged-rand did not conform to spec:
;    val: {:start 10, :end 5} fails
;    at: [:args]
;    predicate: (< (:start %) (:end %))
;    :clojure.spec/args (10 5)
;    :clojure.spec/failure :instrument
;    :clojure.spec.test/caller {:file "form-init7709795464976482689.clj",
;                               :line 400,
;                               :var-scope spec-guide.core/eval13655}

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


; (with-gen <spec> <generator>) => <generator>
(s/def ::kws
  (s/with-gen (s/and keyword? #(= (namespace %) "my.domain"))
              #(s/gen #{:my.domain/name :my.domain/occupation :my.domain/id}) ))

(s/valid? ::kws :my.domain/name)  ;; true
(gen/sample (s/gen ::kws) 5)
; => (:my.domain/occupation :my.domain/id :my.domain/id :my.domain/occupation :my.domain/id)


; (fmap <pred> <generator>) => <generator>

(def kw-gen-2 (gen/fmap #(keyword "my.domain" %)
                        (gen/string-alphanumeric) ))
(gen/sample kw-gen-2 5)
; => (:my.domain/ :my.domain/ :my.domain/ :my.domain/ :my.domain/w4jW)


; (such-that <pred> <generator>) => <generator> 
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

(stest/check `ranged-rand)
; => ({:spec #object[clojure.spec$fspec_impl$reify__14270 0x11daa03f "clojure.spec$fspec_impl$reify__14270@11daa03f"],
;      :clojure.spec.test.check/ret {:result true,
;                                    :num-tests 1000,
;                                    :seed 1477538561577},
;                                    :sym spec-guide.core/ranged-rand})


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
;           :sym spec-guide.core/ranged-rand,
;           :failure {:clojure.spec/problems [{:path [:fn],
;                                              :pred (>= (:ret %) (-> % :args :start)),
;                                              :val {:args {:start -4, :end 0},
;                                                    :ret -5},
;                                              :via [],
;                                              :in []}],
;                     :clojure.spec.test/args (-4 0),
;                     :clojure.spec.test/val {:args {:start -4, :end 0}, :ret -5},
;                     :clojure.spec/failure :check-failed}}


#:clojure.spec{:problems ({:path [:name],
                           :pred string?,
                           :val :foo,
                           :via [:spec-guide.core/name-or-id],
                           :in []}
                          {:path [:id],
                           :pred int?,
                           :val :foo,
                           :via [:spec-guide.core/name-or-id],
                           :in []})}
