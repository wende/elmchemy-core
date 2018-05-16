defmodule Elchemy.Format do
  import Kernel, except: [inspect: 1, inspect: 2]

  @moduledoc """
    Module for inspecting a string representation of data structures according to Elchemy syntax instead of Elixir syntax
  """

  @spec inspect(term()) :: String.t()
  def inspect(term, in_type \\ false)

  @doc "When term is map"
  def inspect(term, _) when is_map(term) do
    case Map.to_list(term) do
      [] ->
        "Dict.fromList []"

      [{key, _value} | _] when is_atom(key) ->
        inner =
          term
          |> Enum.map(fn {key, value} ->
            to_string(key) <> " = " <> inspect(value)
          end)

        "{ " <> Enum.join(inner, ", ") <> " }"

      [{_key, _value} | _] ->
        inner =
          term
          |> Enum.map(fn {key, value} ->
            inspect(key) <> " = " <> inspect(value)
          end)

        "Dict.fromList [{ " <> Enum.join(inner, ", ") <> " }]"
    end
  end

  def inspect(term, in_type) when is_tuple(term) do
    [head | rest] = term |> Tuple.to_list()

    if is_atom(head) do
      type = head |> Atom.to_string() |> Macro.camelize
      args = rest |> Enum.map(&inspect(&1, true)) |> Enum.join(" ")

      if in_type do
        ["(", type, " ", args, ")"]
      else
        [type, " ", args]
      end |> Enum.join()

    else
      inner = term |> Tuple.to_list() |> Enum.map(&inspect/1)
      "(" <> Enum.join(inner, ", ") <> ")"
    end
  end

  def inspect(term, _) when is_list(term) do
    inner =
      term
      |> Enum.map(fn x -> inspect(x) end)
      |> Enum.join(", ")

    "[" <> inner <> "]"
  end

  def inspect(x, _) when is_atom(x), do: Atom.to_string(x) |> String.capitalize()
  def inspect(x, _), do: to_string(x)
end
