#lang scribble/manual

@require[@for-label[racket/base
	            json
		    json-pointer]]

@title{Evaluation of JSON Pointers}

@defproc[
(json-pointer-value
[jp (or/c json-pointer-expression? json-pointer?)]
[doc jsexpr?])
jsexpr?]

Given a JSON Pointer and a JSON document, evaluate the JSON Pointer within the document. The result is a @racket[jsexpr?], if all goes well.

(For the first argument both @racket[json-pointer?]—a string—as well as a @racket[json-pointer-expression]—a listof strings—are allowed. When given a @racket[json-pointer?], it will be parsed into a @racket[json-pointer-expression?].)

If things @emph{don’t} go well, @racket[json-pointer-value] function throws an exception (of type @racket[exn:fail?]). These are the conditions under which evaluation might go awry:

@itemlist[
  @item{The document, or some salient part of it, is not the right kind of JSON value.  For traversal through a JSON document to make sense, we need to be dealing with JSON objects or arrays, not with strings, numbers, or null values.}
  @item{The JSON Pointer refers to a non-existent part of the document. This happens if one refers to a non-existent object property or negative, out-of-bounds or nonsensical array indices such as @racket["radical"] or @racket[3.1415]).}
]
