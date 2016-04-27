defmodule WebPushEncryption.Push do
  @moduledoc """
  Module to send web push notifications with a payload through GCM
  """

  @gcm_url "https://android.googleapis.com/gcm/send"
  @temp_gcm_url "https://gcm-http.googleapis.com/gcm"

  @doc """
  Sends a web push notification with a payload through GCM.

  ## Arguments

    * `message` is a binary payload. It can be JSON encoded
    * `subscription` is the subscription information received from the client.
       It should have the following form: `%{keys: %{auth: AUTH, p256dh: P256DH}, endpoint: ENDPOIONT}`
    * `auth_token` is the GCM api key matching the `gcm_sender_id` from the client `manifest.json`

  ## Return value

  Returns the result of `HTTPoison.post`
  """
  @spec send_web_push(message :: binary, subscription :: map, auth_token :: binary) :: {:ok, any} | {:error, atom}
  def send_web_push(message, subscription, auth_token)
  def send_web_push(_message, _subscription, nil) do
    raise ArgumentError, "send_web_push requires an auth_token"
  end
  def send_web_push(message, %{endpoint: endpoint} = subscription, auth_token) do
    endpoint = String.replace(endpoint, @gcm_url, @temp_gcm_url)

    payload = WebPushEncryption.Encrypt.encrypt(message, subscription)
    headers = [
      {"Content-Encoding", "aesgcm"},
      {"Encryption", "salt=#{ub64(payload.salt)}"},
      {"Crypto-Key", "dh=#{ub64(payload.server_public_key)}"},
      {"Authorization", "key=#{auth_token}"}
    ]
    HTTPoison.post(endpoint, payload.ciphertext, headers)
  end
  def send_web_push(_message, _subscription, _auth_token) do
    raise ArgumentError, "send_web_push expects a subscription endpoint with an endpoint parameter"
  end

  defp ub64(value) do
    Base.url_encode64(value, padding: false)
  end
end
