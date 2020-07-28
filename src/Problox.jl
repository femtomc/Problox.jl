module Problox

using Jaynes
using PyCall
using MacroTools
using MacroTools: @capture

# Imports.
problog = pyimport("problog")
sp = pyimport("problog.program")
pl = pyimport("problog.logic")
pt = pyimport("problog.tasks")
coin = pl.Term("coin")
sample = pyimport("problog.tasks.sample")

function parse_body(body)
    println(body)
    if @capture(body, coin(name_))
        name isa QuoteNode && return coin(String(name.value))
        return coin(pl.Var(String(name)))
    elseif @capture(body, head__ :- tail_)
        println(head)
        println(tail)
    end
end

function _logic(expr)
    @capture(expr, begin body__ end)
    trans = map(body) do ex
        if @capture(ex, begin body__; end)
            length(body) == 1 || error("Parsing error at $body.")
            parse_body(body[1])
        else
            error("Parsing error at $body.")
        end
    end
    return expr
end

macro logic(expr)
    network = _logic(expr)
    network
end

# User-defined terms.
function term(str::String)
    return pl.Term(str)
end

coin, heads, tails, win, query = map(["coin", "heads", "tails", "win", "query"]) do t
    term(t)
end

# Example DSL in Julia. This might not be the final syntax.
net = @logic begin
    coin(:c1);
    coin(:c2);
    0.4 :: heads(C), 0.6 :: tails(C) :- coin(C);
    win :- heads(C);
    evidence(heads(c1), false);
    query(win);
end

# Original model:
# coin(c1). coin(c2).
# 0.4::heads(C); 0.6::tails(C) :- coin(C).
# win :- heads(C).
# evidence(heads(c1), false).
# query(win).

# Want this:
# coin,heads,tails,win,query = Term('coin'),Term('heads'),Term('tails'),Term('win'),Term('query')
# C = Var('C')
# p = SimpleProgram()
# p += coin(Constant('c1'))
# p += coin(Constant('c2'))
# p += AnnotatedDisjunction([heads(C,p=0.4), tails(C,p=0.6)], coin(C))
# p += (win << heads(C))
# p += query(win)

end # module
