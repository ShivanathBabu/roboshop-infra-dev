variable "components" {
  default = {
      catalogue = {
        component = "catalogue"
        rule_priority = 10
    }
    
    user = {
        component = "user"
        rule_priority = 20
    }
    cart = {
        component = "cart"
        rule_priority = 30
    }

      shipping = {
        component = "shipping"
        rule_priority = 40
    }

      payment = {
        component = "payment"
        rule_priority = 50
    }

      frontend = {
        component = "cart"
        rule_priority = 10
    }
  }
}