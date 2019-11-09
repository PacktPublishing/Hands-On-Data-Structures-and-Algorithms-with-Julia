module Stacks

export Stack, StackUnderflowException, StackOverflowException
export peek, isfull

struct Stack{T}
  data::Vector{T}
  size::Int

  Stack{T}(data::Vector{T}, size::Int) where {T} = begin
    length(data) > size && throw(StackOverflowException("The length of the data exceeds the size of the stack"))
    size < 0 && throw(StackUnderflowException("The size of the stack can not be negative"))

    new(data, size)
  end
end

struct StackUnderflowException <: Exception
  msg
end

struct StackOverflowException <: Exception
  msg
end

Stack(data::Vector{T}, size::Int) where {T} = Stack{T}(data, size)
Stack(data::Vector{T}) where {T} = Stack{T}(data, length(data))

Stack(itr, size) where {T} = Stack{eltype(itr)}([itr...], size)
Stack(itr) where {T} = Stack{eltype(itr)}([itr...], length(itr))

# Stack(t::Type{T}, size::Int) where {T} = Stack{T}(Vector{T}(undef, size), size)

function Base.push!(s::Stack{T}, elems::Vararg{T}) where {T}
  length(s.data) + length(elems) > s.size && throw(StackOverflowException("Pushing $elems exceeds the size of the stack"))
  push!(s.data, elems...)

  s
end

function Base.pop!(s::Stack{T}) where {T}
  length(s.data) > 0 || throw(StackUnderflowException("Stack can not be empty"))

  pop!(s.data)
end

function peek(s::Stack{T}) where {T}
  length(s.data) > 0 || throw(StackUnderflowException("Stack can not be empty"))

  s.data[end]
end

function Base.isempty(s::Stack{T}) where {T}
  isempty(s.data)
end

function Base.length(s::Stack{T}) where {T}
  length(s.data)
end

function Base.size(s::Stack{T}) where {T}
  s.size
end

function isfull(s::Stack{T}) where {T}
  length(s) == size(s)
end

function Base.empty!(s::Stack{T}) where{T}
  empty!(s.data)
  s
end

function Base.iterate(s::Stack{T}, state::Union{Stack,Nothing} = s) where {T}
  (state === nothing || isempty(s)) && return nothing
  pop!(s), s
end

function Base.Array(s::Stack{T}) where {T}
  s.data |> reverse
end

function Base.eltype(s::Stack{T}) where {T}
  eltype(s.data)
end

end
