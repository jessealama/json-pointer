#lang scribble/manual

@require[@for-label[racket/base
	            json
		    json-pointer]]

@title{Library interface}

@defproc[
(json-pointer?
[x any/c])
boolean?]

Checks whether a string adheres to the syntax of JSON Pointer.

@defproc[
(json-pointer-value
[jp json-pointer?]
[doc jsexpr?])
jsexpr?]

Given a JSON Pointer and a JSON document, evaluate the JSON Pointer within the document.

This function throws an exception (of type @racket[exn:fail?]) under some conditions:

@itemlist[
  @item{The document, or some part of it, is not the right kind of JSON value.  For traversal through a JSON document to make sense, we need to be dealing with JSON objects or arrays, not with strings, numbers, or null values.}
  @item{The JSON Pointer refers to a non-existent part of the document. This happens if one refers to a non-existent object property or negative, out-of-bounds or nonsensical array indices such as @racket["radical"] or @racket[3.1415]).}
]
