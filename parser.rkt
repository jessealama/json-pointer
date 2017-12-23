#lang racket/base

(module+ test
  (require rackunit))

(provide parse-json-pointer
         json-pointer?)

(require (only-in racket/contract
                  define/contract
                  ->
                  any/c
                  listof)
         (only-in racket/string
                  string-split
                  string-replace)
         (only-in racket/list
                  empty?
                  empty
                  rest))

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

(define/contract (json-pointer? x)
  (-> any/c boolean?)
  (and (string? x)
       (or (string=? "" x)
           (regexp-match? #rx"^/" x))))

(module+ test
  (check-false (json-pointer? " "))

  ;; examples copied from https://tools.ietf.org/html/rfc6901
  (check-true (json-pointer? ""))
  (check-true (json-pointer? "/foo"))
  (check-true (json-pointer? "/foo/0"))
  (check-true (json-pointer? "/"))
  (check-true (json-pointer? "/a~1b"))
  (check-true (json-pointer? "/c%d"))
  (check-true (json-pointer? "/e^f"))
  (check-true (json-pointer? "/g|h"))
  (check-true (json-pointer? "/i\\j"))
  (check-true (json-pointer? "/k\"l"))
  (check-true (json-pointer? "/ "))
  (check-true (json-pointer? "/m~0n")))

(define/contract (parse-json-pointer str)
  (-> json-pointer? (listof string?))
  (cond ((string=? "" str)
         empty)
        (else
         (map unescape-tildes
              (rest (string-split str "/" #:trim? #f))))))

(module+ test
  (check-equal? (list) (parse-json-pointer ""))
  (check-equal? (list "") (parse-json-pointer "/"))
  (check-equal? (list "frosch") (parse-json-pointer "/frosch"))
  (check-equal? (list "frosch" "") (parse-json-pointer "/frosch/"))
  (check-equal? (list "~") (parse-json-pointer "/~0"))
  (check-equal? (list "/") (parse-json-pointer "/~1")))
