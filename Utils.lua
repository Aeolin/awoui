function countIf(table, predicate) 
    local res = 0
    for i,val in pairs(table) do
        if predicate == nil or predicate(val) then
            res = res + 1
        end
    end
    return res
end

function getSortedByValue(tbl, sortFunction)
    local keys = {}
    for key in pairs(tbl) do
        table.insert(keys, key)
    end

    table.sort(keys, function(a, b)
        return sortFunction(tbl[a], tbl[b])
    end)

    local res = {}
    for i, key in ipairs(keys) do
        table.insert(res, tbl[key])
    end
    return res
end