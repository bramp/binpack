.PHONY: all format analyze test test-ci fix clean upgrade pub-outdated

## Run all checks (format, analyze, test)
all: format analyze test

## Format all Dart code
format:
	dart format .

## Run the analyzer across all packages
analyze:
	dart analyze

## Run all tests
test:
	dart test

## Run all tests for CI
test-ci: test

## Target for the GitHub actions
test-app-ci: test-ci

## Apply auto-fixes
fix:
	dart fix --apply

## Check for outdated dependencies in all directories
pub-outdated:
	dart pub outdated

## Upgrade dependencies
upgrade: pub-outdated
	dart pub upgrade --major-versions --tighten

## Delete build artifacts
clean:
	rm -rf .dart_tool/
