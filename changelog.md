# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

(Nothing in the pipeline worth noting.)

## [0.7.0] - 2020-01-27

### Added

* Support for negative array indices. /-1 refers to the last element
  of a non-empty array, /-2 to the second-to-last element, and so on.

## [0.6.0] - 2018-11-30

### Added

* New function, `json-pointer-refers?`, to determine whether a JSON
  Pointer refers at all to a value. (To get the value, use
  `json-pointer-value`.)
