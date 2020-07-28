module Simple

include("../src/Problox.jl")
using .Problox

# Little generator - generates worlds :)
@logic function generator(p, q)
    C = variable(:C);
    coin(:c1);
    coin(:c2);
    (p :: heads(C), q :: tails(C)) :- coin(C);
    win << heads(C);
    query(win);
end

net = generate(0.3, 0.5)
ret = evaluate(net)
println(ret)

end # module
