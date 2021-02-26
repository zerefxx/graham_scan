-- This Lua implementation was based on this directory, thanks
-- https://github.com/melanz/graham-scan

table.copy = (t) ->
    new = {k, v for k, v in pairs t}
    return new

graham_scan = (points) ->
    return points if (#points < 3)

    minimum = (Q) ->
        -- Find minimum y point (in case of tie select leftmost)
        -- Sort by y coordinate to ease the left most finding
        table.sort(Q, (a, b) -> return a.y < b.y)
        y_min, smallest = 1000000, 1
        for i = 1, #Q
            p = Q[i]
            if (p.y < y_min)
                y_min, smallest = p.y, i
            elseif (p.y == y_min) -- Select left most
                smallest = i if (Q[i - 1].x > p.x)
        return smallest

    distance = (a, b) -> return (b.x - a.x) * (b.x - a.x) + (b.y - a.y) * (b.y - a.y)

    filter_equal_angles = (p0, Q) ->
        -- If two points have same polar angle remove the closet to p0
        -- Distance can be calculated with vector length...
        for i = 2, #Q - 1
            if (Q[i - 1].polar == Q[i].polar)
                d1 = distance(p0, Q[i - 1])
                d2 = distance(p0, Q[i])
                if (d2 < d1)
                    table.remove(Q, i)
                else
                    table.remove(Q, i - 1)

    cartesian_angle = (x, y) ->
        if (x > 0 and y > 0)
            return math.atan(y / x)
        elseif (x < 0 and y > 0)
            return math.atan(-x / y) + math.pi / 2
        elseif (x < 0 and y < 0)
            return math.atan(y / x) + math.pi
        elseif (x > 0 and y < 0)
            return math.atan(-x / y) + math.pi / 2 + math.pi
        elseif (x == 0 and y > 0)
            return math.pi / 2
        elseif (x < 0 and y == 0)
            return math.pi
        elseif (x == 0 and y < 0)
            return math.pi / 2 + math.pi
        else
            return 0

    calculate_angle = (p1, p2) -> return cartesian_angle(p2.x - p1.x, p2.y - p1.y)

    calculate_polar_angles = (p0, Q) ->
        for i = 1, #Q do Q[i].polar = calculate_angle(p0, Q[i])

    -- Three points are a counter-clockwise turn
    -- if ccw > 0, clockwise if ccw < 0, and collinear if ccw = 0
    ccw = (p1, p2, p3) -> return (p2.x - p1.x) * (p3.y - p1.y) - (p2.y - p1.y) * (p3.x - p1.x)

    -- Find minimum point
    Q = table.copy(points) -- Make copy
    minIndex = minimum(Q)
    p0 = Q[minIndex]
    table.remove(Q, minIndex) -- Remove p0 from Q

    -- Sort by polar angle to p0
    calculate_polar_angles(p0, Q)
    table.sort(Q, (a, b) -> return a.polar < b.polar)

    -- Remove all with same polar angle but the farthest.
    filter_equal_angles(p0, Q)

    -- Graham scan
    S = {}
    table.insert(S, p0)
    table.insert(S, Q[1])
    table.insert(S, Q[2])

    for i = 3, #Q
        pi = Q[i]
        while (ccw(S[#S - 1], S[#S], pi) <= 0) do table.remove(S)
        table.insert(S, pi)

    for i = 1, #S do S[i].polar = nil
    return S

test_points = {
    {x: 0, y: 0}
    {x: 0, y: 20}
    {x: 20, y: 20}
    {x: 20, y: 0}
    {x: 10, y: 10}
}

make = graham_scan(test_points)
for k, v in ipairs(make) do print("{x = #{v.x}, y = #{v.y}}")