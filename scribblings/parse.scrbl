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

What about going the other way around? Can you render a “semantic” JSON Pointer expression into a “syntactic” JSON Pointer? Yes, you can:

@defproc[
(expression->pointer
[expr json-pointer-expression?])
json-pointer?
]

Given a JSON Pointer expression, produce a JSON Pointer.
