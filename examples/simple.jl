module Simple

include("../src/Problox.jl")
using .Problox

# This is a simple program in the direct Python interfaces.
C = Var("C")
p = SimpleProgram()
p.add_fact(coin(Constant("c1")))
p.add_fact(coin(Constant("c2")))
p.add_clause(AnnotatedDisjunction([heads(C, p=0.4), tails(C, p=0.6)], coin(C)))
p.add_clause(win << heads(C))
p.add_fact(query(win))

res = evaluate(p)
println(res)

# Simple DSL - close to Prolog, with a few changes.
net = @logic begin
    C = var(:C);
    coin(:c1);
    coin(:c2);
    (0.4 :: heads(C), 0.6 :: tails(C)) :- coin(C);
    win << heads(C);
    query(win);
end

# Little generator - generates worlds :)
generator = @logic (p, q) begin
    C = var(:C);
    coin(:c1);
    coin(:c2);
    (p :: heads(C), q :: tails(C)) :- coin(C);
    win << heads(C);
    query(win);
end

net = generator(0.4, 0.6)

# Evaluation offloads to the C engine through Python.
println(evaluate(net))

end # module
