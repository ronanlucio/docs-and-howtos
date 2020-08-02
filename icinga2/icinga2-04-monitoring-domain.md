# Monitoring Domain Expiration on Icinga2

## Install Plugin

First, you'll have to install the check_domain_expiration plugin.

To do this, just down load the bash script below and save it as **/usr/lib/nagios/plugin/check_domain_expiration.sh**

https://github.com/ewypych/icinga-domain-expiration-plugin/blob/master/check_domain_expiration.sh


## Configure CheckCommand on Icinga2

Edit or create the file **/etc/icinga2/zones.d/master/commands.conf** and ad the snippet below:

```
# Here is the example of the command configuration.
# You can create your own or use the following example.

object CheckCommand "check_domain_expiration" {
        import "plugin-check-command"

        command = [ PluginDir + "/check_domain_expiration.sh" ]

        arguments = {
        "-d" = { value = "$domain_check$" }
        "-s" = { value = "$domain_server$" }
        "-w" = { value = "$domain_warning$" }
        "-c" = { value = "$domain_critical$" }
	}

	vars.domain_server = "auto"
	vars.domain_warning = 45
	vars.domain_critical = 14
}
```


## Apply a Service template

Add the snippet below into your file **/etc/icinga2/zones.d/master/services.conf**

```
// Domain Expiration Check
apply Service "Domain Expiration" {
  check_command = "check_domain_expiration"

  vars.slack_notifications = "enabled"

  assign where host.vars.domain_check
}
```


## Configure your domains to be monitored

Create a file **/etc/icinga2/zones.d/master/domain.conf** and add the snippet below for each domain you want to monitor.

Note that you can also monitor http availability for the same host.

```
object Host "mydomain.com" {
  check_command = "dummy"
  vars.dummy_state = 0 // UP
  vars.dummy_text = "OK"

  // check_http
  vars.http_vhosts["http"] = {
    http_address = "mydomain.com"
    http_vhost = "mydomain.com"
    http_uri = "/"
  }
  vars.http_vhosts["www"] = {
    http_address = "www.mydomain.com"
    http_vhost = "www.mydomain.com"
    http_uri = "/"
  }

  // check_domain_expiration
  vars.domain_check = name

  // notifications
  vars.slack_notifications = "enabled"
}
```