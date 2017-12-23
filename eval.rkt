#lang racket/base

(require (only-in racket/contract
                  define/contract
                  or/c
                  ->)
         (only-in racket/list
                  empty?
                  first
                  second
                  rest)
         (only-in json
                  jsexpr?
                  bytes->jsexpr)
         (only-in (file "json.rkt")
                  json-object?
                  json-array?
                  array-length
                  empty-array?
                  has-property?
                  property-value
                  array-ref)
         (only-in (file "parser.rkt")
                  parse-json-pointer
                  json-pointer?)
         (only-in (file "expr.rkt")
                  json-pointer-expression?))

(provide json-pointer-value)

(module+ test
  (require rackunit))

(define/contract (find-value steps document)
  (-> list? jsexpr? jsexpr?)
  (cond ((empty? steps)
         document)
        (else
         (define step (first steps))
         (cond ((json-object? document)
                (unless (has-property? document step)
                  (error (format "Document does not have property \"~a\"." step)
                         document))
                (find-value (rest steps)
                            (property-value document step)))
               ((json-array? document)
                (define len (array-length document))
                (cond ((string=? step "0")
                       (when (empty-array? document)
                         (error "Empty array; cannot grab the 0th element."))
                       (find-value (rest steps)
                                   (array-ref document 0)))
                      ((regexp-match-exact? #px"[1-9][0-9]*" step)
                       (let ([index (string->number step)])
                         (when (<= len index)
                           (error (format "Index ~a out of bounds (array contains only ~a items)." index len) document))
                         (find-value (rest steps)
                                     (array-ref document index))))
                      ((string=? step "-")
                       (error "Minus character encountered."))
                      (else
                       (error (format "Cannot handle array index \"~a\" for current array." step) document))))
               (else
                (error "A JSON object or array is needed." document))))))

(define/contract (json-pointer-value jp doc)
  (-> (or/c json-pointer-expression? json-pointer?) jsexpr? jsexpr?)
  (define steps
    (cond ((json-pointer-expression? jp)
           jp)
          ((json-pointer? jp)
           (parse-json-pointer jp))
          (else
           (raise-argument-error 'json-pointer-value
                                 "(or/c json-pointer-expression? json-pointer?)"
                                 jp))))
  (find-value steps doc))

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
  (define sample-doc/jsexpr
    (bytes->jsexpr (string->bytes/utf-8 sample-doc/str)))
  (require (only-in (file "json.rkt")
                    json-equal?))
  (check json-equal?
         (json-pointer-value "" sample-doc/jsexpr)
         sample-doc/jsexpr)
  (check json-equal?
         (json-pointer-value "/foo" sample-doc/jsexpr)
         (list "bar" "baz"))
  (check json-equal?
         (json-pointer-value "/foo/0" sample-doc/jsexpr)
         "bar")
  (check json-equal?
         (json-pointer-value "/" sample-doc/jsexpr)
         0)
  (check json-equal?
         (json-pointer-value "/a~1b" sample-doc/jsexpr)
         1)
  (check json-equal?
         (json-pointer-value "/c%d" sample-doc/jsexpr)
         2)
  (check json-equal?
         (json-pointer-value "/e^f" sample-doc/jsexpr)
         3)
  (check json-equal?
         (json-pointer-value "/g|h" sample-doc/jsexpr)
         4)
  (check json-equal?
         (json-pointer-value "/i\\j" sample-doc/jsexpr)
         5)
  (check json-equal?
         (json-pointer-value "/k\"l" sample-doc/jsexpr)
         6)
  (check json-equal?
         (json-pointer-value "/ " sample-doc/jsexpr)
         7)
  (check json-equal?
         (json-pointer-value "/m~0n" sample-doc/jsexpr)
         8))

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