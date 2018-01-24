defmodule Peer do
  def build_tree(peers, msg, children, parent) do
    if msg == 0 do
      {peers, parent} = receive do
        { :parent, parent } ->
          peers = peers -- [DNS.my_ip_addr()]
          IO.puts ["#{inspect DNS.my_ip_addr()} > parent: " , inspect parent]

          Enum.map(peers, fn(node) ->
            send node, { :parent, self() }
          end)

          IO.puts ["#{inspect DNS.my_ip_addr()} > ", inspect parent]
          send parent, { :ack, self() }
          {peers, parent}
      end
      build_tree(peers, msg + 1, children, parent)
    else
      if msg < length(peers) - 1 do
        children = receive do
          { :ack, child } ->
            children = children ++ [child]
            IO.puts ["#{inspect DNS.my_ip_addr()} > children:", inspect children]
            children
        end
        build_tree(peers, msg + 1, children, parent)
      else
        {children, parent}
      end
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
    :timer.sleep(:timer.seconds(15))

    receive do
      {:bind, peers} ->
        IO.puts ["#{inspect DNS.my_ip_addr()} > bind"]
        {children, parent} = build_tree(peers, 0, [], nil)

        :timer.sleep(:timer.seconds(1))
        IO.puts ["#{inspect DNS.my_ip_addr()} > multicast tree built: ", inspect {parent, children}]

        :timer.sleep(:timer.seconds(1))
        total = delagate(value, children, parent)
        IO.puts ["#{inspect DNS.my_ip_addr()} > sum: ", inspect total]
    end
  end
end
