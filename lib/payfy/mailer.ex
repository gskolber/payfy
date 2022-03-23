defmodule Payfy.Mailer do
  @moduledoc """
  Mailer is a module that sends emails.
  """
  use Swoosh.Mailer, otp_app: :payfy
end
