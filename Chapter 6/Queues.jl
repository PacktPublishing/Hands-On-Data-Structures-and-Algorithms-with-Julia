module Queues

export Queue, enqueue!, dequeue!, peek

include("LinkedLists.jl")
using .LinkedLists

struct Queue{T}
  list::LinkedList{T}
end

Queue(t::Type{T}) where {T} = Queue{T}(LinkedList{T}())
Queue{T}() where {T} = Queue{T}(LinkedList{T}())
Queue() = Queue{Any}(LinkedList{Any}())

function enqueue!(q::Queue{T}, elem::T) where {T}
  pushfirst!(q.list, Node(elem))
  q
end

function dequeue!(q::Queue{T}) where {T}
  isempty(q) && throw(ArgumentError("Queue must not be empty"))
  pop!(q.list).data
end

function peek(q::Queue{T}) where {T}
  isempty(q) && throw(ArgumentError("Queue must not be empty"))
  (q.list[end]).data
end

function Base.length(q::Queue{T}) where {T}
  length(q.list)
end

function Base.isempty(q::Queue{T}) where {T}
  length(q) == 0
end

function Base.empty!(q::Queue{T}) where {T}
  empty!(q.list)

  q
end

function Base.eltype(q::Queue{T}) where {T}
  eltype(q.list)
end

function Base.iterate(q::Queue{T}, state::Union{Queue,Nothing} = q) where {T}
  (state == nothing || isempty(q)) && return nothing
  dequeue!(q), q
end

end
