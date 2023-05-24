# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v3.0.0](https://github.com/voxpupuli/puppet-ldapquery/tree/v3.0.0) (2023-05-24)

[Full Changelog](https://github.com/voxpupuli/puppet-ldapquery/compare/v2.1.0...v3.0.0)

**Breaking changes:**

- Drop Puppet 6 support [\#41](https://github.com/voxpupuli/puppet-ldapquery/pull/41) ([bastelfreak](https://github.com/bastelfreak))

**Implemented enhancements:**

- Rename `Net::LDAP::LdapError` to `Net::LDAP::Error` [\#38](https://github.com/voxpupuli/puppet-ldapquery/pull/38) ([smortex](https://github.com/smortex))

**Fixed bugs:**

- uninitialized constant `Net::LDAP::LdapError` [\#43](https://github.com/voxpupuli/puppet-ldapquery/issues/43)
- Do explicit string conversion on values too [\#35](https://github.com/voxpupuli/puppet-ldapquery/pull/35) ([arjenz](https://github.com/arjenz))

**Closed issues:**

- Convert to modern function API and namespace [\#44](https://github.com/voxpupuli/puppet-ldapquery/issues/44)
- no such file to load -- net/ldap  [\#37](https://github.com/voxpupuli/puppet-ldapquery/issues/37)

**Merged pull requests:**

- Convert function to modern API, refactor and namespace [\#45](https://github.com/voxpupuli/puppet-ldapquery/pull/45) ([alexjfisher](https://github.com/alexjfisher))

## [v2.1.0](https://github.com/voxpupuli/puppet-ldapquery/tree/v2.1.0) (2021-06-25)

[Full Changelog](https://github.com/voxpupuli/puppet-ldapquery/compare/v2.0.0...v2.1.0)

**Implemented enhancements:**

- Put options for ldapquery into opts argument [\#29](https://github.com/voxpupuli/puppet-ldapquery/pull/29) ([treydock](https://github.com/treydock))

## [v2.0.0](https://github.com/voxpupuli/puppet-ldapquery/tree/v2.0.0) (2021-06-15)

[Full Changelog](https://github.com/voxpupuli/puppet-ldapquery/compare/1.0.3...v2.0.0)

**Breaking changes:**

- Drop EoL puppet 5 support; add Puppet 7 [\#26](https://github.com/voxpupuli/puppet-ldapquery/pull/26) ([bastelfreak](https://github.com/bastelfreak))

**Merged pull requests:**

- cleanup metadata.json [\#25](https://github.com/voxpupuli/puppet-ldapquery/pull/25) ([bastelfreak](https://github.com/bastelfreak))
- Declare support for Puppet 5 & 6 [\#24](https://github.com/voxpupuli/puppet-ldapquery/pull/24) ([ekohl](https://github.com/ekohl))
- modulesync 3.0.0 [\#21](https://github.com/voxpupuli/puppet-ldapquery/pull/21) ([bastelfreak](https://github.com/bastelfreak))
- Ca file optional [\#20](https://github.com/voxpupuli/puppet-ldapquery/pull/20) ([Wiston999](https://github.com/Wiston999))
- Update from xaque208 modulesync\_config [\#17](https://github.com/voxpupuli/puppet-ldapquery/pull/17) ([zachfi](https://github.com/zachfi))
- Update from xaque208 modulesync\_config [\#16](https://github.com/voxpupuli/puppet-ldapquery/pull/16) ([zachfi](https://github.com/zachfi))

## [1.0.3](https://github.com/voxpupuli/puppet-ldapquery/tree/1.0.3) (2019-02-27)

[Full Changelog](https://github.com/voxpupuli/puppet-ldapquery/compare/1.0.1...1.0.3)

## [1.0.1](https://github.com/voxpupuli/puppet-ldapquery/tree/1.0.1) (2019-02-06)

[Full Changelog](https://github.com/voxpupuli/puppet-ldapquery/compare/1.0.0...1.0.1)

**Merged pull requests:**

- Update Readme with some hints on the setup [\#14](https://github.com/voxpupuli/puppet-ldapquery/pull/14) ([cbergmann](https://github.com/cbergmann))

## [1.0.0](https://github.com/voxpupuli/puppet-ldapquery/tree/1.0.0) (2018-06-03)

[Full Changelog](https://github.com/voxpupuli/puppet-ldapquery/compare/0.5.1...1.0.0)

**Merged pull requests:**

- Update from xaque208 modulesync\_config [\#13](https://github.com/voxpupuli/puppet-ldapquery/pull/13) ([zachfi](https://github.com/zachfi))
- Update requirements for net-ldap due to CVE-2017-17718 [\#12](https://github.com/voxpupuli/puppet-ldapquery/pull/12) ([zachfi](https://github.com/zachfi))

## [0.5.1](https://github.com/voxpupuli/puppet-ldapquery/tree/0.5.1) (2018-02-10)

[Full Changelog](https://github.com/voxpupuli/puppet-ldapquery/compare/0.5.0...0.5.1)

## [0.5.0](https://github.com/voxpupuli/puppet-ldapquery/tree/0.5.0) (2018-02-10)

[Full Changelog](https://github.com/voxpupuli/puppet-ldapquery/compare/0.4.1...0.5.0)

**Closed issues:**

- no such file to load -- net/ldap [\#10](https://github.com/voxpupuli/puppet-ldapquery/issues/10)

## [0.4.1](https://github.com/voxpupuli/puppet-ldapquery/tree/0.4.1) (2017-03-11)

[Full Changelog](https://github.com/voxpupuli/puppet-ldapquery/compare/0.4.0...0.4.1)

## [0.4.0](https://github.com/voxpupuli/puppet-ldapquery/tree/0.4.0) (2017-02-20)

[Full Changelog](https://github.com/voxpupuli/puppet-ldapquery/compare/0.3.1...0.4.0)

**Merged pull requests:**

- modulesync 2017-02-07 [\#9](https://github.com/voxpupuli/puppet-ldapquery/pull/9) ([zachfi](https://github.com/zachfi))

## [0.3.1](https://github.com/voxpupuli/puppet-ldapquery/tree/0.3.1) (2016-05-18)

[Full Changelog](https://github.com/voxpupuli/puppet-ldapquery/compare/0.3.0...0.3.1)

## [0.3.0](https://github.com/voxpupuli/puppet-ldapquery/tree/0.3.0) (2016-05-16)

[Full Changelog](https://github.com/voxpupuli/puppet-ldapquery/compare/0.2.1...0.3.0)

**Merged pull requests:**

- Add support for scoped queries [\#8](https://github.com/voxpupuli/puppet-ldapquery/pull/8) ([zachfi](https://github.com/zachfi))

## [0.2.1](https://github.com/voxpupuli/puppet-ldapquery/tree/0.2.1) (2016-04-04)

[Full Changelog](https://github.com/voxpupuli/puppet-ldapquery/compare/0.2.0...0.2.1)

## [0.2.0](https://github.com/voxpupuli/puppet-ldapquery/tree/0.2.0) (2016-03-23)

[Full Changelog](https://github.com/voxpupuli/puppet-ldapquery/compare/0.1.8...0.2.0)

**Merged pull requests:**

- Always return an array for the values [\#7](https://github.com/voxpupuli/puppet-ldapquery/pull/7) ([zachfi](https://github.com/zachfi))

## [0.1.8](https://github.com/voxpupuli/puppet-ldapquery/tree/0.1.8) (2016-03-13)

[Full Changelog](https://github.com/voxpupuli/puppet-ldapquery/compare/0.1.7...0.1.8)

**Merged pull requests:**

- Update require for puppet\_x to use relative path [\#6](https://github.com/voxpupuli/puppet-ldapquery/pull/6) ([zachfi](https://github.com/zachfi))

## [0.1.7](https://github.com/voxpupuli/puppet-ldapquery/tree/0.1.7) (2015-11-10)

[Full Changelog](https://github.com/voxpupuli/puppet-ldapquery/compare/0.1.6...0.1.7)

## [0.1.6](https://github.com/voxpupuli/puppet-ldapquery/tree/0.1.6) (2015-09-17)

[Full Changelog](https://github.com/voxpupuli/puppet-ldapquery/compare/0.1.5...0.1.6)

## [0.1.5](https://github.com/voxpupuli/puppet-ldapquery/tree/0.1.5) (2015-09-15)

[Full Changelog](https://github.com/voxpupuli/puppet-ldapquery/compare/0.1.4...0.1.5)

**Merged pull requests:**

- Return boolean false if the LDAP query function raises an exception. [\#5](https://github.com/voxpupuli/puppet-ldapquery/pull/5) ([Ziaunys](https://github.com/Ziaunys))

## [0.1.4](https://github.com/voxpupuli/puppet-ldapquery/tree/0.1.4) (2015-08-20)

[Full Changelog](https://github.com/voxpupuli/puppet-ldapquery/compare/0.1.3...0.1.4)

**Merged pull requests:**

- Improve debugging, add timing information [\#4](https://github.com/voxpupuli/puppet-ldapquery/pull/4) ([zachfi](https://github.com/zachfi))

## [0.1.3](https://github.com/voxpupuli/puppet-ldapquery/tree/0.1.3) (2015-06-14)

[Full Changelog](https://github.com/voxpupuli/puppet-ldapquery/compare/0.1.2...0.1.3)

## [0.1.2](https://github.com/voxpupuli/puppet-ldapquery/tree/0.1.2) (2015-05-29)

[Full Changelog](https://github.com/voxpupuli/puppet-ldapquery/compare/0.1.1...0.1.2)

## [0.1.1](https://github.com/voxpupuli/puppet-ldapquery/tree/0.1.1) (2015-05-29)

[Full Changelog](https://github.com/voxpupuli/puppet-ldapquery/compare/0.1.0...0.1.1)

## [0.1.0](https://github.com/voxpupuli/puppet-ldapquery/tree/0.1.0) (2015-05-21)

[Full Changelog](https://github.com/voxpupuli/puppet-ldapquery/compare/411bc809cf5bbdfbc880bfcc3a8866a2b48e4271...0.1.0)

**Merged pull requests:**

- Rewrite [\#3](https://github.com/voxpupuli/puppet-ldapquery/pull/3) ([zachfi](https://github.com/zachfi))
- Begin module testing [\#1](https://github.com/voxpupuli/puppet-ldapquery/pull/1) ([zachfi](https://github.com/zachfi))



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
