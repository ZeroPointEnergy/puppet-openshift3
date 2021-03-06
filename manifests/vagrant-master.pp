class openshift3::vagrant-master {

  if $::vagrant {
    $openshift_hosts = parsejson($::openshift_hosts)
    $master_ip = $openshift_hosts[0]['ip']

    firewall { '500 Allow UDP DNS requests':
      action => 'accept',
      state  => 'NEW',
      dport  => [53],
      proto  => 'udp',
    }

    firewall { '501 Allow TCP DNS requests':
      action => 'accept',
      state  => 'NEW',
      dport  => [53],
      proto  => 'tcp',
    }

    file { '/etc/dnsmasq.d/dnsmasq-extra.conf':
      ensure  => present,
      owner  => 'root',
      group  => 'root',
      mode   => 0600,
      content => template("openshift3/etc/dnsmasq-extra.conf.erb"),
      notify => Service['dnsmasq'],
    }

    class { 'dnsmasq':
      no_hosts => true,
      listen_address => [$master_ip]
    }

    # Add wildcard entries for OpenShift 3 apps
    dnsmasq::address { ".cloudapps.$::domain":
      ip => $master_ip,
    }
    dnsmasq::address { ".openshiftapps.com":
      ip => $master_ip,
    }

    openshift3::add_dns_entries { $openshift_hosts: }

    user { ['joe', 'alice' ]:
      ensure => present,
      managehome => true,
    }

    file { '/etc/openshift': ensure => directory } ->

    htpasswd { ['joe', 'alice']:
      cryptpasswd => '$apr1$LB4KhoUd$2QRUqJTtbFnDeal80WI2R/',
      target      => '/etc/openshift/openshift-passwd',
    }
  }
}
