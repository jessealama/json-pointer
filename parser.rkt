#lang racket/base

(module+ test
  (require rackunit))

(provide parse-json-pointer
         json-pointer?
         expression->pointer)

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
                  first
                  rest)
         (only-in (file "expr.rkt")
                  json-pointer-expression?)
         (only-in (file "escape.rkt")
                  escape-tildes
                  unescape-tildes))

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
  (-> json-pointer? json-pointer-expression?)
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

(define/contract (expression->pointer steps)
  (-> json-pointer-expression? json-pointer?)
  (if (empty? steps)
      ""
      (format "/~a~a" (escape-tildes (first steps)) (expression->pointer (rest steps)))))

(module+ test
  (check-equal? "" (expression->pointer (list)))
  (check-equal? "/" (expression->pointer (list "")))
  (check-equal? "/red/rum" (expression->pointer (list "red" "rum")))
  (check-equal? "///" (expression->pointer (list "" "" ""))))

(module+ test
  ;; checking that we can deal with escaped characters
  (check-equal? "/~0" (expression->pointer (list "~")))
  (check-equal? "/~1" (expression->pointer (list "/"))))
