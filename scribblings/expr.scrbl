#lang scribble/manual

@require[@for-label[racket/base
	            json
		    json-pointer]]

@title{JSON Pointers and their expressions}

This library uses two terms: @emph{JSON Pointer} and @emph{JSON Pointer expression}. Briefly, the first is a string, and the second is a list. A predicate for the first:

@defproc[
(json-pointer?
[x any/c])
boolean?]

Returns @racket[#t] iff @tt{x} is a string that adheres to the syntax laid out in RFC 6901.

Next, a @emph{JSON Pointer expression} is a represenation of the data encoded in JSON Pointers. Think of it as the “parse tree” of a JSON Pointer. We represent this data as a list (possibly empty) of strings (which are themselves possibly empty).

@defproc[
(json-pointer-expression?
[x any/c])
boolean?]

Returns @racket[#t] iff @tt{x} is a list of strings.

There are essentially no constraints. The list might be empty. The strings in the list may themselves be empty, too. Duplicates are allowed.
