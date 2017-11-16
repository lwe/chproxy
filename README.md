# The missing proxy management CLI: _chproxy_

`chproxy` is an opinionated tool to switch between multiple proxy settings. In addition providing
support for tools that do not work with proxy environment variables, like `proxy`, `http_proxy` or
`no_proxy`. Switching between work :necktie: and other :tshirt: environments usually requires to
change proxies and environments. While changing the `ENV` is rather simple, having it propagated to
all tools is tricky.

## Installation

Make sure you have an up-to-date Ruby (at least 2.0) installed on your system and are running macOS
or Linux.

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

1. Create a file called `~/.chproxy`, this file is sourced from the `chpup` alias, an example script
   could be as follows:
   ```bash
   #!/bin/bash

   # macOS command to check for an auto-configured proxy
   function isWork() {
     scutil --proxy | grep ProxyAutoConfigURLString | grep --silent wpad.example.net && \
       host cache.example.net | grep --silent 'has address'     
   }
   if isWork; then
     export proxy="cache:1080"
     export {http,https}_proxy="cache:3128"
     export no_proxy="example.net,example.org"
     echo "Using: 👔"
   fi
   ```

2. Add the following to your `.bashrc` or `.zshrc` to enable the `chpup` alias with the gradle and
   maven plugins. This also runs `chpup` directly.
   ```bash
   eval "$(chproxy init - gradle maven npm intellij:AndroidStudio)"
   ```

3. In addition, when switching networks, run `chpup` anytime. And, yeah in all your open shells.

## Support

The `chproxy` helps and currently supports changing the proxy settings for:

- :white_check_mark: gradle, with `chproxy gradle [--dry-run] [<config>]`
- :white_check_mark: maven, with `chproxy maven [--dry-run] [<config>]`
- :white_check_mark: npm/yarn, with `chproxy npm [--dry-run] [<config>]`
- :white_check_mark: IntelliJ (supports proxy.pac) and other JetBrains products, with `chproxy intellij [--dry-run] [<config>]`

The `chproxy [tool]` CLI works by reading the current environment proxy variables and updating the
tool specific configuration.

## Development

After checking out the repo, run `./bin/setup` to install dependencies. Then, run `./bin/rspec spec`
to run the tests. You can also run `./bin/console` for an interactive prompt that will allow you to
experiment.

To install this gem onto your local machine, run `./bin/rake install`. To release a new version,
update the version number in `version.rb`, and then run `./bin/rake release`, which will create a
git tag for the version, push git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

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
