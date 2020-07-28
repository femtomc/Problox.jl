module Problox

using PyCall
using Conda
using MacroTools
using MacroTools: @capture

# Install ProbLog.
if PyCall.conda
	Conda.add("pip")
	pip = joinpath(Conda.BINDIR, "pip")
	run(`$pip install problog`)
else
	try
        pyimport("problog")
        pyimport("problog.program")
        pyimport("problog.logic")
        pyimport("problog.tasks")
        pyimport("problog.tasks.sample")
	catch ee
		typeof(ee) <: PyCall.PyError || rethrow(ee)
		warn("""
Python Dependencies not installed
Please either:
 - Rebuild PyCall to use Conda, by running in the julia REPL:
    - `ENV[PYTHON]=""; Pkg.build("PyCall"); Pkg.build("Problox")`
 - Or install the depencences, eg by running pip
	- `pip install problog`
	"""
		)
	end
end

problog = pyimport("problog")
pp = pyimport("problog.program")
pl = pyimport("problog.logic")
pt = pyimport("problog.tasks")
sample = pyimport("problog.tasks.sample")

# User-defined terms.
function term(str::String)
    return pl.Term(str)
end

coin, heads, tails, win, query = map(["coin", "heads", "tails", "win", "query"]) do t
    term(t)
end

SimpleProgram() = pp.SimpleProgram()
Var(str::String) =  pl.Var(str)
var(s::String) = Var(String(s))
var(s::Symbol) = Var(String(s))
Constant(str::String) =  pl.Constant(str)
AnnotatedDisjunction(p::Array{PyObject}, q::PyObject) = pl.AnnotatedDisjunction(p, q)
AnnotatedDisjunction(p::NTuple{N, PyObject}, q::PyObject) where N = pl.AnnotatedDisjunction([p...], q)

evaluate(p::PyObject) = problog.get_evaluatable().create_from(p).evaluate()

include("dsl.jl")

export @logic, SimpleProgram, Var, Constant, AnnotatedDisjunction, coin, heads, tails, win, query, evaluate

end # module
