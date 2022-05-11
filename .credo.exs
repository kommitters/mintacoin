%{
  configs: [
    %{
      name: "default",
      files: %{
        included: [
          "apps/*/lib/",
          "apps/*/test/",
        ],
      },
      strict: true,
      color: true,
      checks: [
        {Credo.Check.Readability.AliasOrder, false},
        {Credo.Check.Readability.Specs, []},
        {Credo.Check.Refactor.FunctionArity, max_arity: 10}
      ]
    }
  ]
}
