#lang racket
(require scribble/manual)
(require scribble/core
         scribble/decode
         scribble/html-properties)

;; (provide m-idx)

;; 메모마다 다르게 구현된 index
;; (define (m-idx method path)
;;   (index `(,path ,(string-upcase method))))