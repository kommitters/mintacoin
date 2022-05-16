defmodule Mintacoin.Minters.MinterTest do
  use Mintacoin.DataCase

  alias Mintacoin.Minters.Minter

  describe "registration_changeset/3" do
    test "requires email and password to be set" do
      changeset = Minter.registration_changeset(%Minter{}, %{})

      assert %{
               password: ["can't be blank"],
               email: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates email and password when given" do
      changeset =
        Minter.registration_changeset(%Minter{}, %{
          email: "not valid",
          password: "not valid"
        })

      assert %{
               email: ["must have the @ sign and no spaces"],
               password: ["should be at least 12 character(s)"]
             } = errors_on(changeset)
    end

    test "validates maximum values for email and password for security" do
      too_long = String.duplicate("db", 100)
      changeset = Minter.registration_changeset(%Minter{}, %{email: too_long, password: too_long})
      assert "should be at most 160 character(s)" in errors_on(changeset).email
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "returns a valid changeset" do
      changeset =
        Minter.registration_changeset(%Minter{}, %{
          email: "test@example.com",
          password: "secretpassword"
        })

      assert changeset.valid?
    end
  end

  describe "email_changeset/2" do
    test "validates email changes" do
      changeset =
        Minter.email_changeset(%Minter{email: "test@example.com"}, %{email: "test@example.com"})

      assert %{email: ["did not change"]} = errors_on(changeset)
    end

    test "validates email to be set" do
      changeset = Minter.email_changeset(%Minter{email: "test@example.com"}, %{email: ""})

      assert %{email: ["did not change", "can't be blank"]} = errors_on(changeset)
    end

    test "validates email format" do
      changeset =
        Minter.email_changeset(%Minter{email: "test@example.com"}, %{email: "not valid"})

      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "validates email length" do
      too_long = String.duplicate("db", 100)
      changeset = Minter.email_changeset(%Minter{email: "test@example.com"}, %{email: too_long})

      assert "should be at most 160 character(s)" in errors_on(changeset).email
    end

    test "returns a valid changeset" do
      changeset =
        Minter.email_changeset(%Minter{email: "test@example.com"}, %{email: "testing@example.com"})

      assert changeset.valid?
    end
  end

  describe "password_changeset/3" do
    test "validates password changes" do
      changeset =
        Minter.password_changeset(%Minter{}, %{password: "secretpassword"}, hash_password: false)

      assert changeset.valid?
      assert get_change(changeset, :password) == "secretpassword"
      assert is_nil(get_change(changeset, :hashed_password))
    end

    test "validates the match and length of passwords" do
      changeset =
        Minter.password_changeset(%Minter{}, %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end
  end

  describe "confirm_changeset/1" do
    test "confirms a minter" do
      changeset = Minter.confirm_changeset(%Minter{})
      refute is_nil(get_change(changeset, :confirmed_at))
    end
  end

  describe "valid_password?/2" do
    test "returns true if the password is correct" do
      assert Minter.valid_password?(
               %Minter{hashed_password: Bcrypt.hash_pwd_salt("secretpassword")},
               "secretpassword"
             )
    end

    test "returns false if the password is incorrect" do
      refute Minter.valid_password?(
               %Minter{hashed_password: Bcrypt.hash_pwd_salt("secretpassword")},
               "wrongpassword"
             )
    end
  end

  describe "validate_current_password/2" do
    test "returns a valid changeset if password is correct" do
      changeset =
        Ecto.Changeset.change(%Minter{hashed_password: Bcrypt.hash_pwd_salt("secretpassword")})

      changeset = Minter.validate_current_password(changeset, "secretpassword")

      assert changeset.valid?
    end

    test "returns an invalid changeset if password is incorrect" do
      changeset =
        Ecto.Changeset.change(%Minter{hashed_password: Bcrypt.hash_pwd_salt("secretpassword")})

      changeset = Minter.validate_current_password(changeset, "wrongpassword")

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
      refute changeset.valid?
    end
  end
end
