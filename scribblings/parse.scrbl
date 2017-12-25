#lang scribble/manual

@require[@for-label[racket/base
	            json
		    json-pointer]]

@title{Parsing and rendering}

How do you parse JSON Pointers to get JSON Pointer expressions?

@defproc[
(parse-json-pointer
[p json-pointer?])
json-pointer-expression?]

Given a JSON Pointer, produce a JSON Pointer expression.

The computation always succeeds (that is, no exception will be thrown).

What about going the other way around? You can do that, too:

@defproc[
(expression->pointer
[expr json-pointer-expression?])
json-pointer?
]

Given a JSON Pointer expression, produce a JSON Pointer.

The computation always succeeds (no exception will be thrown, unless, well, something really weird happens).
