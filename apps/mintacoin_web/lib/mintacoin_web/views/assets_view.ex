defmodule MintacoinWeb.AssetsView do
  use MintacoinWeb, :view
  alias MintacoinWeb.AssetsView

  @spec render(template :: String.t(), assigns :: map()) :: map()
  def render("index.json", %{assets: assets}) do
    render_many(assets, AssetsView, "asset.json", as: :asset)
  end

  def render("asset.json", %{asset: asset}) do
    %{
      resource: "asset",
      code: asset.code,
      supply: asset.supply,
      minter_id: asset.minter_id,
      blockchain_id: asset.blockchain_id
    }
  end
end
