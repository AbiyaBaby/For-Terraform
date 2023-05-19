terraform {
  required_version = "~> 1.3.1"
  required_providers {
    newrelic = {
      source = "newrelic/newrelic"  
    }
  }
}
provider  "newrelic" {
    alias = "newrelic"
    account_id = 3826874
    api_key = "NRAK-QWL46LQ9BDJ7L8P8M04MF9PR66P"
    region = "US"
}
resource "newrelic_alert_policy" "my_alert_policy_name" {
    name = "My FoodMe Alert Policy"
}

data "newrelic_application" "app_name" {
  name = "FoodMe"
}

resource "newrelic_alert_condition" "alert_condition_two" {
  policy_id = newrelic_alert_policy.my_alert_policy_name.id 
  name = "My FoodMe Alert Condition Two"
  entities = [data.newrelic_application.app_name.id]
  metric = "error_percentage"
  type = "apm_app_metric"
  condition_scope = "application"
  term { 
    duration = 7
    operator = "above"
    priority ="critical"
    threshold = "0.75"
    time_function = "all"
  }
}

resource "newrelic_notification_destination" "email" {
  account_id = 3826874
  name = "email-example"
  type = "EMAIL"

  property {
    key = "email"
    value = "abiya@litmus7.com"
  }
}
resource "newrelic_notification_channel" "email" {
  account_id = 3826874
  name = "email-example"
  type = "EMAIL"
  destination_id = newrelic_notification_destination.email.id
  product = "IINT"

  property {
    key = "subject"
    value = "New Subject Title"
  }
}

resource "newrelic_workflow" "workflow-example" {
  name = "workflow-example"
  muting_rules_handling = "NOTIFY_ALL_ISSUES"

  issues_filter {
    name = "Filter-name"
    type = "FILTER"

    predicate {
      attribute = "labels.policyIds"
      operator = "EXACTLY_MATCHES"
      values = [ newrelic_alert_policy.my_alert_policy_name.id ]
    }
  }

  destination {
    channel_id = newrelic_notification_channel.email.id
  }
}


resource "newrelic_alert_policy" "my_second_alert_policy_name" {
    name = "My FoodMe Second Alert Policy"
}
resource "newrelic_alert_condition" "alert_condition_foodme" {
  policy_id = newrelic_alert_policy.my_second_alert_policy_name.id 
  name = "My FoodMe Alert Condition"
  entities = [data.newrelic_application.app_name.id]
  metric = "throughput_web"
  type = "apm_app_metric"
  condition_scope = "application"
  term { 
    duration = 5
    operator = "below"
    priority ="critical"
    threshold = "0.75"
    time_function = "all"
  }
}

resource "newrelic_notification_destination" "email2" {
  account_id = 3826874
  name = "email-example2"
  type = "EMAIL"

  property {
    key = "email"
    value = "aparna@litmus7.com"
  }
}
 resource "newrelic_notification_channel" "email2" {
  account_id = 3826874
  name = "email-example2"
  type = "EMAIL"
  destination_id = newrelic_notification_destination.email2.id
  product = "IINT"

  property {
    key = "subject"
    value = "New Subject Title"
  }
}
resource "newrelic_workflow" "next_workflow" {
  name = "next_workflow"
  muting_rules_handling = "NOTIFY_ALL_ISSUES"

  issues_filter {
    name = "Filter-name"
    type = "FILTER"

    predicate {
      attribute = "labels.policyIds"
      operator = "EXACTLY_MATCHES"
      values = [ newrelic_alert_policy.my_second_alert_policy_name.id ]
    }
  }
  destination {
    channel_id = newrelic_notification_channel.email2.id
  }
}
