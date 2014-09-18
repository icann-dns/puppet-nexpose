# nexpose

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with nexpose](#setup)
    * [What nexpose affects](#what-nexpose-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with nexpose](#beginning-with-nexpose)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This module attempts to configuer nexpose basic config

## Module Description

The module currently supports configuering the basic web server parmaters of the security console including configuering ldap authentication source.  It also adds a new custome type nexpose\_host this allows for exporting resources and realising them on the nexpose console

## Setup

### What nexpose affects

This module is configuered to work with the virtual machine provided by nexpose.  The following files are altered during configeration
 * /opt/rapid7/nexpose/nsc/conf/httpd.xml (via a template)
 * /opt/rapid7/nexpose/nsc/conf/nsc.xml (using augeas)

It also uses the augeas api to add resources directly to the nexpos console.  The policy will install the nexpose gem and configure the system for ruby 1.9.3.

If you are using puppet enterprise you will need to install the puppet gem manully with the following command 

/opt/puppet/bin/gem install nexpose

We also introduce three custom types 
 * nexpose\_host
 * nexpose\_site
 * nexpose\_user

### Setup Requirements 

 * puppetlabs/puppetlabs-ruby

### Beginning with nexpose

to configure nexpose with default settings add the following:

    class {'::nexpose': } 

To configure ldap ad the following to your manifest

    class {'::nexpose:ldap':
      ldap\_server => 'ldap.example.com',
      ldap\_base   => 'DC=example,DC=com',
    }

To export a resource use the follwing

    @@nexpose_host {
        $::fqdn:
            ensure => present,
            site => 'site_name',
            require => Nexpose_site['site_name'];
    }
And to realise it use

    Nexpose\_host <<||>>

To add a site to the nexpose console 

    nexpose_site {
        'site_name'
            ensure => present,
            description => 'description',
            scan_template => 'scan_template',
    }

The following scan\_templates are supported
  * cis
  * disa
  * dos-audit
  * discovery
  * aggressive-discovery
  * exhaustive-audit
  * fdcc-1\_2\_1\_0
  * full-audit
  * full-audit-without-web-spider
  * hipaa-audit
  * internet-audit
  * linux-rpm
  * microsoft-hotfix
  * pci-audit
  * pentest-audit
  * scada
  * network-audit
  * sox-audit
  * usgcb-1\_2\_1\_0
  * web-audit

To add a user to the nexpose console 

    nexpose\_user {
      'nxadmin'
        ensure      => present,
        enabled     => true,
        password    => 'nxpassword',
        full_name   => 'Default User',
        role        => 'global-admin';
    }

If the password is not present then the account will be created with a password of nxpassword.  The following roles are supported 
  * user
  * system-admin
  * controls-insight-only
  * global-admin
  * security-manager
  * site-admin

## Usage

Put the classes, types, and resources for customizing, configuring, and doing
the fancy stuff with your module here.

## Reference

Here, list the classes, types, providers, facts, etc contained in your module.
This section should include all of the under-the-hood workings of your module so
people know what the module is touching on their system but don't need to mess
with things. (We are working on automating this section!)

## Limitations

Only tested with the rapid7 nexpose VM.  Currently restarts the nexposeconsole when making changes which takes a long time.

 * When using absent with nexpose\_host it will remove the host from all templates
 * if you change the site property of nexpose\_host it will add the host to the new site but it will remain in old site (this should probably be an array however in the back end it creates two devices on the backend so still not convinced)

## Development

Any feedback or pull requests welcom

