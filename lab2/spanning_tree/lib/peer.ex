defmodule Peer do
  def build_tree(peers, msg, children, acks, parent) do
    {parent, children, acks} = receive do
      { :parent, rec_parent } ->
        if parent == nil do
          IO.puts ["#{inspect self()} > parent: " , inspect rec_parent]

          Enum.map(peers -- [self()], fn(node) ->
            send node, { :parent, self() }
          end)

          send rec_parent, { :ack, self() }
          {rec_parent, children, acks}
        else
          send rec_parent, { :nack, self() }
          {parent, children, acks}
        end
      { :ack, child } ->
        children = children ++ [child]
        IO.puts ["#{inspect self()} > children:", inspect children]
        {parent, children, acks + 1}

      { :nack, _child } ->
        {parent, children, acks + 1}
        #IO.puts ["#{inspect self()} > nack from ", inspect child]

    after
      10_000 ->
        {parent, children, acks}
    end

    # IO.puts length(peers)
    # IO.puts inspect acks
    if acks < length(peers) do
      build_tree(peers, msg + 1, children, acks, parent)
    else
      {parent, children, acks}
    end
  end

  def delagate(value, children, parent) do
    Enum.map(children, fn (child) ->
      send child, {:delagate, self()}
    end)

    value = Enum.reduce(children, value, fn (_child, acc) ->
      receive do
        {:accumulate, value} ->
          acc + value
      end
    end)

    send parent, {:accumulate, value}
    value
  end

  #           114
  #         /     \
  #      120      115
  #     /        /   \
  #    121      116  117
  #   /   \     |     |
  # 122   123  118   119

  def start(value) do
    receive do
      {:bind, peers} ->
        IO.puts ["#{inspect self()} > bind"]
        {parent, children, _} = build_tree(peers, 0, [], 0, nil)

        :timer.sleep(:timer.seconds(10))
        IO.puts ["#{inspect self()} > multicast tree built: ", inspect {parent, children}]

        :timer.sleep(:timer.seconds(1))
        total = delagate(value, children, parent)
        IO.puts ["#{inspect self()} > sum: ", inspect total]
    end
  end
end
