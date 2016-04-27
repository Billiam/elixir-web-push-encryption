defmodule WebPushEncryption.Crypto do
  @callback generate_key(atom, atom) :: {binary, binary}
  @callback rand_bytes(non_neg_integer) :: binary

  def generate_key(type, params) do
    impl.generate_key(type, params)
  end

  def rand_bytes(bytes_num) do
    impl.rand_bytes(bytes_num)
  end

  defp impl do
    Application.get_env(:web_push_encryption, :crypto_impl) || :crypto
  end
end
