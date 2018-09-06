# IntervalSets.jl currently has deprecation warnings on Julia 0.7

export Interval, .., exclude, Exclude

"""
    Interval(start, stop)

Construct a closed interval, which is a collection which contains (via `in`) elements
between `start` and `stop` (inclusive) according to `isless`. The collection is abstract
in nature and doesn't support iteration, indexing, etc.

Can be constructed via the `..` function, e.g. `1..3 === Interval(1, 3)`.

# Examples

```julia
julia> 2 in Interval(1, 3)
true

julia> 3 in Interval(1, 3)
true

julia> 4 in Interval(1, 3)
false
"""
struct Interval{T1, T2}
    start::T1
    stop::T2
end

"""
    ..(start, stop)
    start..stop

Constructs an `Interval(start, stop)`, which represents the closed interval between `start`
and `stop`. `Interval`s are abstract collections which support `in` but not iteration,
indexing, etc.

To exclude either endpoint from the `Interval`, use the `exclude` function.

# Examples

```julia
julia> 2 in 1..3
true

julia> 3 in 1..3
true

julia> 4 in 1..3
false

julia> 3 in 1..exclude(3)
false
"""
..(start::T1, stop::T2) where {T1, T2} = Interval{T1, T2}(start, stop)

function Base.in(x, interval::Interval)
    return isgreaterequal(x, interval.start) && islessequal(x, interval.stop)
end

function Base.:(==)(i1::Interval, i2::Interval)
    (isequal(i1.start, i2.start) && isequal(i1.stop, i2.stop)) || (isless(i1.stop, i1.start) && isless(i2.stop, i2.start))
end

function Base.isequal(i1::Interval, i2::Interval)
    isequal(i1.start, i2.start) && isequal(i1.stop, i2.stop)
end

function Base.isless(i1::Interval, i2::Interval)
    isless(i1.start, i2.start) || (isequal(i1.start, i2.start) && isless(i1.stop, i2.stop))
end

Base.hash(interval::Interval, h::UInt) = hash(interval.start, hash(interval.stop, hash(UInt === UInt64 ? 0x0c3a059de789f681 : 0x0c88d4c5, h)))

function Base.show(io::IO, interval::Interval)
    print(io, interval.start)
    print(io, "..")
    print(io, interval.stop)
end

struct Exclude{T}
    value::T
end

function Base.show(io::IO, x::Exclude)
    print(io, "exclude(")
    print(io, x.value)
    print(io, ")")
end

"""
    exclude(x)

Return a value which excludes itself from `isequal` comparison but otherwise preserves order
with respect to `isless`.

Amongst other uses, this may be used to create `Interval`s the exclude the end points.

# Examples

```julua
julia> isequal(10, exclude(10))
false

julia> isless(9, exclude(10))
true

julia> 10 ∈ 0..10
true

julia> 10 ∈ 0..exclude(10)
false
```
"""
function exclude(x)
    Exclude{typeof(x)}(x)
end

Base.isequal(x::Exclude, y::Exclude) = isequal(x.value, y.value)
Base.isequal(x::Exclude, y) = false
Base.isequal(x, y::Exclude) = false
Base.isequal(x::Exclude, y::Missing) = false
Base.isequal(x::Missing, y::Exclude) = false

Base.isless(x::Exclude, y::Exclude) = isless(x.value, y.value)
Base.isless(x::Exclude, y) = isless(x.value, y)
Base.isless(x, y::Exclude) = isless(x, y.value)
Base.isless(x::Exclude, y::Missing) = true
Base.isless(x::Missing, y::Exclude) = false

Base.hash(x::Exclude, h::UInt) = hash(x.value, hash(UInt === UInt64 ? 0x1f61aad02a1ec08b : 0xd6318b8a, h))