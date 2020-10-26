function parse_disjuncts(head)
    ret = MacroTools.postwalk(head) do ex
        if @capture(ex, num_::call_(args__))
            quote $call($(args...), p = $num) end
        else
            ex
        end
    end
    ret
end

function parse_call(call, names)
    names = map(names) do name
        if name isa QuoteNode
            quote Constant(String($name)) end
        else
            name
        end
    end
    return quote sp.add_fact($call($(names...))) end
end

function parse_body(body)
    if @capture(body, head_ :- tail_)
        disjuncts = parse_disjuncts(head)
        return quote sp.add_clause(AnnotatedDisjunction($disjuncts, $tail)) end

    elseif @capture(body, head_ << tail_)
        return quote sp.add_clause($head << $tail) end

    elseif @capture(body, call_(names__))
        return parse_call(call, names)

    else
        body
    end
end

function _problox(expr)
    if @capture(expr, function name_(args__) body__ end)
        trans = map(body) do ex
            if @capture(ex, begin body__; end)
                length(body) == 1 || error("Parsing error at $body.")
                parse_body(body[1])
            else
                error("Parsing error at $body.")
            end
        end
        expr = quote 
            function $name($(args...))
                sp = SimpleProgram()
                $(trans...)
                sp
            end
        end

    elseif @capture(expr, begin body__ end)
        trans = map(body) do ex
            if @capture(ex, begin body__; end)
                length(body) == 1 || error("Parsing error at $body.")
                parse_body(body[1])
            else
                error("Parsing error at $body.")
            end
        end
        expr = quote 
            sp = SimpleProgram()
            $(trans...)
            sp
        end
    end
    expr
end

macro problox(expr)
    new = _problox(expr)
    new = MacroTools.postwalk(rmlines ∘ unblock, new)
    esc(new)
end
