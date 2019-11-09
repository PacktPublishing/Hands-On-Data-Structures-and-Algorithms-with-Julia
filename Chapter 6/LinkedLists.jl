module LinkedLists

export LinkedList, Node

mutable struct Node{T}
  data::T
  next::Union{Node{T},Nothing}
end

function Node(data::T) where {T}
    Node(data, nothing)
end

mutable struct LinkedList{T}
    head::Union{Node{T},Nothing}
    tail::Union{Node{T},Nothing}
end

LinkedList{T}() where {T} = LinkedList{T}(nothing, nothing)
LinkedList() = LinkedList{Any}(nothing, nothing)

function get_testlist(start::Int, finish::Int)
    head = current = Node(start)

    for i in (start+1):finish
        node = Node(i)
        current.next = node
        current = node
    end

    tail = current

    LinkedList(head, tail)
end

function Base.iterate(list::LinkedList, state::Union{Node,Nothing} = list.head)
    (state == nothing || list.head == nothing) && return nothing
    (state, state.next)
end

Base.eltype(::Type{LinkedList{T}}) where T = Node{T}

function Base.length(list::LinkedList)
    count = 0

    for _ in list
        count += 1
    end

    count
end

function Base.getindex(list::LinkedList, index::Int)
    count = 1

    for node in list
        count == index && return node
        count += 1
    end

    throw(BoundsError("$(count-1) element LinkedList", index))
end

function Base.firstindex(list::LinkedList)
   1
end

function Base.lastindex(list::LinkedList)
   length(list)
end

function Base.setindex!(list::LinkedList{T}, node::Node{T}, index::Int) where {T}
    (index > lastindex(list) || index < firstindex(list)) &&
        throw(BoundsError("$(length(list)) element LinkedList", index))

    if index < lastindex(list)
        node.next = list[index+1]
    else
        node.next = nothing
        list.tail = node
    end

    if index > firstindex(list)
        list[index-1].next = node
    else
        list.head = node
    end
end

Base.show(io::IO, node::Node{T}) where {T} = print(io, "[$(node.data)::$(T)]→")

function Base.show(io::IO, list::LinkedList{T}) where {T}
    print(io, "LinkedList::$(T)")
    isempty(list) || print(io, " ")
    for node in list
        print(io, "[$(node.data)]→")
    end
end

function Base.push!(list::LinkedList{T}, nodes::Vararg{Node{T}}) where {T}
    head_node = current = nodes[1]

    for (index, node) in enumerate(nodes)
        index == 1 && continue
        current.next = node
        current = node
    end
    list[end].next = head_node
    list.tail = head_node

    list
end

function withnodes(nodes::Vararg{Node{T}}) where {T}
    head_node = current = nodes[1]

    for (index, node) in enumerate(nodes)
        index == 1 && continue
        current.next = node
        current = node
    end

    LinkedList(head_node, current)
end

import Base: +

function (+)(l1::LinkedList{T}, l2::LinkedList{T}) where {T}
    _l1 = deepcopy(l1)
    _l2 = deepcopy(l2)

    isempty(_l1) && return _l2
    isempty(_l2) && return _l1

    _l1[end].next = _l2[1]
    _l1.tail = _l2.tail

    _l1
end

function Base.hash(list::LinkedList)
    h = ""

    for node in list
        h *= string(node.data)
    end

    hash(h)
end

import Base.==

function ==(l1::LinkedList{T}, l2::LinkedList{T}) where {T}
  hash(l1) == hash(l2)
end

function push(list::LinkedList{T}, nodes::Vararg{Node{T}}) where {T}
    list + withnodes(nodes...)
end

function Base.push!(list::LinkedList{T}, nodes::Vararg{Node{T}}) where {T}
    list[end].next = withnodes(nodes...)[1]
    list
end

function pushfirst(list::LinkedList{T}, nodes::Vararg{Node{T}}) where {T}
    withnodes(nodes...) + list
end

function Base.pushfirst!(list::LinkedList{T}, nodes::Vararg{Node{T}}) where {T}
    list.head = (withnodes(nodes...) + list)[1]
    list
end

function Base.insert!(list::LinkedList{T}, pos::Int, nodes::Vararg{Node{T}}) where {T}
    (pos < 1 || pos > length(list)) &&
        throw(BoundsError("$(length(list)) element LinkedList", pos))

    nodes_list = withnodes(nodes...)

    if pos < length(list)
        nodes_list[end].next = list[pos]
    end
    if pos > 1
        list[pos-1].next = nodes_list[1]
    else
        list.head = nodes_list[1]
    end
    if pos == length(list)
      list[pos].next = nodes_list[1]
      list.tail = nodes_list.tail
    end

    list
end

function Base.pop!(list::LinkedList)
    last_node = list[end]

    if length(list) == 1
      list.head = nothing
      list.tail = nothing
    else
      list[end-1].next = nothing
      list.tail = list[end]
    end

    last_node
end

function Base.popfirst!(list::LinkedList)
    first_node = list[1]
    list.head = first_node.next
    first_node.next = nothing
    first_node
end

function Base.delete!(list::LinkedList{T}, remove_node::Node{T}) where {T}
    for (index, node) in enumerate(list)
        node == remove_node || continue

        if index > 1 && index < length(list)
            list[index-1].next = list[index+1]
        elseif index == 1 && index < length(list)
            list.head = list[index+1]
        elseif index > 1 && index == length(list)
            list[index-1].next = nothing
            list.tail = list[index-1]
        end

        return node
    end
end

function Base.deleteat!(list::LinkedList, index::Int) where {T}
    delete!(list, list[index])
end

function Base.empty!(list::LinkedList)
    list.head = nothing

    list
end

function Base.reverse(list::LinkedList)
    _list = deepcopy(list)
    last_node = _list[end]
    first_node = _list.head

    for index in length(_list):-1:1
        if index == 1
            _list[1].next = nothing
            break
        end

        _list[index].next = _list[index-1]
    end
    _list.head = last_node
    _list.tail = first_node

    _list
end

end
