defmodule Emailer do 
  defmacro __using__(config) do 
    quote do
      def send_email(to, from, subject, body) do 
        Emailer.send_email(unquote(config), to, from, subject, body)
      end
    end
  end

  def send_email(config, to, from, subject, _body) do 
    host = Keyword.fetch!(config, :host)
    user = Keyword.fetch!(config, :username)
    pass = Keyword.fetch!(config, :password)

    :gen_smtp_client.send({to, [from], subject}, [
      relay: host,
      username: user,
      password: pass
    ])
  end
end

