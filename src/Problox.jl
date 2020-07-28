module Problox

using Jaynes
using PyCall
using MacroTools
using MacroTools: @capture

#abstract type Statement end
#struct Network
#    entities::Vector{Symbol}
#    statements::Dict{Statement, Vector{Symbol}}
#end
#
#function _logic(expr)
#    @capture(expr, begin body__ end)
#    trans = map(body) do ex
#        if @capture(ex, var_ ~ d_)
#            println(var)
#        elseif @capture(ex, rel_ ? prob_ : stmt_)
#            println(rel)
#        end
#    end
#    return expr
#end
#
#macro logic(expr)
#    network = _logic(expr)
#    network
#end
#
#net = @logic begin
#    drops(:tree, :wood) ~ Bernoulli(0.3)
#    tall(:tree) ~ Bernoulli(0.3)
#    important(X) ? 0.3 : tall(X)
#    important(X) ? 0.7 : drops(X, :wood)
#end

# Imports.
problog = pyimport("problog")
sp = pyimport("problog.program")
pl = pyimport("problog.logic")
pt = pyimport("problog.tasks")
sample = pyimport("problog.tasks.sample")

modeltext = """
    0.3::a.
    0.5::b.
    c :- a; b.
    query(a).
    query(b).
    query(c).
"""
model = sp.PrologString(modeltext)
println(model)
result = sample.sample(model, n = 3, format = "dict")
for s in result
    @show s
end

end # module
