#lang scribble/manual

@require[@for-label[json-pointer
	            json
                    racket/base]]

@title[#:style "toc"]{json-pointer: Referring to bits of JSON}
@author[(author+email "Jesse Alama" "jesse@lisp.sh")]

@defmodule[json-pointer]

JSON Pointer @hyperlink[#:underline? #f "https://tools.ietf.org/html/rfc6901"]{(RFC 6901)} is a straightforward notation for referring to values embedded within a JSON document. Given a JSON object like this:

@verbatim{
    {
        "foo": 5,
        "bar": [ 1, 2 ]
    }
}

the JSON Pointer expression @tt{/foo} has the value @racket[5], whereas the expressions @tt{/bar/0} and @tt{/bar/1} have the values @racket[1] and @racket[2], respectively. @tt{/baz} and @tt{/bar/42} do not refer to anything.

Nothing terribly fancy is going on here: JSON Pointers are nothing more than Racket strings, and we work with @racket[jsexpr?] values.

@include-section["interface.scrbl"]

@include-section["license.scrbl"]
