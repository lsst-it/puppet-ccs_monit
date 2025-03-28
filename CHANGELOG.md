# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v2.3.0](https://github.com/lsst-it/puppet-ccs_monit/tree/v2.3.0) (2025-03-28)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_monit/compare/v2.2.3...v2.3.0)

**Implemented enhancements:**

- Allow specification of disk monitoring parameters. [\#33](https://github.com/lsst-it/puppet-ccs_monit/pull/33) ([glennmorris](https://github.com/glennmorris))

## [v2.2.3](https://github.com/lsst-it/puppet-ccs_monit/tree/v2.2.3) (2024-10-17)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_monit/compare/v2.2.2...v2.2.3)

**Breaking changes:**

- Remove unused pkgurl parameters [\#24](https://github.com/lsst-it/puppet-ccs_monit/pull/24) ([glennmorris](https://github.com/glennmorris))

**Implemented enhancements:**

- \(files/monit\_netspeed\) tweak expected auxtel.cp speeds [\#30](https://github.com/lsst-it/puppet-ccs_monit/pull/30) ([glennmorris](https://github.com/glennmorris))
- \(puppet-ccs\_monit\) add apache license [\#23](https://github.com/lsst-it/puppet-ccs_monit/pull/23) ([dtapiacl](https://github.com/dtapiacl))

## [v2.2.2](https://github.com/lsst-it/puppet-ccs_monit/tree/v2.2.2) (2024-04-17)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_monit/compare/v2.2.1...v2.2.2)

**Fixed bugs:**

- Fix typo in netspeed script [\#22](https://github.com/lsst-it/puppet-ccs_monit/pull/22) ([glennmorris](https://github.com/glennmorris))

## [v2.2.1](https://github.com/lsst-it/puppet-ccs_monit/tree/v2.2.1) (2024-03-28)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_monit/compare/v2.2.0...v2.2.1)

**Implemented enhancements:**

- \(files/monit\_hwraid\) no error if RAID not configured [\#21](https://github.com/lsst-it/puppet-ccs_monit/pull/21) ([glennmorris](https://github.com/glennmorris))

## [v2.2.0](https://github.com/lsst-it/puppet-ccs_monit/tree/v2.2.0) (2024-03-26)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_monit/compare/v2.1.0...v2.2.0)

**Implemented enhancements:**

- Allow multiple mailservers, default to localhost [\#20](https://github.com/lsst-it/puppet-ccs_monit/pull/20) ([glennmorris](https://github.com/glennmorris))

## [v2.1.0](https://github.com/lsst-it/puppet-ccs_monit/tree/v2.1.0) (2023-08-22)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_monit/compare/v2.0.0...v2.1.0)

**Implemented enhancements:**

- allow stdlib 9.x [\#18](https://github.com/lsst-it/puppet-ccs_monit/pull/18) ([jhoblitt](https://github.com/jhoblitt))

## [v2.0.0](https://github.com/lsst-it/puppet-ccs_monit/tree/v2.0.0) (2023-06-23)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_monit/compare/v1.1.0...v2.0.0)

**Breaking changes:**

- \(plumbing\) drop support for puppet6 [\#11](https://github.com/lsst-it/puppet-ccs_monit/pull/11) ([jhoblitt](https://github.com/jhoblitt))

**Implemented enhancements:**

- add support for puppet8 [\#12](https://github.com/lsst-it/puppet-ccs_monit/pull/12) ([jhoblitt](https://github.com/jhoblitt))

## [v1.1.0](https://github.com/lsst-it/puppet-ccs_monit/tree/v1.1.0) (2023-01-31)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_monit/compare/v1.0.1...v1.1.0)

**Implemented enhancements:**

- normalize supported operating systems [\#6](https://github.com/lsst-it/puppet-ccs_monit/pull/6) ([jhoblitt](https://github.com/jhoblitt))

**Merged pull requests:**

- monit\_inlet\_temp: shellcheck fixes [\#7](https://github.com/lsst-it/puppet-ccs_monit/pull/7) ([glennmorris](https://github.com/glennmorris))

## [v1.0.1](https://github.com/lsst-it/puppet-ccs_monit/tree/v1.0.1) (2022-11-12)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_monit/compare/v1.0.0...v1.0.1)

## [v1.0.0](https://github.com/lsst-it/puppet-ccs_monit/tree/v1.0.0) (2022-08-17)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_monit/compare/v0.2.0...v1.0.0)

**Merged pull requests:**

- release 1.0.0 [\#4](https://github.com/lsst-it/puppet-ccs_monit/pull/4) ([jhoblitt](https://github.com/jhoblitt))
- modulesync 5.3.0 + general cleanup + EL7/EL8/EL9 acceptance testing [\#3](https://github.com/lsst-it/puppet-ccs_monit/pull/3) ([jhoblitt](https://github.com/jhoblitt))
- Improve treatment of package source [\#2](https://github.com/lsst-it/puppet-ccs_monit/pull/2) ([glennmorris](https://github.com/glennmorris))

## [v0.2.0](https://github.com/lsst-it/puppet-ccs_monit/tree/v0.2.0) (2022-07-13)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_monit/compare/v0.1.2...v0.2.0)

## [v0.1.2](https://github.com/lsst-it/puppet-ccs_monit/tree/v0.1.2) (2021-02-26)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_monit/compare/v0.1.1...v0.1.2)

## [v0.1.1](https://github.com/lsst-it/puppet-ccs_monit/tree/v0.1.1) (2020-07-03)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_monit/compare/v0.1.0...v0.1.1)

## [v0.1.0](https://github.com/lsst-it/puppet-ccs_monit/tree/v0.1.0) (2020-06-11)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_monit/compare/0a5039b3fdfe3b87bb2c74424fb8287e5099c17b...v0.1.0)



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
