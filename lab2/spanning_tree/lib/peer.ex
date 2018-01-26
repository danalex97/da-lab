defmodule Peer do
  def build_tree(peers, msg, children, parent) do
    {parent, children} = receive do
      { :parent, rec_parent } ->
        if parent == nil do
          IO.puts ["#{inspect self()} > parent: " , inspect rec_parent]

          Enum.map(peers -- [self()], fn(node) ->
            send node, { :parent, self() }
          end)

          send rec_parent, { :ack, self() }
          {rec_parent, children}
        else
          send rec_parent, { :nack, self() }
          {parent, children}
        end
      { :ack, child } ->
        children = children ++ [child]
        IO.puts ["#{inspect self()} > children:", inspect children]
        {parent, children}

      { :nack, _child } ->
        {parent, children}
    after
      1_000 ->
        {parent, children}
    end

    build_tree(peers, msg + 1, children, parent)
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
        {parent, children} = build_tree(peers, 0, [], nil)

        :timer.sleep(:timer.seconds(1))
        IO.puts ["#{inspect self()} > multicast tree built: ", inspect {parent, children}]

        :timer.sleep(:timer.seconds(1))
        total = delagate(value, children, parent)
        IO.puts ["#{inspect self()} > sum: ", inspect total]
    end
  end
end
