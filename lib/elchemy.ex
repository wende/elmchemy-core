defmodule ElchemyHack do
  defmacro __before_compile__(_env) do
    module = __CALLER__.module
    verifies = Macro.escape(Module.get_attribute(module, :verify_type))
    quote do
      def __type_tests__ do
        unquote(verifies)
      end
    end
  end
end

defmodule Elchemy do
  defmacro __using__(_) do
    quote do
      Module.register_attribute(__MODULE__, :verify_type, accumulate: true)
      @before_compile ElchemyHack

      require Elchemy
      require Elchemy.Glue

      import Elchemy
      import Kernel, except: [{:"++", 2}]
      import Elchemy.Glue
      import Kernel, except: [
        {:'++', 2}
      ]

      alias Elchemy.{
        XBasics,
        XList,
        XString,
        XDebug,
        XMaybe,
        XChar,
        XTuple,
        XResult
      }
      import_std()
    end
  end

  @std [
    Elchemy.XBasics,
    Elchemy.XList,
    Elchemy.XString,
    Elchemy.XMaybe,
    Elchemy.XDebug,
    Elchemy.XChar,
    Elchemy.XTuple,
    Elchemy.XResult
    ]
  defmacro import_std() do
    if Enum.member?(@std, __CALLER__.module) do
      quote do
        :ok
      end
    else
      quote do
        import Elchemy.XBasics
        import Elchemy.XList, only: [{:cons, 0}]
        # Rest contains no functions
        # import Maybe exposing ( Maybe( Just, Nothing ) )
        # import Result exposing ( Result( Ok, Err ) )
        # import String
        # import Tuple
        # import Debug
      end
    end
  end
end
