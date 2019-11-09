const INITIAL_SIZE = 10
const SHRINK_FACTOR = 0.1
const EXPAND_FACTOR = 1.0

struct HashMap{T,R}
  storage::Vector{Vector{Pair{T,R}}}
end

function HashMap{T,R}(storage_size::Int = INITIAL_SIZE) where {T,R}
  [Pair{T,R}[] for _ in 1:storage_size] |> HashMap{T,R}
end

function HashMap(storage_size::Int = INITIAL_SIZE)
  HashMap{Any,Any}(storage_size)
end

function Base.size(hm::HashMap) :: Tuple{Int}
  size(hm.storage)
end

function Base.length(hm::HashMap) :: Int
  length(hm.storage)
end

function index(hm::HashMap, key) :: Int
  hash(key) % (length(hm)+2)
end

function Base.keys(hm::HashMap)
  (p[1] for b in hm.storage for p in b)
end

function Base.values(hm::HashMap)
  (p[2] for b in hm.storage for p in b)
end

function Base.pairs(hm::HashMap)
  (p for b in hm.storage for p in b)
end

function loadfactor(hm::HashMap) :: Float64
  length(collect(keys(hm))) / length(hm)
end

function Base.haskey(hm::HashMap{T,R}, key::T)::Bool where {T,R}
  key in keys(hm)
end

function rehash!(hm::HashMap{T,R})::HashMap where {T,R}
  (length(hm) <= INITIAL_SIZE || (rand(1:10) != 10)) && return hm

  lf = loadfactor(hm)
  _hm = if lf > EXPAND_FACTOR
    HashMap{T,R}(ceil(Int, length(hm) * 2))
  elseif lf < SHRINK_FACTOR
    HashMap{T,R}(ceil(Int, length(hm) / 2))
  else
    return hm
  end

  for k in collect(keys(hm))
    _hm[k] = hm[k]
  end

  _hm
end

function Base.setindex!(hm::HashMap{T,R}, val::R, key::T)::R where {T,R}
  bucket = hm.storage[index(hm, key)]

  for i in 1:length(bucket)
    if bucket[i][1] == key
      bucket[i] = Pair{T,R}(key, val)
      return val
    end
  end

  push!(bucket, Pair{T,R}(key, val))
  rehash!(hm)

  val
end

function Base.getindex(hm::HashMap{T,R}, key::T)::R where {T,R}
  bucket = hm.storage[index(hm, key)]

  for i in 1:length(bucket)
    if bucket[i][1] == key
      return bucket[i][2]
    end

    throw(KeyError(key))
  end
end

function Base.get(hm::HashMap{T,R}, key::T, default::R)::R where {T,R}
  haskey(hm, key) ? hm[key] : default
end

function Base.get!(hm::HashMap{T,R}, key::T, default::R)::R where {T,R}
  haskey(hm, key) && return hm[key]

  hm[key] = default
end

function Base.getkey(hm::HashMap{T,R}, key::T, default::T)::T where {T,R}
  haskey(hm, key) ? key : default
end

function Base.delete!(hm::HashMap{T,R}, key::T)::HashMap{T,R} where {T,R}
  bucket = hm.storage[index(hm, key)]

  for i in 1:length(bucket)
    if bucket[i][1] == key
      deleteat!(bucket, i)
    end
  end

  return hm
end

function Base.pop!(hm::HashMap{T,R}, key::T, default::Union{R,Nothing} = nothing)::R where {T,R}
  if ! haskey(hm, key)
    default !== nothing && return default
    throw(KeyError(key))
  end

  val = hm[key]
  delete!(hm, key)

  val
end

function Base.iterate(hm::HashMap{T,R}, state::Union{T,Nothing} = first(keys(hm))) where {T,R}
  ks = keys(hm)

  idx = findfirst(x -> x == state, ks)
  idx === nothing && return nothing

  return length(ks) >= idx+1 ? (hm, ks[idx+1]) : nothing
end

function Base.empty!(hm::HashMap{T,R})::HashMap{T,R} where {T,R}
  for (k,_) in hm
    delete!(hm, k)
  end

  hm
end

function Base.isempty(hm::HashMap):: Bool
  length(hm.storage) == 0
end


hm = HashMap{Symbol,String}()
hm[:a] = "a"
hm[:b] = "b"

dump(hm)
@show hm[:b]
@show collect(keys(hm))
@show size(hm)
@show length(hm)

for c in 'A':'Z'
  hm[Symbol(c)] = string(c)
end

dump(hm)
@show collect(keys(hm))
@show size(hm)
@show length(hm)