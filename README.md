#vault

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What vault does and why it is useful](#module-description)
3. [Setup - The basics of getting started with [vault]](#setup)
    * [What [vault] affects](#what-[vault]-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with [vault]](#beginning-with-[vault])
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to vault](#development)

##Overview

Deploy Hashicorp's [Vault](http://vaultproject.io).  Downloads and installs
the software, writes the configuration file and manages initialisation, the
initial unseal, and mounting selected backends.

Tested with Ubuntu 14.04, but should work on other systems with the addition
of a suitable init script template.

##Module Description

This module attempts to bring Vault into a usable state without human
intervention, while maintaining a high level of security.  Unseal keys and
the initial root token are encrypted using public ssh keys and placed in
home directories ready for download and offline storage.

The optional bootstrap process sets up an SSL certificate authority and
configures the PKI secret backend.  Future releases will add support for
configuring other backends.

##Setup

###What [vault] affects

* Installs Vault to /usr/local/bin/vault
* Installs configuration to /etc/vault/
* Installs SSL certificate authority files to /etc/ssl/ca/
* Encrypts and stores unseal keys to admin users' home directories as
    ~/vault_unseal_key
* Encrypts and stores initial root token to admin users' home
    directories as ~/vault_initial_root_token

###Setup Requirements **OPTIONAL**

Requires the nanlui/staging and puppetlabs/stdlib modules.

###Beginning with [vault]

Basic configuration -- including bootstrapping to an unsealed running
instance -- requires one parameter, an array of admin usernames.  The users
and their ssh keys need to already exist when Vault is bootstrapped.

```puppet
class { 'vault':
  admins => [
    'amy',
    'bob',
    'dave',
    'fred',
    'sally'
  ],
}

Ssh_authorized_key <||> -> Class['vault']
```

##Usage

Full documentation of parameters is included in the init.pp manifest file.

##Reference

Only the "vault" class should be instantiated directly - all other classes
are private.

##Limitations

Currently this module only supports Upstart, so it's mostly limited to
Ubuntu.  Support for other operating systems and distributions should be a
simple matter; most of the basic structure is already in place.

##Development

Pull requests are welcome, and even more so if they come with passing test
cases.

##Contributors

Written by Mark Mickan <mark.mickan@blackboard.com>.

Thanks to Kyle Anderson for the
[KyleAnderson/consul](https://github.com/solarkennedy/puppet-consul) module,
which parts of this module are based on.
