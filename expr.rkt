#lang racket/base

(provide json-pointer-expression?)

;; A JSON Pointer expression is a (very) simple representation of a
;; parsed JSON Pointer value. The latter is simply a string; the
;; former is our representation of the semantics encoded by JSON
;; Pointers.

(define (json-pointer-expression? x)
  (and (list? x)
       (andmap string? x)))

(module+ test
  (require rackunit)
  (check-true (json-pointer-expression? (list)))
  (check-true (json-pointer-expression? (list "")))
  (check-false (json-pointer-expression? "/foo/bar"))
  (check-false (json-pointer-expression? (hasheq))))
