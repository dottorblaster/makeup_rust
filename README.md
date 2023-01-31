# MakeupRust

A [Makeup](https://github.com/elixir-makeup/makeup/) lexer for the Rust language.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `makeup_rust` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:makeup_rust, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/makeup_rust>.

## Example

Following an highlighted example taken from [`rhai_rustler`](https://github.com/fabriziosestito/rhai_rustler): 

```rust
mod errors;
mod types;

use std::collections::HashMap;

use rhai::{Dynamic, Engine, Scope};
use rustler::{Env, Term};

#[rustler::nif]
fn eval<'a>(
    env: Env<'a>,
    expression: &str,
    expression_scope: HashMap<String, Term<'a>>,
) -> Result<Term<'a>, Term<'a>> {
    // Create an 'Engine'
    let mut engine = Engine::new();
    engine.set_fail_on_invalid_map_property(true);
    let engine = engine;

    let mut scope = Scope::new();

    // Add variables to the scope
    for (k, v) in &expression_scope {
        scope.push_dynamic(k, types::to_dynamic(env, v));
    }

    match engine.eval_with_scope::<Dynamic>(&mut scope, expression) {
        Ok(result) => Ok(types::from_dynamic(env, result)),

        Err(e) => Err(errors::to_error(env, *e)),
    }
}

rustler::init!("Elixir.Rhai.Native", [eval]);
```
