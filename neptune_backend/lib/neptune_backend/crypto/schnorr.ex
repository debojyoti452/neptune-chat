defmodule NeptuneBackend.Crypto.Schnorr do
  @moduledoc false

  @p 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
  @n 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141
  @gx 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798
  @gy 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8

  def verify(msg, sig, pubkey)
      when byte_size(msg) == 32 and byte_size(sig) == 64 and byte_size(pubkey) == 32 do
    r_x = :binary.decode_unsigned(binary_part(sig, 0, 32))
    s = :binary.decode_unsigned(binary_part(sig, 32, 32))
    px = :binary.decode_unsigned(pubkey)

    with true <- r_x < @p,
         true <- s < @n,
         true <- px < @p,
         {:ok, {ppx, ppy}} <- lift_x(px),
         e_hash =
           tagged_hash(
             "BIP0340/challenge",
             i2b(r_x, 32) <> i2b(ppx, 32) <> msg
           ),
         e = Integer.mod(:binary.decode_unsigned(e_hash), @n),
         {rx, ry} = point_sub(point_mul({@gx, @gy}, s), point_mul({ppx, ppy}, e)),
         true <- rx != :inf,
         true <- Integer.mod(ry, 2) == 0,
         true <- rx == r_x do
      :ok
    else
      _ -> {:error, "invalid schnorr signature"}
    end
  end

  def verify(_, _, _), do: {:error, "invalid input length"}

  defp lift_x(x) when x < @p do
    y_sq = Integer.mod(pow_mod(x, 3, @p) + 7, @p)
    y = pow_mod(y_sq, div(@p + 1, 4), @p)

    if Integer.mod(pow_mod(y, 2, @p), @p) != y_sq do
      {:error, "no curve point at x"}
    else
      y_even = if Integer.mod(y, 2) == 0, do: y, else: @p - y
      {:ok, {x, y_even}}
    end
  end

  defp lift_x(_), do: {:error, "x out of range"}

  defp point_add(:inf, q), do: q
  defp point_add(p, :inf), do: p

  defp point_add({x1, y1}, {x2, y2}) do
    cond do
      x1 == x2 and Integer.mod(y1 + y2, @p) == 0 ->
        :inf

      x1 == x2 ->
        lam = mulmod(mulmod(3, mulmod(x1, x1, @p), @p), inv(mulmod(2, y1, @p)), @p)
        double_point(x1, y1, lam)

      true ->
        lam = mulmod(submod(y2, y1), inv(submod(x2, x1)), @p)
        x3 = submod(submod(mulmod(lam, lam, @p), x1), x2)
        y3 = submod(mulmod(lam, submod(x1, x3), @p), y1)
        {x3, y3}
    end
  end

  defp double_point(x1, y1, lam) do
    x3 = submod(mulmod(lam, lam, @p), addmod(x1, x1))
    y3 = submod(mulmod(lam, submod(x1, x3), @p), y1)
    {x3, y3}
  end

  defp point_mul(point, scalar) do
    do_mul(point, scalar, :inf)
  end

  defp do_mul(_p, 0, acc), do: acc

  defp do_mul(p, n, acc) do
    acc = if rem(n, 2) == 1, do: point_add(acc, p), else: acc
    do_mul(point_add(p, p), div(n, 2), acc)
  end

  defp point_sub(p, :inf), do: p
  defp point_sub(:inf, {x, y}), do: {x, @p - y}
  defp point_sub(p, {x, y}), do: point_add(p, {x, Integer.mod(@p - y, @p)})

  defp pow_mod(base, exp, mod) do
    :crypto.mod_pow(base, exp, mod) |> :binary.decode_unsigned()
  end

  defp mulmod(a, b, m), do: Integer.mod(a * b, m)
  defp addmod(a, b, m \\ @p), do: Integer.mod(a + b, m)
  defp submod(a, b, m \\ @p), do: Integer.mod(a - b, m)
  defp inv(a, m \\ @p), do: pow_mod(a, m - 2, m)

  defp i2b(n, size) do
    b = :binary.encode_unsigned(n)
    pad_size = size - byte_size(b)
    <<0::size(pad_size * 8), b::binary>>
  end

  defp tagged_hash(tag, data) do
    tag_hash = :crypto.hash(:sha256, tag)
    :crypto.hash(:sha256, tag_hash <> tag_hash <> data)
  end
end
