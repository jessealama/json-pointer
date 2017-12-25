#lang racket/base

(provide json-pointer-expression?)

;; JSON Pointer expression is a simple representation of a
;; parsed JSON Pointer. The latter is simply a
;; string; the former is our representation of the semantics encoded
;; by JSON Pointers.

(define (json-pointer-expression? x)
  (and (list? x)
       (andmap string? x)))

(module+ test
  (require rackunit)
  (check-false (json-pointer-expression? ""))
  (check-true (json-pointer-expression? (list)))
  (check-true (json-pointer-expression? (list "")))
  (check-false (json-pointer-expression? "/foo/bar"))
  (check-false (json-pointer-expression? "#/foo/bar"))
  (check-false (json-pointer-expression? (list 'foo)))
  (check-false (json-pointer-expression? (hasheq))))
