defmodule LiveLoggerTest do
  use ExUnit.Case
  doctest LiveLogger

  test "greets the world" do
    assert LiveLogger.hello() == :world
  end
end
