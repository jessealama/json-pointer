#lang racket/base

(provide json-object?
         json-string?
         json-null?
         json-boolean?
         json-array?
         array-items
         array-ref
         array-length
         json-number?
         has-property?
         property-value
         empty-array?
         object-properties
         remove-property
         json-equal?)

(require (only-in json
                  jsexpr?)
         (only-in racket/list
                  empty?
                  first
                  rest)
         racket/contract)

(module+ test
  (require rackunit))

(define/contract (json-object? x)
  (-> jsexpr? boolean?)
  (hash? x))

(define/contract (json-string? x)
  (-> jsexpr? boolean?)
  (string? x))

;; assumes that x is already a jsexpr? value
(define/contract (json-null? x)
  (-> jsexpr? boolean?)
  (eq? x 'null))

(module+ test
  (test-case "JSON null"
    (check-true (json-null? 'null))
    (check-false (json-null? (list)))
    (check-false (json-null? (hasheq)))
    (check-false (json-null? "null"))
    (check-false (json-null? 0))
    (check-false (json-null? #f))))

(define/contract (json-boolean? x)
  (-> jsexpr? boolean?)
  (boolean? x))

(define/contract (json-array? x)
  (-> jsexpr? boolean?)
  (list? x))

(module+ test
  (check-true (json-array? (list)))
  (check-false (json-array? (hasheq))))

(define/contract (array-items arr)
  (-> json-array? list?)
  arr)

(define/contract (array-ref arr idx)
  (-> json-array? exact-integer? jsexpr?)
  (list-ref (array-items arr) idx))

(define/contract (array-length arr)
  (-> json-array? exact-nonnegative-integer?)
  (length (array-items arr)))

(define/contract (json-number? x)
  (-> jsexpr? boolean?)
  (real? x))

(module+ test
  (check-true (json-number? 4))
  (check-false (json-number? #t))
  (check-false (json-number? (hasheq)))
  (check-true (json-number? -4.5))
  (check-true (json-number? 3.141592653589793238462643383279)))

(define/contract (json-integer? x)
  (-> jsexpr? boolean?)
  (integer? x))

(module+ test
  (test-case "JSON integers"
     (check-true (json-integer? 4))
     (check-true (json-integer? -4))
     (check-true (json-integer? 4.0))
     (check-false (json-integer? 4.1))
     (check-false (json-integer? #t))))

(define/contract (has-property? obj prop)
  (-> json-object? (or/c symbol? string?) boolean?)
  (cond ((symbol? prop)
         (hash-has-key? obj prop))
        ((string? prop)
         (hash-has-key? obj (string->symbol prop)))))

(module+ test
  (let ([obj (hasheq
              'foo "bar")])
    (check-true (jsexpr? obj))
    (check-true (has-property? obj 'foo))
    (check-true (has-property? obj "foo"))
    (check-false (has-property? obj 'bar))
    (check-false (has-property? obj "bar"))))

(define/contract (property-value obj prop)
  (-> json-object? (or/c symbol? string?) jsexpr?)
  (cond ((symbol? prop)
         (hash-ref obj prop))
        ((string? prop)
         (hash-ref obj (string->symbol prop)))))

(define/contract (empty-array? x)
  (-> json-array? boolean?)
  (empty? x))

(module+ test
  (test-case "Basic JSON object check"
    (check-false (json-object? 5))
    (check-false (json-object? #t))
    (check-false (json-object? (list)))
    (check-true (json-object? (hasheq)))
    (check-true (json-object? (hasheq 'type "object")))))

(define/contract (object-properties obj)
  (-> json-object? list?)
  (hash-keys obj))

(define/contract (json-equal-arrays? jsarr1 jsarr2)
  (-> json-array? json-array? boolean?)
  (if (empty? jsarr1)
      (empty? jsarr2)
      (if (empty? jsarr2)
          #f
          (let ([a1 (first jsarr1)]
                [b1 (first jsarr2)]
                [as (rest jsarr1)]
                [bs (rest jsarr2)])
            (and (json-equal? a1 b1)
                 (json-equal-arrays? as bs))))))

(define/contract (remove-property jsobj prop)
  (-> json-object? symbol? json-object?)
  (hash-remove jsobj prop))

(define/contract (json-equal-objects? jsobj1 jsobj2)
  (-> json-object? json-object? boolean?)
  (let ([props1 (object-properties jsobj1)])
    (if (empty? props1)
        (empty? (object-properties jsobj2))
        (let ([prop1 (first props1)])
          (and (has-property? jsobj2 prop1)
               (let ([val1 (property-value jsobj1 prop1)]
                     [val2 (property-value jsobj2 prop1)])
                 (and (json-equal? val1 val2)
                      (json-equal? (remove-property jsobj1 prop1)
                                   (remove-property jsobj2 prop1)))))))))

(define/contract (json-equal? js1 js2)
  (-> jsexpr? jsexpr? boolean?)
  (cond ((json-null? js1)
         (json-null? js2))
        ((json-string? js1)
         (and (json-string? js2)
              (string=? js1 js2)))
        ((json-number? js1)
         (and (json-number? js2)
              (= js1 js2)))
        ((json-boolean? js1)
         (and (json-boolean? js2)
              (eq? js1 js2)))
        ((json-array? js1)
         (and (json-array? js2)
              (json-equal-arrays? js1 js2)))
        ((json-object? js1)
         (and (json-object? js2)
              (json-equal-objects? js1 js2)))
        (else
         (error "Unknown type: Don't know how to deal with ~a." js1))))

(module+ test
  (test-case "Null equality"
    (check-true (json-equal? 'null 'null))
    (check-false (json-equal? 'null "null")))
  (test-case "String equality"
    (check-true (json-equal? "dog" "dog"))
    (check-false (json-equal? "a" "A"))
    (check-true (json-equal? "" ""))
    (check-true (json-equal? "düg" "d\u00fcg"))
    (check-false (json-equal? "null" 'null)))

  (test-case "Boolean equality"
    (check-true (json-equal? #f #f))
    (check-true (json-equal? #t #t))
    (check-false (json-equal? #f #t))
    (check-false (json-equal? #t 1))
    (check-false (json-equal? #f 0)))

  (test-case "Number equality"
    (check-true (json-equal? 0 0))
    (check-true (json-equal? 0 0.0))
    (check-false (json-equal? -1 -0.999999999))
    (check-true (json-equal? 3.141592654 3.141592654))
    (check-false (json-equal? 3.141592654 3.141592653))
    (check-true (json-equal? 4 4.000000000000))
    (check-false (json-equal? 4 4.000000000001)))

  (test-case "Object equality"
    (check-true (json-equal? (hasheq)
                             (hasheq)))
    (check-true (json-equal? (hasheq 'foo "bar")
                             (hasheq 'foo "bar")))
    (check-true (json-equal? (hasheq 'foo 'null)
                             (hasheq 'foo 'null)))
    (check-true (json-equal? (hasheq 'a "b"
                                     'c "d")
                             (hasheq 'c "d"
                                     'a "b")))
    (check-false (json-equal? (hasheq 'a "b"
                                      'c "d")
                              (hasheq 'a "d"
                                      'c "d")))
    (check-true (json-equal? (hasheq 'a "düg")
                             (hasheq 'a "d\u00fcg")))
    (check-true (json-equal? (hasheq 'a "b"
                                     'c (hasheq 'a "b"))
                             (hasheq 'a "b"
                                     'c (hasheq 'a "b"))))
    (check-true (json-equal? (hasheq 'a "b"
                                     'c (list "a" "b"))
                             (hasheq 'c (list "a" "b")
                                     'a "b"))))

  (test-case "Array equality"
    (check-true (json-equal? (list) (list)))
    (check-false (json-equal? (list "a") (list)))
    (check-false (json-equal? (list) (hasheq)))
    (check-true (json-equal? (list "a" (hasheq 'a "b"))
                             (list "a" (hasheq 'a "b"))))
    (check-false (json-equal? (list "a" "b")
                              (list "b" "a")))
    (check-true (json-equal? (list (list "a" "b"))
                             (list (list "a" "b"))))))
