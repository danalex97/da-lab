defmodule SpanTree do
  @num 10

  def bind(peers, idx, neigh) do
    send Enum.at(peers, idx), { :bind, Enum.to_list(
      for i <- neigh, do: Enum.at(peers, i)
    )}
  end

  def build_network(peers) do
    bind(peers, 0, [1, 6])
    bind(peers, 1, [0, 2, 3])
    bind(peers, 2, [1, 3, 4])
    bind(peers, 3, [1, 2, 5])
    bind(peers, 4, [2])
    bind(peers, 5, [3])
    bind(peers, 6, [0, 7])
    bind(peers, 7, [6, 8, 9])
    bind(peers, 8, [7, 9])
    bind(peers, 9, [7, 8])
  end

  def loop do
    loop()
  end

  ##### for Docker ###################
  def main_net do
    :timer.sleep(:timer.seconds(10))

    peers = Enum.to_list(for idx <- 0..(@num-1), do:
      Node.spawn(
        :'peer#{idx}@peer#{idx}.localdomain',
        Peer,
        :start,
        [Enum.random(1..5)]))

    build_network(peers)

    send Enum.at(peers, 0), { :parent, self() }

    loop()
  end
  #####################################
end
