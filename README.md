json-pointer
============

    raco pkg install json-pointer

JSON Pointer is a straightforward notation for referring to values embedded within a JSON document. Given a JSON object like this:

    {
        "foo": 5,
        "bar": [ 1, 2 ]
    }

the JSON Pointer expression `/foo` has the value `5`, whereas the expressions `/bar/0` and `/bar/1` have the values `1` and `2`, respectively.

JSON Pointer is an IETF standard [RFC 6901][rfc].

Exports
----------

This library exports five functions:

*Predicates*

* `json-pointer?` checks whether a string adheres to the syntax of JSON Pointer
* `json-pointer-expression?` checks whether a list is a suitable representation of the steps that make up a JSON Pointer expression

*Parsing and rendering*

* `parse-json-pointer`: Produces a JSON Pointer expression from a JSON Pointer
* `expression->pointer`: Produces a JSON Pointer from a JSON Pointer expression

*Evaluation*

* `json-pointer-value` takes two arguments: a JSON Pointer (`json-pointer?`, defined in this library) and a JSON document (`jsexpr?`, provided by the standard `json` module) and evaluates the JSON Pointer within the document.

[rfc]: https://tools.ietf.org/html/rfc6901
