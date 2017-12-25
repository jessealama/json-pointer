json-pointer
============

JSON Pointer is a straightforward notation for referring to values embedded within a JSON document. Given a JSON object like this:

    {
        "foo": 5,
        "bar": [ 1, 2 ]
    }

the JSON Pointer expression `/foo` has the value `5`, whereas the expressions `/bar/0` and `/bar/1` have the values `1` and `2`, respectively.

JSON Pointer is an IETF standard [RFC 6901][rfc].

Exports
----------

This library exports two functions:

* `json-pointer?` checks whether a string adheres to the syntax of JSON Pointer, and
* `json-pointer-value` takes two arguments: a JSON Pointer (`json-pointer?`, defined in this library) and a JSON document (`jsexpr?`, provided by the standard `json` module) and evaluates the JSON Pointer within the document. (This function understandably throws exceptions if the document [or some part of it] is not the right kind of JSON value, or if the JSON Pointer refers to a non-existent part of the document.)

[rfc]: https://tools.ietf.org/html/rfc6901
