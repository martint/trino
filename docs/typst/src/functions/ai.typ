#import "/lib/trino-docs.typ": *

#anchor("doc-functions-ai")
= AI functions

The AI functions allow you to invoke a large language model \(LLM\) to perform various textual tasks. Multiple LLM providers are supported, specifically #link("https://platform.openai.com/")[OpenAI] and #link("https://www.anthropic.com/api")[Anthropic] directly, and many others such as Llama, DeepSeek, Phi, Mistral, or Gemma using #link("https://ollama.com/")[Ollama].

The LLM must be provided outside Trino as an external service.

== Configuration

Because the AI functions require an external LLM service, they are not available by default. To enable them, you must configure a #link(label("ref-catalog-properties"))[catalog properties file] to register the functions invoking the configured LLM with the specified catalog name.

Create a catalog properties file #raw("etc/catalog/llm.properties") that references the #raw("ai") connector:

#code-block("properties", "connector.name=ai")

The AI functions are available with the #raw("ai") schema name. For the preceding example, the functions use the #raw("llm.ai") catalog and schema prefix.

To avoid needing to reference the functions with their fully qualified name, configure the #raw("sql.path") #link(label("doc-admin-properties-sql-environment"))[SQL environment property] in the #raw("config.properties") file to include the catalog and schema prefix:

#code-block("properties", "sql.path=llm.ai")

Configure multiple catalogs to use the same functions with different LLM providers. In this case, the functions must be referenced using their fully qualified name, rather than relying on the SQL path.

=== Providers

The AI functions invoke an external LLM. Access to the LLM API must be configured in the catalog. Performance, results, and cost of all AI function invocations are dependent on the LLM provider and the model used. You must specify a model that is suitable for textual analysis.

#list-table((
  ([Property name], [Description],),
  ([#raw("ai.provider")], [Required name of the provider. Must be #raw("anthropic") for using the #link(label("ref-ai-anthropic"))[Anthropic provider] or #raw("openai") for #link(label("ref-ai-openai"))[OpenAI] or #link(label("ref-ai-ollama"))[Ollama].],),
  ([#raw("ai.anthropic.endpoint")], [URL for the Anthropic API endpoint. Defaults to #raw("https://api.anthropic.com").],),
  ([#raw("ai.anthropic.api-key")], [API key value for Anthropic API access. Required with #raw("ai.provider") set to #raw("anthropic").],),
  ([#raw("ai.openai.endpoint")], [URL for the OpenAI API or Ollama endpoint. Defaults to #raw("https://api.openai.com"). Set to the URL endpoint for Ollama when using models via Ollama and add any string for the #raw("ai.openai.api-key").],),
  ([#raw("ai.openai.api-key")], [API key value for OpenAI API access. Required with #raw("ai.provider") set to #raw("openai"). Required and ignored with Ollama use.],)
), header-rows: 1, title: "AI functions provider configuration properties")

The AI functions connect to the providers over HTTP. Configure the connection using the #raw("ai") prefix with the #link(label("doc-admin-properties-http-client"))[HTTP client properties].

The following sections show minimal configurations for Anthropic, OpenAI, and Ollama use.

#anchor("ref-ai-anthropic")

==== Anthropic

The Anthropic provider uses the #link("https://www.anthropic.com/api")[Anthropic API] to perform the AI functions:

#code-block("properties", "ai.provider=anthropic
ai.model=claude-3-5-sonnet-latest
ai.anthropic.api-key=xxx")

Use #link(label("doc-security-secrets"))[secrets] to avoid actual API key values in the catalog properties files.

#anchor("ref-ai-openai")

==== OpenAI

The OpenAI provider uses the #link("https://platform.openai.com/")[OpenAI API] to perform the AI functions:

#code-block("properties", "ai.provider=openai
ai.model=gpt-4o-mini
ai.openai.api-key=xxx")

Use #link(label("doc-security-secrets"))[secrets] to avoid actual API key values in the catalog properties files.

#anchor("ref-ai-ollama")

==== Ollama

The OpenAI provider can be used with #link("https://ollama.com/")[Ollama] to perform the AI functions, as Ollama is compatible with the OpenAI API:

#code-block("properties", "ai.provider=openai
ai.model=llama3.3
ai.openai.endpoint=http://localhost:11434
ai.openai.api-key=none")

An API key must be specified, but is ignored by Ollama.

Ollama allows you to use #link("https://ollama.com/search")[Llama, DeepSeek, Phi, Mistral, Gemma and other models] on a self-hosted deployment or from a vendor.

=== Model configuration

All providers support a number of different models. You must configure at least one model to use for the AI function. The model must be suitable for textual analysis. Provider and model choice impacts performance, results, and cost of all AI functions.

Costs vary with AI function used based on the implementation prompt size, the length of the input, and the length of the output from the model, because model providers charge based input and output tokens.

Optionally configure different models from the same provider for each functions as an override:

#list-table((
  ([Property name], [Description],),
  ([#raw("ai.model")], [Required name of the model. Valid names vary by provider. Model must be suitable for textual analysis. The model is used for all functions, unless a specific model is configured for a function as override.],),
  ([#raw("ai.analyze-sentiment.model")], [Optional override to use a different model for #link(label("fn-ai-analyze-sentiment"), raw("ai_analyze_sentiment")).],),
  ([#raw("ai.classify.model")], [Optional override to use a different model for #link(label("fn-ai-classify"), raw("ai_classify")).],),
  ([#raw("ai.extract.model")], [Optional override to use a different model for #link(label("fn-ai-extract"), raw("ai_extract")).],),
  ([#raw("ai.fix-grammar.model")], [Optional override to use a different model for #link(label("fn-ai-fix-grammar"), raw("ai_fix_grammar")).],),
  ([#raw("ai.generate.model")], [Optional override to use a different model for #link(label("fn-ai-gen"), raw("ai_gen")).],),
  ([#raw("ai.mask.model")], [Optional override to use a different model for #link(label("fn-ai-mask"), raw("ai_mask")).],),
  ([#raw("ai.translate.model")], [Optional override to use a different model for #link(label("fn-ai-translate"), raw("ai_translate")).],)
), header-rows: 1, title: "AI function model configuration properties")

== Functions

The following functions are available in each catalog configured with the #raw("ai") connector under the #raw("ai") schema and use the configured LLM provider:

#function-def("fn-ai-analyze-sentiment", "ai_analyze_sentiment(text)", "varchar")[
Analyzes the sentiment of the input text.

The sentiment result is #raw("positive"), #raw("negative"), #raw("neutral"), or #raw("mixed").

#code-block("sql", "SELECT ai_analyze_sentiment('I love Trino');
-- positive")
]

#function-def("fn-ai-classify", "ai_classify(text, labels)", "varchar")[
Classifies the input text according to the provided labels.

#code-block("sql", "SELECT ai_classify('Buy now!', ARRAY['spam', 'not spam']);
-- spam")
]

#function-def("fn-ai-extract", "ai_extract(text, labels)", "map(varchar, varchar)")[
Extracts values for the provided labels from the input text.

#code-block("sql", "SELECT ai_extract('John is 25 years old', ARRAY['name', 'age']);
-- {name=John, age=25}")
]

#function-def("fn-ai-fix-grammar", "ai_fix_grammar(text)", "varchar")[
Corrects grammatical errors in the input text.

#code-block("sql", "SELECT ai_fix_grammar('I are happy. What you doing?');
-- I am happy. What are you doing?")
]

#function-def("fn-ai-gen", "ai_gen(prompt)", "varchar")[
Generates text based on the input prompt.

#code-block("sql", "SELECT ai_gen('Describe Trino in a few words');
-- Distributed SQL query engine.")
]

#function-def("fn-ai-mask", "ai_mask(text, labels)", "varchar")[
Masks the values for the provided labels in the input text by replacing them with the text #raw("[MASKED]").

#code-block("sql", "SELECT ai_mask(
    'Contact me at 555-1234 or visit us at 123 Main St.',
    ARRAY['phone', 'address']);
-- Contact me at [MASKED] or visit us at [MASKED].")
]

#function-def("fn-ai-translate", "ai_translate(text, language)", "varchar")[
Translates the input text to the specified language.

#code-block("sql", "SELECT ai_translate('I like coffee', 'es');
-- Me gusta el café

SELECT ai_translate('I like coffee', 'zh-TW');
-- 我喜歡咖啡")
]
