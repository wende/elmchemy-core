defmodule Elmchemy.Glue do

  def try_catch() do
    fn func ->
      try do
        {:ok, func.(nil)}
      rescue
        e -> {:error, e.message}
      end
    end
  end


  defmacro curry({:/, _, [{name, _, _}, arity]}) do
    args =
      1..arity |> Enum.map(&({:"arg#{&1}", [], Elixir}))

    define_curried(:def, name, args)
  end

  defmacro curryp({:/, _, [{name, _, _}, arity]}) do
    args =
      1..arity |> Enum.map(&({:"arg#{&1}", [], Elixir}))

    define_curried(:defp, name, args)
  end

  defmacro defcurry(definition, _opts \\ [], do: body) do
    {fun, args} = Macro.decompose_call(definition)
    quote do
      unquote(define_curried(:def, fun, args))
      def unquote(fun)(unquote_splicing(args)) do
        unquote(body)
      end
    end
  end

  defmacro defcurryp(definition, _opts \\ [], do: body) do
    {fun, args} = Macro.decompose_call(definition)
    quote do
      unquote(define_curried(:defp, fun, args))
      defp unquote(fun)(unquote_splicing(args)) do
        unquote(body)
      end
    end
  end

  defp define_curried(:def, name, args) do
    quote do
      def unquote(name)() do
        unquote(do_curry(name, args))
      end
    end
  end
  defp define_curried(:defp, name, args) do
    quote do
      defp unquote(name)() do
        unquote(do_curry(name, args))
      end
    end
  end

  defp do_curry(fun, args), do: do_curry(fun, args, args)
  defp do_curry(fun, [h | args], all) do
    quote do fn unquote(h) -> unquote(do_curry(fun, args, all)) end end
  end
  defp do_curry(fun, [], args) do
    quote do: unquote(fun)(unquote_splicing(args))
  end

  ## TYPE CHECKING
  defmacro verify(as: {:/, _, [{call, _, []}, arity1]}) do
    {mod, function} = case call do
      {:., _, [{:__aliases__, _, mods}, fun]} ->
        mod = Module.concat(mods)
        {mod, fun}
      {:., _, [mod, fun]} ->
        {mod, fun}
    end
    quote do
      spec_ast = Module.get_attribute(__MODULE__, :spec) |> hd |> elem(1)
      {{:spec, {fun1, _}, spec}, _line} = Kernel.Typespec.translate_spec(:spec, spec_ast, __ENV__)
      orig = Elmchemy.Spec.find(unquote(mod), unquote(function), unquote(arity1))
      Elmchemy.Spec.compare!({{unquote(function), unquote(arity1)}, [spec]}, orig, __MODULE__, unquote(mod))
    end
  end
end
