# The missing proxy management CLI: _chproxy_

Most \*nix utilities support proxy environment variables, like `proxy`, `http_proxy` or `no_proxy`. However, some don't play so well, including Java tools like _gradle_ or _maven_. Switching between work :necktie: and other :tshirt: environments usually requires to change proxies and environments. While changing the `ENV` is rather simple, having it propagated to all tools is tricky.

The `chproxy` helps and currently supports changing the proxy settings for:

- :white_check_mark: gradle, with `chproxy gradle [--dry-run] [<config>]`
- :white_check_mark: maven, with `chproxy maven [--dry-run] [<config>]`
- :white_check_mark: IntelliJ (supports proxy.pac) and other JetBrains products, with `chproxy intellij [--dry-run] [<config>]`

The `chproxy` CLI works by reading the current environment proxy variables and updating the tool specific configuration.

## Installation

Make sure you have an up-to-date Ruby (at least 2.0) installed on your system and are running macOS or Linux.

### Choose your installation method:

<table width="100%" >
  <tr>
    <th width="66%"><a href="http://brew.sh">Homebrew</a></td>
    <th width="34%">Rubygems</td>
  </tr>
  <tr>
    <td width="66%" align="center">macOS</td>
    <td width="34%" align="center">macOS or Linux with<br>Ruby 2.0.0 or above</td>
  </tr>
  <tr>
    <td width="66%"><code>brew install https://raw.githubusercontent.com/lwe/chproxy/master/chproxy.rb</code></td>
    <td width="34%"><code>sudo gem install chproxy -NV -n /usr/local/bin</code></td>
  </tr>
</table>

## Usage

Best used in your shell scripts (e.g. `~/bin/proxy.sh`) to change the switch proxies:

```bash
#!/usr/bin/env bash

# Some test to check the current location.
function isWork() {
  scutil --proxy | grep ProxyAutoConfigURLString | grep --silent wpad.example.net && \
    host cache.example.net | grep --silent 'has address'
}

echo 'unset proxy {http,https,no,auto}_proxy PROXY {HTTP,HTTPS,NO,AUTO}_PROXY'

if isWork(); then
  echo 'export proxy=cache:1080'
  echo 'export {http,https}_proxy=cache:3128'
  echo 'export auto_proxy=http://cache.example.net/proxy.pac'
  echo 'export no_proxy=.local,example.net,example.org,192.168.0.0/16'
fi
echo 'chproxy gradle'
echo 'chproxy maven'
echo 'chproxy intellij'
```

...and then use like:

```bash
eval "$(./bin/proxy.sh)"
```

## Development

After checking out the repo, run `./bin/setup` to install dependencies. Then, run `./bin/rspec spec` to run the tests. You can also run `./bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `./bin/rake install`. To release a new version, update the version number in `version.rb`, and then run `./bin/rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Git Commit Messages

(From the awesome [Atom Editor](https://github.com/atom/atom/blob/master/CONTRIBUTING.md#git-commit-messages))

* Use the present tense ("Add feature" not "Added feature")
* Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
* Limit the first line to 72 characters or less
* Reference issues and pull requests liberally after the first line
* When only changing documentation, include `[ci skip]` in the commit description
* Consider starting the commit message with an applicable emoji:
    * :art: `:art:` when improving the format/structure of the code
    * :memo: `:memo:` when writing docs
    * :penguin: `:penguin:` when fixing something on Linux
    * :apple: `:apple:` when fixing something on macOS
    * :bug: `:bug:` when fixing a bug
    * :fire: `:fire:` when removing code or files
    * :green_heart: `:green_heart:` when fixing the CI build
    * :white_check_mark: `:white_check_mark:` when adding tests
    * :arrow_up: `:arrow_up:` when upgrading dependencies
    * :arrow_down: `:arrow_down:` when downgrading dependencies

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/lwe/chproxy.
