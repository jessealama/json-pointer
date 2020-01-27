#lang racket/base

(provide json-pointer-value
         json-pointer-refers?)

(require (only-in racket/contract
                  define/contract
                  or/c
                  ->)
         (only-in racket/list
                  empty?
                  first
                  second
                  rest)
         (only-in racket/function
                  const)
         (only-in (file "json.rkt")
                  json-object?
                  json-array?
                  array-length
                  has-property?
                  property-value
                  array-ref
                  json-value?)
         (only-in (file "parser.rkt")
                  parse-json-pointer
                  json-pointer?)
         (only-in (file "expr.rkt")
                  json-pointer-expression?))

(module+ test
  (require rackunit))

(define/contract (refer-to/object step object)
  (-> string? json-object? json-value?)
  (property-value object step))

(define/contract (refer-to/array step array)
  (-> string? json-array? json-value?)
  (cond [(string=? step "0")
         (array-ref array 0)]
        [(regexp-match-exact? #px"[1-9][0-9]*" step)
         (array-ref array (string->number step))]
        [(regexp-match-exact? #px"[-][1-9][0-9]*" step)
         (array-ref array (+ (length array)
                             (string->number step)))]
        [else
         (error (format "Cannot handle array index \"~a\" for current array." step) array)]))

(define/contract (refer-to step document)
  (-> string? (or/c json-object? json-array?) json-value?)
  (cond ((json-object? document)
         (refer-to/object step document))
        ((json-array? document)
         (refer-to/array step document))))

(define/contract (find-value steps document)
  (-> list? json-value? json-value?)
  (if (empty? steps)
      document
      (find-value (rest steps)
                  (refer-to (first steps) document))))

(define/contract (json-pointer-value jp doc)
  (-> (or/c json-pointer-expression? json-pointer?) json-value? json-value?)
  (find-value (cond ((json-pointer-expression? jp)
                     jp)
                    ((json-pointer? jp)
                     (parse-json-pointer jp)))
              doc))

(module+ test
  (define sample-doc/str #<<SAMPLE
 {
      "foo": ["bar", "baz"],
      "": 0,
      "a/b": 1,
      "c%d": 2,
      "e^f": 3,
      "g|h": 4,
      "i\\j": 5,
      "k\"l": 6,
      " ": 7,
      "m~n": 8
   }
SAMPLE
    ))

(module+ test
  (require (only-in ejs
                    string->ejsexpr
                    equal-ejsexprs?))
  (define sample-doc/ejsexpr (string->ejsexpr sample-doc/str))
  (check equal-ejsexprs?
         (json-pointer-value "" sample-doc/ejsexpr)
         sample-doc/ejsexpr)
  (check equal-ejsexprs?
         (json-pointer-value "/foo" sample-doc/ejsexpr)
         (list "bar" "baz"))
  (check equal-ejsexprs?
         (json-pointer-value "/foo/0" sample-doc/ejsexpr)
         "bar")
  (check equal-ejsexprs?
         (json-pointer-value "/" sample-doc/ejsexpr)
         0)
  (check equal-ejsexprs?
         (json-pointer-value "/a~1b" sample-doc/ejsexpr)
         1)
  (check equal-ejsexprs?
         (json-pointer-value "/c%d" sample-doc/ejsexpr)
         2)
  (check equal-ejsexprs?
         (json-pointer-value "/e^f" sample-doc/ejsexpr)
         3)
  (check equal-ejsexprs?
         (json-pointer-value "/g|h" sample-doc/ejsexpr)
         4)
  (check equal-ejsexprs?
         (json-pointer-value "/i\\j" sample-doc/ejsexpr)
         5)
  (check equal-ejsexprs?
         (json-pointer-value "/k\"l" sample-doc/ejsexpr)
         6)
  (check equal-ejsexprs?
         (json-pointer-value "/ " sample-doc/ejsexpr)
         7)
  (check equal-ejsexprs?
         (json-pointer-value "/m~0n" sample-doc/ejsexpr)
         8))

;; check negative references
(module+ test
  (check-equal? (json-pointer-value "/-1" (list "a" "b"))
                "b")
  (check-equal? (json-pointer-value "/-2" (list "a" "b"))
                "a")
  (check-equal? (json-pointer-value "/-1" (list 5))
                5))

(module+ test
  (let ([doc (list "foo" 3)])
    (check-equal? "foo" (json-pointer-value "/0" doc))
    (check-equal? 3 (json-pointer-value "/1" doc))
    (check-exn exn:fail? (lambda () (json-pointer-value "/foo/bar" doc)))
    (check-exn exn:fail? (lambda () (json-pointer-value "/3" doc)))
    (check-equal? doc (json-pointer-value "" doc))))

(module+ test
  (let* ([jp "/foo/bar"]
         [steps (parse-json-pointer jp)]
         [doc (hasheq 'foo (hasheq 'bar #t))])
    (check-equal? #t (json-pointer-value jp doc))
    (check-equal? #t (json-pointer-value steps doc))))

(define/contract (json-pointer-refers? jp doc)
  (-> (or/c json-pointer-expression? json-pointer?) json-value? boolean?)
  (with-handlers ([exn:fail? (const #f)])
    (begin0
        #t
      (json-pointer-value jp doc))))

(module+ test
  (let* ([jp "/hi"])
    (check-false (json-pointer-refers? jp (list)))
    (check-false (json-pointer-refers? jp (list "hi")))
    (check-false (json-pointer-refers? jp (hasheq)))
    (check-true (json-pointer-refers? jp (hasheq 'hi "there")))
    (check-false (json-pointer-refers? jp "WTF?"))
    (check-false (json-pointer-refers? jp 'null))
    (check-false (json-pointer-refers? jp 123))))
