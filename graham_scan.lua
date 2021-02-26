-- This Lua implementation was based on this directory, thanks
-- https://github.com/melanz/graham-scan

table.copy = function(t)
    local new = {}
    for k, v in pairs(t) do
        new[k] = v
    end
    return new
end

local graham_scan = function(points)
    if (#points < 3) then
        return points
    end

    local minimum = function(Q)
        -- Find minimum y point (in case of tie select leftmost)
        -- Sort by y coordinate to ease the left most finding
        table.sort(Q, function(a, b) return a.y < b.y end)
        local y_min, smallest = 1000000, 1
        for i = 1, #Q do
            local p = Q[i]
            if (p.y < y_min) then
                y_min, smallest = p.y, i
            elseif (p.y == y_min) then -- Select left most
                if (Q[i - 1].x > p.x) then
                    smallest = i
                end
            end
        end
        return smallest
    end

    local distance = function(a, b)
        return (b.x - a.x) * (b.x - a.x) + (b.y - a.y) * (b.y - a.y)
    end

    local filter_equal_angles = function(p0, Q)
        -- If two points have same polar angle remove the closet to p0
        -- Distance can be calculated with vector length...
        for i = 2, #Q - 1 do
            if (Q[i - 1].polar == Q[i].polar) then
                local d1 = distance(p0, Q[i - 1])
                local d2 = distance(p0, Q[i])
                if (d2 < d1) then
                    table.remove(Q, i)
                else
                    table.remove(Q, i - 1)
                end
            end
        end
    end

    local cartesian_angle = function(x, y)
        if (x > 0 and y > 0) then
            return math.atan(y / x)
        elseif (x < 0 and y > 0) then
            return math.atan(-x / y) + math.pi / 2
        elseif (x < 0 and y < 0) then
            return math.atan(y / x) + math.pi
        elseif (x > 0 and y < 0) then
            return math.atan(-x / y) + math.pi / 2 + math.pi
        elseif (x == 0 and y > 0) then
            return math.pi / 2
        elseif (x < 0 and y == 0) then
            return math.pi
        elseif (x == 0 and y < 0) then
            return math.pi / 2 + math.pi
        else
            return 0
        end
    end

    local calculate_angle = function(p1, p2)
        return cartesian_angle(p2.x - p1.x, p2.y - p1.y)
    end

    local calculate_polar_angles = function(p0, Q)
        for i = 1, #Q do
            Q[i].polar = calculate_angle(p0, Q[i])
        end
    end

    -- Three points are a counter-clockwise turn
    -- if ccw > 0, clockwise if ccw < 0, and collinear if ccw = 0
    local ccw = function(p1, p2, p3)
        return (p2.x - p1.x) * (p3.y - p1.y) - (p2.y - p1.y) * (p3.x - p1.x)
    end

    -- Find minimum point
    local Q = table.copy(points) -- Make copy
    local minIndex = minimum(Q)
    local p0 = Q[minIndex]
    table.remove(Q, minIndex) -- Remove p0 from Q

    -- Sort by polar angle to p0
    calculate_polar_angles(p0, Q)
    table.sort(Q, function(a, b) return a.polar < b.polar end)

    -- Remove all with same polar angle but the farthest.
    filter_equal_angles(p0, Q)

    -- Graham scan
    local S = {}
    table.insert(S, p0)
    table.insert(S, Q[1])
    table.insert(S, Q[2])

    for i = 3, #Q do
        local pi = Q[i]
        while (ccw(S[#S - 1], S[#S], pi) <= 0) do
            table.remove(S)
        end
        table.insert(S, pi)
    end

    for i = 1, #S do
        S[i].polar = nil
    end

    return S
end

local test_points = {
    {x = 0, y = 0},
    {x = 0, y = 20},
    {x = 20, y = 20},
    {x = 20, y = 0},
    {x = 10, y = 10}
}

local make = graham_scan(test_points)
for k, v in ipairs(make) do
    print("{x = " .. tostring(v.x) .. ", y = " .. tostring(v.y) .. "}")
end