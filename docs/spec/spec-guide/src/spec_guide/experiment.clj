(ns spec-guide.experiment
  (:require [clojure.spec :as s]
            [clojure.spec.gen :as gen]
            [clojure.spec.test :as stest]
            [clojure.core.specs :as core]))

(use 'debux.core)

;;; generator 지정하지 않고도 check 실행 가능

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

(s/exercise-fn `ranged-rand)
; => ([(-1 0) -1] [(-2 100) 5] [(-1 0) -1] [(-1 0) -1]
;     [(-20 340) 81] [(41 428) 357] [(-1 0) -1] [(-102 -2) -83]
;     [(3 6) 5] [(2 230) 226])

(stest/check `ranged-rand)


;;; 멥에 ':req/:opt 옵션에 지정된 키' 이외의 키를 사용해도 무방

(s/def ::person (s/keys :req [::first-name ::last-name]
                        :opt [::age]))
(s/valid? ::person
  {::first-name "Elon"
   ::last-name "Musk"
   ::age 45
   ::sex :male})
; => true

(s/conform ::person
  {::first-name "Elon"
   ::last-name "Musk"
   ::sex :male})
; => #:spec-guide.experiment{:first-name "Elon", :last-name "Musk", :sex :male}

(s/conform ::person
  {::first-name "Elon"
   ::last-name "Musk"
   :sex :male})
; => {:spec-guide.experiment/first-name "Elon", :spec-guide.experiment/last-name "Musk",
;     :sex :male}


(s/def ::big-even (s/and int? even? #(> % 1000)))

(s/explain ::big-even 100)


(s/def ::b string?)
(s/def ::c int?)
(s/def ::a (s/keys :req [::b ::c]))

(s/def ::e keyword?)
(s/def ::f (s/coll-of number?))
(s/def ::d (s/coll-of (s/keys :req [::e ::f])))

(s/def ::data (s/keys :req [::a ::d]))


(s/valid? ::data {::a {::b "abc"
                       ::c 123}
                  ::d [{::e :bc
                        ::f [12.2 13 100]}
                       {::e :bc
                        ::f [-1] }]})
; => true

(s/valid? ::data {::a {::b 123
                       ::c "ABC"}})
; => false

(s/explain ::data {::a {::b 123
                        ::c "ABC"}})
; >> val: {:a {:b 123, :c "ABC"}} fails
;    spec: ::data
;    predicate: (contains? % ::d)
;
;    In: [::a ::b]
;    val: 123 fails
;    spec: ::b
;    at: [::a ::b]
;    predicate: string?
;
;    In: [::a ::c]
;    val: "ABC" fails
;    spec: ::c
;    at: [::a ::c]
;    predicate: int?


(def box {:with 10
          :height 20})

(defn print-box [box]
  (println "Width of the box is" (:width box))
  (println "Height of the box is" (:height box)))

(print-box box)
; >> Width of the box is 10
;    Height of the box is 20

(def box2 {:with 10
           :height 20})

(print-box box2)
; => Width of the box is nil
;    Height of the box is 20
  

(defn prepend-log [name body]
  (dbg [name body])
  (cons `(println ~name "has been called.") body))

(defn update-conf [{:keys [:bs] :as conf} body-update-fn]
  (update-in conf [:bs 1 :body] body-update-fn))

(defmacro defnlog [& args]
  (let [{:keys [name] :as conf} (s/conform ::core/defn-args args)
        new-conf (update-conf conf (partial prepend-log (str name)))
        new-args (s/unform ::core/defn-args new-conf)]
    (cons `defn new-args)))

(s/conform ::core/defn-args '(add [a b] (+ a b)))
; => {:name add,
;     :bs [:arity-1 {:args {:args [[:sym a] [:sym b]]},
;     :body [(+ a b)]}]}

(defnlog add [a b]
  (+ a b))

(add 10 20)
