#lang racket/base

(provide json-pointer?
         json-pointer-value)

(require (only-in (file "expr.rkt")
                  json-pointer-expression?)
         (only-in (file "parser.rkt")
                  json-pointer?
                  expression->pointer)
         (only-in (file "eval.rkt")
                  json-pointer-value))
