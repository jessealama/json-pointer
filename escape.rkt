#lang racket/base

(provide escape-tildes
         unescape-tildes)

(require (only-in racket/contract
                  define/contract
                  ->)
         (only-in racket/string
                  string-replace))

(module+ test
  (require rackunit))

(define/contract (unescape-tildes str)
  (-> string? string?)
  (string-replace (string-replace str "~1" "/")
                  "~0"
                  "~"))

(module+ test
  (check-equal? "grue" (unescape-tildes "grue"))
  (check-equal? "~" (unescape-tildes "~0"))
  (check-equal? "/" (unescape-tildes "~1"))
  (check-equal? "~/" (unescape-tildes "~0~1"))
  (check-equal? "/~" (unescape-tildes "~1~0")))

(define/contract (escape-tildes str)
  (-> string? string?)
  (string-replace (string-replace str "~" "~0")
                  "/"
                  "~1"))

(module+ test
  (check-equal? "~1" (escape-tildes "/"))
  (check-equal? "~0" (escape-tildes "~"))
  (check-equal? "~00" (escape-tildes "~0"))
  (check-equal? "~0~01" (escape-tildes "~~1")))
