## 0.4.6

- Throw a more relevant exception for server error HTTP responses.

## 0.4.5

- Add support for model side Code Execution. Enable code execution by
  configuring `Tools` with a `codeExecution` argument.
- Use a default role `'model'` when a chat response comes back with no role.

## 0.4.4

- Allow the Vertex format for citation metadata - read either `citationSources`
  or `citations` keys, whichever exists. Fixes a `FormatException` when parsing
  vertex results with citations.

## 0.4.3

- Internal changes to enable reuse in the Vertex SDK. No user visible changes.

## 0.4.2

- Add support for `GenerationConfig.responseSchema` for constraining JSON mime
  type output formats.
- Require Dart 3.1.

## 0.4.1

- Concatenate multiple `TextPart` into the `text` String in case the model
  replies with more than one part.
- Fix handling of `format` argument to `Schema.number` and `Schema.integer`.
- Export `UsageMetadata`.
- Include the full `GenerateContentRequest` (previously omitted
  `safetySettings`, `generationConfig`, `tools`, `toolConfig`, and
  `systemInstruction`) in `countTokens` requests. This aligns the token count
  with the token count the backend will see in practice for a
  `generateContent` request.
- Add a `text` getter on `Candidate` to make it easer to retrieve the text from
  candidates other than the first in a response.

## 0.4.0

- Add support for parsing Vertex AI specific fields in `CountTokensResponse`.
- Add named constructors on `Schema` for each value type.
- Add `GenerationConfig.responseMimeType` which supports setting
  `'application/json'` to force the model to reply with JSON parseable output.
- Add `outputDimensionality` argument support for `embedContent` and
  `batchEmbedContent`.
- Add `Content.functionResponses` utility to reply to multiple function calls in
  parallel.
- **Breaking** The `Part` class is no longer `sealed`. Exhaustive switches over
  a `Part` instance will need to add a wildcard case.

## 0.3.3

- Add support for parsing the `usageMetadata` field in `GenerateContentResponse`
  messages.

## 0.3.2

- Use API version `v1beta` by default.
- Add note to README warning about leaking API keys.

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
