defmodule Makeup.Lexers.RustLexer do
  import NimbleParsec
  import Makeup.Lexer.Combinators
  import Makeup.Lexer.Groups

  import Makeup.Lexers.RustLexer.Helper

  @behaviour Makeup.Lexer

  @moduledoc """
  Documentation for `MakeupRust`.
  """

  ###################################################################
  # Step #1: tokenize the input (into a list of tokens)
  ###################################################################
  # We will often compose combinators into larger combinators.
  # Sometimes, the smaller combinator is usefull on its own as a token, and sometimes it isn't.
  # We'll adopt the following "convention":
  #
  # 1. A combinator that ends with `_name` returns a string
  # 2. Other combinators will *usually* return a token
  #
  # Why this convention? Tokens can't be composed further, while raw strings can.
  # This way, we immediately know which of the combinators we can compose.

  whitespace = ascii_string([?\r, ?\s, ?\n, ?\f], min: 1) |> token(:whitespace)

  any_char = utf8_char([]) |> token(:error)

  # Numbers
  digits = ascii_string([?0..?9], min: 1)
  bin_digits = ascii_string([?0..?1], min: 1)
  hex_digits = ascii_string([?0..?9, ?a..?f, ?A..?F], min: 1)
  oct_digits = ascii_string([?0..?7], min: 1)
  # Digits in an integer may be separated by underscores
  number_bin = bin_digits |> with_optional_separator("_") |> prepend("0b") |> token(:number_bin)
  number_oct = oct_digits |> with_optional_separator("_") |> prepend("0o") |> token(:number_oct)
  number_hex = hex_digits |> with_optional_separator("_") |> prepend("0x") |> token(:number_hex)
  integer = with_optional_separator(digits, "_")

  # Base 10
  number_integer = token(integer, :number_integer)

  number_float =
    integer
    |> string(".")
    |> concat(integer)
    |> token(:number_float)

  variable_name =
    ascii_string([?a..?z, ?_], 1)
    |> optional(ascii_string([?a..?z, ?_, ?0..?9, ?A..?Z], min: 1))
    |> optional(ascii_string([??, ?!], 1))

  # Can also be a function name
  variable =
    variable_name
    |> lexeme
    |> token(:name)

  define_name =
    ascii_string([?A..?Z], 1)
    |> optional(ascii_string([?a..?z, ?_, ?0..?9, ?A..?Z], min: 1))

  define = token(define_name, :name_constant)

  operator_name = word_from_list(~W(
    -> + -  * / % ++ -- ~ ^ & && | ||
    =  += -= *= /= &= |= %= ^= << >>
    <<= >>= > < >= <= == != ! ? :
  ))

  operator = token(operator_name, :operator)

  normal_char =
    string("?")
    |> utf8_string([], 1)
    |> token(:string_char)

  escape_char =
    string("?\\")
    |> utf8_string([], 1)
    |> token(:string_char)

  directive =
    string("#")
    |> concat(variable_name)
    |> token(:keyword_pseudo)

  punctuation =
    word_from_list(
      ["\\\\", ":", ";", ",", "."],
      :punctuation
    )

  delimiters_punctuation =
    word_from_list(
      ~W( ( \) [ ] { }),
      :punctuation
    )

  unicode_char_in_string =
    string("\\u")
    |> ascii_string([?0..?9, ?a..?f, ?A..?F], 4)
    |> token(:string_escape)

  escaped_char =
    string("\\")
    |> utf8_string([], 1)
    |> token(:string_escape)

  combinators_inside_string = [
    unicode_char_in_string,
    escaped_char
  ]

  string_keyword =
    choice([
      string_like("\"", "\"", combinators_inside_string, :string_symbol),
      string_like("'", "'", combinators_inside_string, :string_symbol)
    ])
    |> concat(token(string(":"), :punctuation))

  normal_keyword =
    choice([operator_name, []])
    |> token(:string_symbol)
    |> concat(token(string(":"), :punctuation))

  keyword =
    choice([
      normal_keyword,
      string_keyword
    ])
    |> concat(whitespace)

  double_quoted_string_interpol = string_like("\"", "\"", combinators_inside_string, :string)

  line = repeat(lookahead_not(ascii_char([?\n])) |> utf8_string([], 1))

  inline_comment =
    string("//")
    |> concat(line)
    |> token(:comment_single)

  root_element_combinator =
    choice(
      [
        whitespace,
        # Comments
        inline_comment,
        # Syntax sugar for keyword lists (must come before variables and strings)
        directive,
        keyword,
        # Strings
        double_quoted_string_interpol
      ] ++
        [
          # Chars
          escape_char,
          normal_char
        ] ++
        [delimiters_punctuation] ++
        [
          # Operators
          operator,
          # Numbers
          number_bin,
          number_oct,
          number_hex,
          # Floats must come before integers
          number_float,
          number_integer,
          # Names
          variable,
          define,
          punctuation,
          # If we can't parse any of the above, we highlight the next character as an error
          # and proceed from there.
          # A lexer should always consume any string given as input.
          any_char
        ]
    )

  # By default, don't inline the lexers.
  # Inlining them increases performance by ~20%
  # at the cost of doubling the compilation times...
  @inline false

  @doc false
  def __as_rust_language__({ttype, meta, value}) do
    {ttype, Map.put(meta, :language, :rust), value}
  end

  # Semi-public API: these two functions can be used by someone who wants to
  # embed an Elixir lexer into another lexer, but other than that, they are not
  # meant to be used by end-users.

  # @impl Makeup.Lexer
  defparsec(
    :root_element,
    root_element_combinator |> map({__MODULE__, :__as_rust_language__, []}),
    inline: @inline
  )

  # @impl Makeup.Lexer
  defparsec(
    :root,
    repeat(parsec(:root_element)),
    inline: @inline
  )

  ###################################################################
  # Step #2: postprocess the list of tokens
  ###################################################################

  @keyword ~W[
    as break const continue crate else enum extern fn for if impl in
    let loop match mod move mut pub ref return self Self static super
    trait type unsafe use where while
  ]

  @keyword_type ~W[
    bool byte int long unsigned double char short signed float wchar_t
    char16_t char32_t i8 i16 i32 i64 i128 isize u8 u16 u32 u64 u128 usize
  ]

  @keyword_constant ~W[
    nil true false
  ]

  @operator_word ~W[and and_eq bitand bitor not not_eq or or_eq xor xor_eq]
  @name_builtin_pseudo ~W[__FUNCTION__ __FILE__ __LINE__]

  # The `postprocess/1` function will require a major redesign when we decide to support
  # custom `def`-like keywords supplied by the user.
  defp postprocess_helper([]), do: []

  # match function names. They are followed by parens...
  defp postprocess_helper([
         {:name, attrs, text},
         {:punctuation, %{language: :rust}, "("}
         | tokens
       ]) do
    [
      {:name_function, attrs, text},
      {:punctuation, %{language: :rust}, "("}
      | postprocess_helper(tokens)
    ]
  end

  defp postprocess_helper([{:name, attrs, text} | tokens]) when text in @keyword,
    do: [{:keyword, attrs, text} | postprocess_helper(tokens)]

  defp postprocess_helper([{:name, attrs, text} | tokens]) when text in @keyword_type,
    do: [{:keyword_type, attrs, text} | postprocess_helper(tokens)]

  defp postprocess_helper([{:name, attrs, text} | tokens]) when text in @keyword_constant,
    do: [{:keyword_constant, attrs, text} | postprocess_helper(tokens)]

  defp postprocess_helper([{:name, attrs, text} | tokens]) when text in @operator_word,
    do: [{:operator_word, attrs, text} | postprocess_helper(tokens)]

  defp postprocess_helper([{:name, attrs, text} | tokens]) when text in @name_builtin_pseudo,
    do: [{:name_builtin_pseudo, attrs, text} | postprocess_helper(tokens)]

  # Unused variables
  defp postprocess_helper([{:name, attrs, "_" <> _name = text} | tokens]),
    do: [{:comment, attrs, text} | postprocess_helper(tokens)]

  # Otherwise, don't do anything with the current token and go to the next token.
  defp postprocess_helper([token | tokens]), do: [token | postprocess_helper(tokens)]

  # Public API
  @impl Makeup.Lexer
  def postprocess(tokens, _opts \\ []), do: postprocess_helper(tokens)

  ###################################################################
  # Step #3: highlight matching delimiters
  ###################################################################

  @impl Makeup.Lexer
  defgroupmatcher(:match_groups,
    parentheses: [
      open: [[{:punctuation, %{language: :rust}, "("}]],
      close: [[{:punctuation, %{language: :rust}, ")"}]]
    ],
    array: [
      open: [[{:punctuation, %{language: :rust}, "["}]],
      close: [[{:punctuation, %{language: :rust}, "]"}]]
    ],
    brackets: [
      open: [[{:punctuation, %{language: :rust}, "{"}]],
      close: [[{:punctuation, %{language: :rust}, "}"}]]
    ]
  )

  defp remove_initial_newline([{ttype, meta, text} | tokens]) do
    case to_string(text) do
      "\n" -> tokens
      "\n" <> rest -> [{ttype, meta, rest} | tokens]
    end
  end

  # Finally, the public API for the lexer
  @impl Makeup.Lexer
  def lex(text, opts \\ []) do
    group_prefix = Keyword.get(opts, :group_prefix, random_prefix(10))
    {:ok, tokens, "", _, _, _} = root("\n" <> text)

    tokens
    |> remove_initial_newline()
    |> postprocess([])
    |> match_groups(group_prefix)
  end
end
