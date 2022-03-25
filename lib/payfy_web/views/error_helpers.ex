defmodule PayfyWeb.ErrorHelpers do
  @moduledoc """
  Conveniences for translating and building error messages.
  """

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate "is invalid" in the "errors" domain
    #     dgettext("errors", "is invalid")
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    # This requires us to call the Gettext module passing our gettext
    # backend as first argument.
    #
    # Note we use the "errors" domain, which means translations
    # should be written to the errors.po file. The :count option is
    # set by Ecto and indicates we should also apply plural rules.
    if count = opts[:count] do
      Gettext.dngettext(PayfyWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(PayfyWeb.Gettext, "errors", msg, opts)
    end
  end

  def translate_errors(changeset) do
    for result_error <- changeset.errors do
      {field_name, ecto_error} = result_error
      {_error_message, ecto_validation} = ecto_error
      [ecto_validation_message | _ecto_validation_tail] = ecto_validation
      ecto_validation_message = Kernel.inspect(ecto_validation_message)

      Jason.encode!(%{
        error: "invalid field value",
        field: %{field_name: field_name, error_message: ecto_validation_message}
      })
    end
  end
end
