variable "organization_map" {
  type = map
  default = {
    root = {

      ou-vrbz-sb5wzrsg = [
        092184108996, 
        081556044659, 
        865876543607
      ]

      ou-vrbz-ugxa0808 = [
        912786606823
      ]

      no-ou = [
        791529083252,
        019659989168,
        004507715063,
        310935373214,
        373407869938,
        698827576654
      ]
    }
  }
}

variable "business_unit_1" {
  type = map
  default = {
    target_ou = "ou-vrbz-sb5wzrsg",
    preferred_alert_channel = ""
  }
}

variable "business_unit_2" {
  type = map
  default = {
    target_ou = "ou-vrbz-ugxa0808",
    preferred_alert_channel = ""
  }
}
