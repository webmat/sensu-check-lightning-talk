## Lightning talk about creating a Sensu check

1. Basic shell check / explain the API

Nagios check-compatible (so you can reuse those)

Exit codes:
0: ok
1: warning
2: critical
3+: unknown

Output one line of text describing the situation.


2. Writing a check in Ruby for more niceties

```bash
gem install sensu-plugin
# where gem is /opt/sensu/embedded/bin/gem
```

```ruby
class MyCheck < Sensu::Plugin::Check::CLI
```

Your class has to define `run()` and declare the command-line parameters.


Class definition:
option(...)

Will be held in the instance method `config`, which returns a hash.

```ruby
class MyCheck < Sensu::Plugin::Check::CLI
  option :warn,
    :short => '-w WARN',
    :default => 80

  option :crit,
    :short => '-c CRIT',
    :default => 100

  def run
    # ...
  end
end
```

This `option` helper lets you define

- short and long argument names `-v` or `--version`
- adding a description for the CLI help output
- required arguments
- argument types (default is string, but supports integer, boolean)
- a proc to run on the argument (commonly used to call .to_f)

This helper is provided by the gem `mixlib-cli`:
https://github.com/opscode/mixlib-cli.

Inside `run`, the process is a bit procedural.

You run one or more commands to observe the state this script should watch.

```ruby
disk_free = `df`
```

You parse it

```ruby
disk_free.split(/\s+/)
...
```

You set the message

```ruby
message("Disk usage is #{ x }")
```

Then you set the exit code

```ruby
if x >= options[:crit]
  critical
elsif x < options[:crit] && x > options[:warn]
  warning
else
  ok
end
```

That's it.



2.1. Test the check manually

3. Have Sensu run the check

On monitored servers: `/etc/sensu/plugins/checks/my_check.rb`

The JSON config for it isn't magic (doesn't add a missing `.rb` or other such things)
The `command` key is actually a whole shell command. With params and maybe even
an interpreter. Here are examples:

```JSON
"command": "my_check.rb" // The Ruby script is executable, run it with default params

"command": "ruby my_check.rb" // The Ruby script is not executable

"command": "my_check.rb --warn 42 --crit 99" // Tweak some parameters

"command": "python another_check.py" // We're a Python shop and custon scripts are in Python

"command": "bash_check.sh" // The lowest common denominator simplifies my life

"command": "..." // Could be a 200 char Perl one liner, for all Sensu cares!
```

4. Creating a "metric" check

Another very important kind of check, with a few differences.

Returns more than one line, in Graphite format

```
# sensu.system.disk.lolcats.free   9000    1383246228
# sensu.system.disk.root.free   42    1383246229
```

Is identified as a metric check to Sensu in its config:

```JSON
"type": "metric",
"command": "cpu-usage-metrics.sh",
```

If using Ruby to build your check, there's a specific helper for it.

```ruby
class MyMetric < Sensu::Plugin::Metric::CLI::Graphite
  ...
  def run
    ...
    output(name, value, timestamp)
    ok # Still have to say that everything is fine / on fire
  end
end
```

5. Plugins are shared

Tons of plugins available open source

https://github.com/sensu/sensu-community-plugins/

5.1. As you can see, there's tons of plugins you can reuse and contribute,
  but the same goes for handlers and mutators as well.


### Resources

- Sensu: http://sensuapp.org/
- Plugins: https://github.com/sensu/sensu-community-plugins/
- `option`: http://rubydoc.info/gems/mixlib-cli/1.3.0/frames
- `option`: https://github.com/opscode/mixlib-cli
