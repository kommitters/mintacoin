defmodule Mintacoin.Crypto.Stellar.Assets do
  @moduledoc """
  This module provides functions for creating and managing assets in the Stellar network.
  """

  def create(_params) do
    {:ok,
     %Stellar.Horizon.Transaction{
       created_at: ~U[2022-06-30 17:04:10Z],
       envelope_xdr:
         "AAAAAgAAAAA1g28UW2dCMYtvD0hVfw7+ZM8SjnB/HzQq7lGIRlLuiwAAAMgAAc5vAAAACgAAAAAAAAAAAAAAAgAAAAEAAAAA+fH4yEJYQaYVgfdNLTgOt7+C2VSBors4/+9C6+KUZz0AAAAGAAAAAU1USwAAAAAANYNvFFtnQjGLbw9IVX8O/mTPEo5wfx80Ku5RiEZS7ot//////////wAAAAEAAAAANYNvFFtnQjGLbw9IVX8O/mTPEo5wfx80Ku5RiEZS7osAAAABAAAAAPnx+MhCWEGmFYH3TS04Dre/gtlUgaK7OP/vQuvilGc9AAAAAU1USwAAAAAANYNvFFtnQjGLbw9IVX8O/mTPEo5wfx80Ku5RiEZS7osAAAkYTnKgAAAAAAAAAAACRlLuiwAAAEC2abYb0wynN8CPzUJzVQr9koQAxmK4+4VPkvk91xVONGwSECQ6UwxWJiLBl60lq4LatPbiht7cXB8oXs4nhCUI4pRnPQAAAEBH5SXfAGNgiGeQ0GXvV0XpH13cS9IVjTou45AYM91cnBLwK1Mi1vPKpCgVeVAHeHbHOogbOboLNCPavL38IroA",
       fee_charged: 200,
       fee_meta_xdr:
         "AAAAAgAAAAMAAeK5AAAAAAAAAAA1g28UW2dCMYtvD0hVfw7+ZM8SjnB/HzQq7lGIRlLuiwAAABc4XwNsAAHObwAAAAkAAAABAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAIAAAAAAAAAAAAAAAAAAAADAAAAAAAB4rkAAAAAYrzZXQAAAAAAAAABAAITIwAAAAAAAAAANYNvFFtnQjGLbw9IVX8O/mTPEo5wfx80Ku5RiEZS7osAAAAXOF8CpAABzm8AAAAJAAAAAQAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAACAAAAAAAAAAAAAAAAAAAAAwAAAAAAAeK5AAAAAGK82V0AAAAA",
       hash: "3378da751d34b5abb6ce233b6a8dd905c461c6c21a813c1d825cd8bc64c38815",
       id: "3378da751d34b5abb6ce233b6a8dd905c461c6c21a813c1d825cd8bc64c38815",
       ledger: 135_971,
       max_fee: 200,
       memo: nil,
       memo_type: "none",
       operation_count: 2,
       paging_token: "583990998208512",
       result_meta_xdr:
         "AAAAAgAAAAIAAAADAAITIwAAAAAAAAAANYNvFFtnQjGLbw9IVX8O/mTPEo5wfx80Ku5RiEZS7osAAAAXOF8CpAABzm8AAAAJAAAAAQAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAACAAAAAAAAAAAAAAAAAAAAAwAAAAAAAeK5AAAAAGK82V0AAAAAAAAAAQACEyMAAAAAAAAAADWDbxRbZ0Ixi28PSFV/Dv5kzxKOcH8fNCruUYhGUu6LAAAAFzhfAqQAAc5vAAAACgAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAMAAAAAAAITIwAAAABivdeKAAAAAAAAAAIAAAACAAAAAwACD7UAAAABAAAAAPnx+MhCWEGmFYH3TS04Dre/gtlUgaK7OP/vQuvilGc9AAAAAU1USwAAAAAANYNvFFtnQjGLbw9IVX8O/mTPEo5wfx80Ku5RiEZS7osAAASC16JWgAAACRhOcqAAAAAAAQAAAAAAAAAAAAAAAQACEyMAAAABAAAAAPnx+MhCWEGmFYH3TS04Dre/gtlUgaK7OP/vQuvilGc9AAAAAU1USwAAAAAANYNvFFtnQjGLbw9IVX8O/mTPEo5wfx80Ku5RiEZS7osAAASC16JWgH//////////AAAAAQAAAAAAAAAAAAAAAgAAAAMAAhMjAAAAAQAAAAD58fjIQlhBphWB900tOA63v4LZVIGiuzj/70Lr4pRnPQAAAAFNVEsAAAAAADWDbxRbZ0Ixi28PSFV/Dv5kzxKOcH8fNCruUYhGUu6LAAAEgteiVoB//////////wAAAAEAAAAAAAAAAAAAAAEAAhMjAAAAAQAAAAD58fjIQlhBphWB900tOA63v4LZVIGiuzj/70Lr4pRnPQAAAAFNVEsAAAAAADWDbxRbZ0Ixi28PSFV/Dv5kzxKOcH8fNCruUYhGUu6LAAANmyYU9oB//////////wAAAAEAAAAAAAAAAAAAAAA=",
       result_xdr: "AAAAAAAAAMgAAAAAAAAAAgAAAAAAAAAGAAAAAAAAAAAAAAABAAAAAAAAAAA=",
       signatures: [
         "tmm2G9MMpzfAj81Cc1UK/ZKEAMZiuPuFT5L5PdcVTjRsEhAkOlMMViYiwZetJauC2rT24obe3FwfKF7OJ4QlCA==",
         "R+Ul3wBjYIhnkNBl71dF6R9d3EvSFY06LuOQGDPdXJwS8CtTItbzyqQoFXlQB3h2xzqIGzm6CzQj2ry9/CK6AA=="
       ],
       source_account: "GA2YG3YULNTUEMMLN4HUQVL7B37GJTYSRZYH6HZUFLXFDCCGKLXIXMDT",
       source_account_sequence: 508_451_113_402_378,
       successful: true,
       valid_after: nil,
       valid_before: nil
     }}
  end

  def authorize(_params) do
    {:ok,
     %Stellar.Horizon.Transaction{
       created_at: ~U[2022-06-30 16:57:55Z],
       envelope_xdr:
         "AAAAAgAAAAD0TmCowAdQZfNEJayTp5/8IFzEYVL1zjguPDIlWU331gAAAGQAAhLHAAAAAQAAAAAAAAAAAAAAAQAAAAAAAAAGAAAAAU1USwAAAAAANYNvFFtnQjGLbw9IVX8O/mTPEo5wfx80Ku5RiEZS7ot//////////wAAAAAAAAABWU331gAAAEC/MisnMeYpoeP271pX5HvRmTJVoJaxww1d7CZPgvlppFyenEYyIpv8sYcZsoFMdrfyJA0k2WVWTcpyHbVKaMEH",
       fee_charged: 100,
       fee_meta_xdr:
         "AAAAAgAAAAMAAhLHAAAAAAAAAAD0TmCowAdQZfNEJayTp5/8IFzEYVL1zjguPDIlWU331gAAABdIdugAAAISxwAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAhLcAAAAAAAAAAD0TmCowAdQZfNEJayTp5/8IFzEYVL1zjguPDIlWU331gAAABdIduecAAISxwAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==",
       hash: "6984326ac947fba61ab4a702e12b5550eb44f0b9811ce05889b66fe9f9fbe822",
       id: "6984326ac947fba61ab4a702e12b5550eb44f0b9811ce05889b66fe9f9fbe822",
       ledger: 135_900,
       max_fee: 100,
       memo: nil,
       memo_type: "none",
       operation_count: 1,
       paging_token: "583686055534592",
       result_meta_xdr:
         "AAAAAgAAAAIAAAADAAIS3AAAAAAAAAAA9E5gqMAHUGXzRCWsk6ef/CBcxGFS9c44LjwyJVlN99YAAAAXSHbnnAACEscAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAABAAIS3AAAAAAAAAAA9E5gqMAHUGXzRCWsk6ef/CBcxGFS9c44LjwyJVlN99YAAAAXSHbnnAACEscAAAABAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAACAAAAAAAAAAAAAAAAAAAAAwAAAAAAAhLcAAAAAGK91hMAAAAAAAAAAQAAAAMAAAAAAAIS3AAAAAEAAAAA9E5gqMAHUGXzRCWsk6ef/CBcxGFS9c44LjwyJVlN99YAAAABTVRLAAAAAAA1g28UW2dCMYtvD0hVfw7+ZM8SjnB/HzQq7lGIRlLuiwAAAAAAAAAAf/////////8AAAABAAAAAAAAAAAAAAADAAIS3AAAAAAAAAAA9E5gqMAHUGXzRCWsk6ef/CBcxGFS9c44LjwyJVlN99YAAAAXSHbnnAACEscAAAABAAAAAAAAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAACAAAAAAAAAAAAAAAAAAAAAwAAAAAAAhLcAAAAAGK91hMAAAAAAAAAAQACEtwAAAAAAAAAAPROYKjAB1Bl80QlrJOnn/wgXMRhUvXOOC48MiVZTffWAAAAF0h255wAAhLHAAAAAQAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAgAAAAAAAAAAAAAAAAAAAAMAAAAAAAIS3AAAAABivdYTAAAAAAAAAAA=",
       result_xdr: "AAAAAAAAAGQAAAAAAAAAAQAAAAAAAAAGAAAAAAAAAAA=",
       signatures: [
         "vzIrJzHmKaHj9u9aV+R70ZkyVaCWscMNXewmT4L5aaRcnpxGMiKb/LGHGbKBTHa38iQNJNllVk3Kch21SmjBBw=="
       ],
       source_account: "GD2E4YFIYADVAZPTIQS2ZE5HT76CAXGEMFJPLTRYFY6DEJKZJX35MJJE",
       source_account_sequence: 583_595_861_213_185,
       successful: true,
       valid_after: nil,
       valid_before: nil
     }}
  end
end
