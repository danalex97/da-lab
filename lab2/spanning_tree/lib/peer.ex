defmodule Peer do
  def build_tree(peers, msg, children, parent) do
    {parent, children} = receive do
      { :parent, parent } ->
        if parent == nil do
          peers = peers -- [self()]
          IO.puts ["#{inspect self()} > parent: " , inspect parent]

          Enum.map(peers, fn(node) ->
            send node, { :parent, self() }
          end)

          IO.puts ["#{inspect self()} > ", inspect parent]
          send parent, { :ack, self() }
          parent
        else
          send parent, { :nack, self() }
          parent
        end
      { :ack, child } ->
        children = children ++ [child]
        IO.puts ["#{inspect self()} > children:", inspect children]
        {parent, children}

      { :nack, child } ->
        {parent, children}
    after
      1_000 -> nil
    end

    build_tree(peers, msg + 1, children, parent)
    {parent, children}
  end

  def delagate(value, children, parent) do
    Enum.map(children, fn (child) ->
      send child, {:delagate, self()}
    end)

    value = Enum.reduce(children, value, fn (child, acc) ->
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
