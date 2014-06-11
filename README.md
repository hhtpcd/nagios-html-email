Opsview HTML Email Template
---------------------------

Generate HTML emails for Opsview service and host alerts.
This is a forked version of the nagios-html-email nodejs script with amendments for Opsview.

Instead of choosing service vs hosts notification method in commands.cfg, service or host check is determined by the existence of the env variable passed to the notification script, ```NAGIOS_SERVICEATTEMPT``` which should be null for host checks.

Opsview
-------

Opsview is based on Nagios however notifications and configuration is handled differently. Opsview has done away with the .cfg files and all the configuration takes place in the web interface. Any changes that get made to the .cfg files will mostly get overwritten.

The installation into the commands.cfg, or misccommands.cfg for Opsview gets overwritten on a reload. For the nagios installation instructions please see [Voxer/nagios-html-email](https://github.com/voxer/nagios-html-template) on Github.

The modifications I have made will stop this working with Nagios.

Tested on Opsview Core 3.20131016.0.14175-1precise1 on Ubuntu 12.04 LTS as of 2014-06-10.

Installation
------------

Generate HTML emails for Opsview service and host alerts

- [Quick Start Guide](#quick-start-guide)
- [Screenshots](#screenshots)
- [Advanced Usage](#advanced-usage)
    - [Custom Subject](#custom-subject)
    - [Alleviation Steps](#alleviation-steps)
- [Custom Templates](#custom-templates)
    - [Rendering](#rendering)
    - [Testing](#testing)
- [Common Problems](#common-problems)
- [License](#license)

Quick Start Guide
-----------------

Requires nodejs and npm. Install with your package manager. Below is for Ubuntu

``` bash
$ ~ sudo apt-get update; sudo apt-get install nodejs npm
```

Install this package on your opsview server

``` bash
$ ~ sudo npm install -g opsview-html-email
```

Check that the nagios-html-email script is in the path of the nagios user.

``` bash
$ ~ which opsview-html-email
/usr/bin/opsview-html-email
```
In `/usr/local/nagios/libexec/notifications` create a symlink to the script

``` bash
$ ~ ln -s /usr/bin/opsview-html-email /usr/local/nagios/libexec/notifications/opsview-html-email
```
You can now test this from the command line, but first you will need to export some environment variables for the script to use. This is only for testing. See the Testing section below for better testing.

``` bash
export NAGIOS_HOSTALIAS="test server alias"
export NAGIOS_CONTACTEMAIL="your.email@domain"
export NAGIOS_NOTIFICATIONTYPE='WARNING'
export NAGIOS_SERVICEDESC='CPU Utilisation'
export NAGIOS_HOSTADDRESS='prod1-database.domain'
export NAGIOS_SERVICESTATE='SKY IS FALLING'
export NAGIOS_SERVICEDURATION='15'
export NAGIOS_SERVICEOUTPUT='CPU is 678%'
export NAGIOS_LONGDATETIME='2014-06-10 15:39'
```
Now you can run
``` bash
$ ~ opsview-html-email your-opsview-host.domain | sendmail -t
```
You may have to change sendmail for the mail daemon configured on your server. You can also not pipe to sendmail to see the raw HTML output.

Now in your Opsview web interface, add a new Notification method. Name it whatever suits and add the command as
``` opsview-html-email your-opsview-server.domain | sendmail -t```

You should be able to add your new notification method to existing or new notification profiles and start generating HTML emails from Opsview. I added mine alongside existing notification methods in case it didn't work so I still recieved alerts.

Have a look at the troubleshooting section if your emails come through as just JSON or raise an issue.

Screenshots
-----------
**I have updated the templates slightly so they will appear different to the screenshots here. Only slightly though.**

A critical service

<p><img src="screenshots/service-critical.png" alt="Critical Service" style="border: 2px solid black;" /></p>

The service recovery, threaded because the subject is the same

<p><img src="screenshots/service-recovery-thread.png" alt="Service Recovery Threaded" style="border: 2px solid black;" /></p>

Host recovery

<p><img src="screenshots/host-recovery.png" alt="Host Recovery" style="border: 2px solid black;" /></p>

Advanced Usage
--------------

I have skipped the advanced usage step for now as I haven't found out if it works with Opsview yet. Will add in later following some testing!

Custom Templates
----------------

By default, this program will use builtin templates for host and service
alerts.  You can use your own templates by supplying `-t <dir>` to point to a
directory with your templates.

See [templates/](templates) to see the builtin templates.

### Rendering

Templates are rendered using [EJS](https://github.com/visionmedia/ejs), and
have these variables available for you to use.

- `nagios`: this object contains all of the Nagios variables found as
  environmental variables.  For example, `nagios.CONTACTEMAIL`,
  `nagios.HOSTSTATE`, etc.  Any variable you could access as a macro like
  `$MACRONAME$` will be avaliable as `nagios.MACRONAME`.
- `args`: this array contains all of the command line arguments after the type
  argument.  For instance, if the program is invoked as `nagios-html-email -t
  /etc/templates -s subject service foo bar baz` the array will be set to
  `['foo', 'bar', 'baz']`.
- `package`: `package.json` from this module as an object; this can be used
   to get information like `package.version`, etc.

A custom template dir, if you supply one, should contain at least a
`host.html.ejs` and `service.html.ejs` file for host and service alerts
respectively.

Common Problems
---------------

### No emails are being generated

Most likely, the path with `nagios-html-email` in it is not in the `PATH`
variable for the Nagios server.  Ensure the path given by `which
nagios-html-email` is in the PATH of the Nagios server.

### I'm getting emailed, but it is a JSON stringified version of the Nagios variables

This means that a template failed to render.  Instead of failing
to send an email, this program will do everything it can to make sure you
get an email, even if it isn't pretty.

### I'm trying to do numerical analysis on values but it isn't working

Since variables are passed as either command line arguments or
environmental variables, all variables are of type `String`.  You
must expliticly cast any values you know to be numbers, booleans,
dates, etc. to their correct data type.

### I've disabled environmental variables for performance reasons

**Not sure if this works with Opsview. Haven't tested or found a need for this in my server. **

You can still use this program, just pass the variables you would like to
use as command line arguments, and access them in your template as
`args[0]`, `args[1]`, etc.  For example:


``` bash
define command {
    command_name notify-service-by-email
    command_line nagios-html-email -s "** $NOTIFICATIONTYPE$ Service Alert: $HOSTALIAS$/$SERVICEDESC$ is $SERVICESTATE$ **" -a $CONTACTEMAIL$ service | mailx -t
}
```

However, from experience, passing environmental variables won't cause too much
of a performance penality. I'd recommend turning it on for a bit to see how it
affects your latency before turning off such an amazing feature.

License
-------

MIT
