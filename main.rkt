#lang racket/base

(provide json-pointer?
         json-pointer-value)

(require (only-in (file "parser.rkt")
                  json-pointer?)
         (only-in (file "evaluate.rkt")
                  json-pointer-value))
