defmodule Argon2 do
  @moduledoc """
  Elixir wrapper for the Argon2 password hashing function.

  This library can be used on its own, or it can be used together with
  [Comeonin](https://hexdocs.pm/comeonin/api-reference.html), which
  provides a higher-level api.

  Before using Argon2, you will need to configure it. Read the documentation
  for Argon2.Stats for more information about configuration. After that,
  most users will just need to use the `hash_pwd_salt/2` and `verify_pass/3`
  functions from this module.

  For a lower-level API, see Argon2.Base.

  ## Argon2

  Argon2 is the winner of the [Password Hashing Competition (PHC)](https://password-hashing.net).

  Argon2 is a memory-hard password hashing function which can be used to hash
  passwords for credential storage, key derivation, or other applications.

  Argon2 has the following three variants (Argon2i is the default):

    * Argon2d - suitable for applications with no threats from side-channel
    timing attacks (eg. cryptocurrencies)
    * Argon2i - suitable for password hashing and password-based key derivation
    * Argon2id - a hybrid of Argon2d and Argon2i

  Argon2i, Argon2d, and Argon2id are parametrized by:

    * A **time** cost, which defines the amount of computation realized and
    therefore the execution time, given in number of iterations
    * A **memory** cost, which defines the memory usage, given in kibibytes
    * A **parallelism** degree, which defines the number of parallel threads

  More information can be found in the documentation for the Argon2.Stats
  module and at the [Argon2 reference C implementation
  repository](https://github.com/P-H-C/phc-winner-argon2).

  ## Comparison with Bcrypt / Pbkdf2

  Currently, the most popular password hashing functions are Bcrypt,
  which was presented in 1999, and Pbkdf2 (pbkdf2_sha256 or pbkdf2_sha512),
  which dates back to 2000. Both are strong password hashing functions
  with no known vulnerabilities, and their algorithms have been used and
  widely reviewed for over 10 years. To help you decide whether you should
  use Argon2 instead, here is a brief comparison of Bcrypt / Pbkdf2 with
  Argon2.

  Argon2 is a lot newer, and this can be considered to be both an
  advantage and a disadvantage. On the one hand, Argon2 benefits
  from more recent research, and it is designed to combat the kinds
  of attacks which have become more common over the past decade,
  such as the use of GPUs or dedicated hardware. On the other hand,
  Argon2 has not received the same amount of scrutiny that Bcrypt / Pbkdf2
  has.

  One of the main differences is that Argon2 is a memory-hard function,
  and this means that it is designed to use a lot more memory than
  Bcrypt / Pbkdf2. With Bcrypt / Pbkdf2, attackers can use GPUs to hash
  several hundred / thousand passwords in parallel. This can result in
  significant gains in the time it takes an attacker to crack passwords.
  Argon2's memory cost means that it is a lot more difficult for attackers
  to benefit from using GPUs or other dedicated hardware.
  """

  use Comeonin

  alias Argon2.Base

  @doc """
  Generate a random salt.

  The default length for the salt is 16 bytes. We do not recommend using
  a salt shorter than the default.
  """
  def gen_salt(salt_len \\ 16), do: :crypto.strong_rand_bytes(salt_len)

  @doc """
  MOVE THESE DOCS TO moduledoc?
  Generate a random salt and hash a password using Argon2.

  ## Options

  For more information about the options for the underlying hash function,
  see the documentation for Argon2.Base.hash_password/3.

  This function has the following additional option:

    * `:salt_len` - the length of the random salt
      * the default is 16 (the minimum is 8) bytes
      * we do not recommend using a salt less than 16 bytes long

  ## Examples

  The following example changes the default `t_cost` and `m_cost`:

      Argon2.hash_pwd_salt("password", [t_cost: 8, m_cost: 20])

  In the example below, the Argon2 type is changed to Argon2id:

      Argon2.hash_pwd_salt("password", [argon2_type: 2])

  To use Argon2d, use `argon2_type: 0`.
  """
  @impl true
  def hash_pwd_salt(password, opts \\ []) do
    Base.hash_password(password, Keyword.get(opts, :salt_len, 16) |> gen_salt, opts)
  end

  @impl true
  def verify_pass(password, stored_hash) do
    hash = :binary.bin_to_list(stored_hash)

    case Base.verify_nif(hash, password, argon2_type(stored_hash)) do
      0 -> true
      _ -> false
    end
  end

  defp argon2_type("$argon2id" <> _), do: 2
  defp argon2_type("$argon2i" <> _), do: 1
  defp argon2_type("$argon2d" <> _), do: 0

  defp argon2_type(_) do
    raise ArgumentError,
          "Invalid Argon2 hash. " <> "Please check the 'stored_hash' input to verify_pass."
  end
end
