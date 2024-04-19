## 0.3.2-wip

- Use API version `v1beta` by default.

## 0.3.1

- Add support on content generating methods for overriding "tools" passed when
  the generative model was instantiated.
- Add support for forcing the model to use or not use function calls to generate
  content.

## 0.3.0

- Allow specifying an API version in a `requestOptions` argument when
  constructing a model.
- Add support for referring to uploaded files in request contents.
- Add support for passing tools with functions the model may call while
  generating responses.
- Add support for passing a system instruction when creating the model.
- **Breaking** Added new subclasses `FilePart`, `FunctionCall`, and
  `FunctionResponse` of the sealed class `Part`.

## 0.2.3

- Update the package version that is sent with the HTTP client name.
- Throw more actionable error objects than `FormatException` for errors. Errors
  were previously only correctly parsed in `generateContent` calls.
- Add support for tuned models.
- Add support for `batchEmbedContents` calls.

## 0.2.2

- Remove usage of new SDK features - support older SDKs 3.0 and above.

## 0.2.1

- Fix an issue parsing `generateContent()` responses that do not include content
  (this can occur for some `finishReason`s).
- Fix an issue parsing `generateContent()` responses that include citation
  sources with unpopulated fields
- Add link to ai.google.dev docs.

## 0.2.0

- **Breaking** `HarmCategory.unknown` renamed to `unspecified`. Removed unused
  `unknown` values in the `HarmProbability` and `FinishReason` enums.
- Add additional API documentation.
- Update the getting started instructions in the readme.

## 0.1.0

- Initial release.
