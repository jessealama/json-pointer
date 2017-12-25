#lang info

(define collection "json-pointer")

(define version "0.3")

(define deps
  '("base"
    "rackunit-lib"))

(define build-deps
  '("scribble-lib"
    "racket-doc"
    "rackunit-lib"))

(define pkg-desc "json-pointer provides functions for parsing and evaluating JSON Pointers (IETF RFC 6901).")

(define pkg-authors '("jesse@lisp.sh"))

(define scribblings '(("scribblings/json-pointer.scrbl" ())))
