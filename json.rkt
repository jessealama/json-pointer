#lang racket/base

(provide json-object?
         json-array?
         array-ref
         array-length
         json-number?
         has-property?
         property-value
         object-properties
         json-value?)

(require (only-in json
                  jsexpr?)
         (only-in racket/list
                  empty?
                  first
                  rest)
         racket/contract)

(module+ test
  (require rackunit))

(define (json-null? x)
  (eq? x 'null))

(define (json-object? x)
  (and (hash? x)
       (andmap symbol? (hash-keys x))
       (andmap json-value? (hash-values x))))

(define (json-string? x)
  (string? x))

(define (json-boolean? x)
  (boolean? x))

(define (json-array? x)
  (and (list? x)
       (andmap json-value? x)))

(module+ test
  (check-true (json-array? (list)))
  (check-false (json-array? (hasheq))))

(define (array-ref arr idx)
  (list-ref arr idx))

(define (array-length arr)
  (length arr))

(define (json-number? x)
  (real? x))

(module+ test
  (check-true (json-number? 4))
  (check-false (json-number? #t))
  (check-false (json-number? (hasheq)))
  (check-true (json-number? -4.5))
  (check-true (json-number? 3.141592653589793238462643383279)))

(define/contract (has-property? obj prop)
  (-> json-object? (or/c symbol? string?) boolean?)
  (cond [(symbol? prop)
         (hash-has-key? obj prop)]
        [(string? prop)
         (hash-has-key? obj (string->symbol prop))]))

(module+ test
  (let ([obj (hasheq 'foo "bar")])
    (check-true (has-property? obj 'foo))
    (check-true (has-property? obj "foo"))
    (check-false (has-property? obj 'bar))
    (check-false (has-property? obj "bar"))))

(define/contract (property-value obj prop)
  (-> json-object? (or/c symbol? string?) json-value?)
  (cond [(symbol? prop)
         (hash-ref obj prop)]
        [(string? prop)
         (hash-ref obj (string->symbol prop))]))

(module+ test
  (test-case "Basic JSON object check"
    (check-false (json-object? 5))
    (check-false (json-object? #t))
    (check-false (json-object? (list)))
    (check-true (json-object? (hasheq)))
    (check-true (json-object? (hasheq 'type "object")))))

(define (json-value? x)
  (or (json-null? x)
      (json-string? x)
      (json-number? x)
      (json-boolean? x)
      (json-array? x)
      (json-object? x)))

(define/contract (object-properties obj)
  (json-object? . -> . (listof json-value?))
  (hash-keys obj))
