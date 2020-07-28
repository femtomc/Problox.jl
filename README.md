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

You can, of course, use some of Julia's nice abstractions.

```julia
# Little generator - generates worlds :)
@logic function generator(p, q)
    C = var(:C);
    coin(:c1);
    coin(:c2);
    (p :: heads(C), q :: tails(C)) :- coin(C);
    win << heads(C);
    query(win);
end
```

Here's a world generator. This defines a function which produces worlds which you can evaluate with `evaluate`.

If you want to work at a lower-level, there's a set of direct APIs for building programs.

```julia
# This is a simple program in the direct Python interfaces.
C = Var("C")
p = SimpleProgram()
p.add_fact(coin(Constant("c1")))
p.add_fact(coin(Constant("c2")))
p.add_clause(AnnotatedDisjunction([heads(C, p=0.4), tails(C, p=0.6)], coin(C)))
p.add_clause(win << heads(C))
p.add_fact(query(win))
```

This might be useful if you'd like to hook this up to some other system.
