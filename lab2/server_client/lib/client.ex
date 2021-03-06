defmodule Client do

  def random_sleep do
    sleep_time = Enum.random(1..3)
    :timer.sleep(:timer.seconds(sleep_time))
  end

  def interact(server) do
    random_sleep()

    query_type = Enum.random([:circle, :square])

    send server, { query_type, self(), 1.0 }

    receive do
    { :result, area } ->
      IO.puts "Client #{inspect self()} > Area is #{area}"
    end

    interact(server)
  end

  def start do
    IO.puts "Client #{inspect self()} > Started.."

    receive do
      { :bind, server } ->
        IO.puts ["Client #{inspect self()} > ", inspect server]
        send server, { :bind, self() }

        interact(server)
    end
  end

end # module -----------------------
