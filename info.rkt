#lang info

(define collection "json-pointer")

(define version "0.7")

(define deps
  '("base"
    "rackunit-lib"
    "ejs"))

(define build-deps
  '("scribble-lib"
    "racket-doc"
    "rackunit-lib"))

(define pkg-desc "Parse and evaluate JSON Pointers (IETF RFC 6901).")

(define pkg-authors '("jesse@serverracket.com"))

(define scribblings '(("scribblings/json-pointer.scrbl" ())))
