env = {}

car = (list) -> list[0]
cdr = (list) -> list[1]
caar = (list) -> car(car(list))
cadar = (list) -> car(cdr(car(list)))
atom = (x) -> !(x instanceof Array or x is undefined)
eq = (x, y) -> return (x is y) if atom(x) and atom(y)
equal = (x, y) -> 
    ((atom(x) and atom(y) and eq(x, y)) or
    (!atom(x) and !atom(y) and equal(car(x), car(y)) and equal(cdr(x), cdr(y))))
nil = (x) -> atom(x) and eq(x, null)
undef = (x) -> x is undefined
none = (x) -> nil(x) or undef(x)
lambda = (xs, fn) ->
cons = (x, y) ->
    y = null if undef(y)
    y = [y] unless !atom(y) and nil(y)
    y.unshift(x)
    y
list = (x, y...) -> 
    if y.length is 0 then cons(x) 
    else cons(x, list.apply(null, y))
ff = (x) -> if atom(x) then x else ff(car(x))
subst = (x, y, z) -> 
    if atom(z)
        if eq(z, y) then x else z
    else
        cons(subst(x, y, car(z)), subst(x, y, cdr(z)))
append = (x, y) ->
    if nil(x) then y
    else cons(car(x), append(cdr(x), y))
among = (x, y) -> !nil(x) and (equal(x, car(y)) or equal(x, cdr(y)))
pair = (x, y) ->
    if nil(x) and nil(y)
        return null
    if !atom(x) and !atom(y)
        return cons(list(car(x), car(y)), pair(cdr(x), cdr(y)))
assoc = (x, y) ->
    if eq(caar(y), x) then cadar(y)
    else assoc(x, cdr(y))
sub2 = (x, z) ->
    if nil(x)
        return z
    if eq(caar(x), z)
        return cadar(x)
    sub2(cdr(x), z)
sublis = (x, y) ->
    if atom(y) then sub2(x, y)
    else
        cons(sublis(x, car(y)), sublis(x, cdr(y)))
    
# Testing Microframework

_tests = []
_fails = 0
expect = (a) -> 
    a: a
    to: (b) ->
        if (undef(a) and undef(b)) or equal(a, b)
            _tests.push(true)
        else
            _tests.push(false)
            console.log "Test(#{_tests.length}) failed: (#{a})[#{b}]"
            _fails = _fails + 1
            
results = ->
    console.log "Passed: #{_tests.length - _fails}/#{_tests.length}"
    if _fails is 0 then console.log "All passed!"
    
# Tests

one = 1
two = 2
shell = cons(1, cons(2, cons(3)))
expect(shell).to [1, [2, [3, null]]]
expect(car(shell)).to 1
expect(cdr(shell)).to [2, [3, null]]
expect(atom(shell)).to false
expect(atom(one)).to true
expect(eq(one, one)).to true
expect(eq(one, two)).to false
expect(eq(one, shell)).to undefined
expect(equal(shell, shell)).to true
expect(equal(one, one)).to true
expect(nil(cdr(cons(1)))).to true
expect(ff(cons(cons(1, cons(2, null)), cons(3, null)))).to 1
expect(subst(4, 2, shell)).to [1, [4, [3, null]]]
expect(list(1, 2, 3)).to [1, [2, [3, null]]]
expect(append(list(1,2),list(3, 4))).to [1, [2, [3, [4, null]]]]
expect(among(1, list(1,2,3))).to true
expect(pair(list(1,2), list(3,4))).to [[1, [3, null]], [[2, [4, null]], null]]
expect(assoc("b", list(list("a", 1), list("b", 2), list("c", 3)))).to 2
expect(sublis(list(list("a", 1), list("b", 2)), list("a", "b"))).to list(1, 2)

results()