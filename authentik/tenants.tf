resource "authentik_tenant" "lama-corp" {
  domain = "lama-corp.space"

  branding_title   = "Lama Corp."
  branding_logo    = "https://lama-corp.space/llama.png"
  branding_favicon = "https://lama-corp.space/llama.png"

  event_retention = "days=365"
}
