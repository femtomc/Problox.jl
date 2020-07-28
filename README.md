`Problox.jl` is a small DSL for _probabilistic relational modeling_ which wraps `ProbLog` - a wonderful, well-supported library which extends `Prolog` with probabilistic constructs.

Here's the DSL in action:

```julia
net = @logic begin
    C = var(:C);
    coin(:c1);
    coin(:c2);
    (0.4 :: heads(C), 0.6 :: tails(C)) :- coin(C);
    win << heads(C);
    query(win);
end
```

As long as you've got everything straightened out with `PyCall`, this will compile to a `PyObject` representing ProbLog's `SimpleProgram`.

You can evaluate the compiled representation directly in Julia. For example, 

```julia
println(evaluate(net))
```

will return

```julia
Dict{Any,Any}(PyObject win => 0.64)
```
