class teamcity::agent::service {
  file { "$home/bin/agent.sh":
    mode    => '0755',
    require => [
    Anchor['teamcity::agent::start'],
    File[$home],
    Class['teamcity::agent::install']
    ],
    before  => Anchor['teamcity::agent::end'],
  }

  file { "/etc/init.d/$service":
    ensure  => present,
    content => template('teamcity/teamcity-agent.erb'),
    mode    => '0755',
    require => Anchor['teamcity::agent::start'],
    before  => Anchor['teamcity::agent::end'],
  }

  service { $service:
    ensure     => running,
    enable     => true,
    status     => 'ps aux | grep /usr/bin/java | grep AgentMain',
    hasstatus  => false,
    hasrestart => true,
    require    => [
    Anchor['teamcity::agent::start'],
    Class['java'],
    Class['teamcity::common'],
    File["$home/bin/agent.sh"],
    File["/etc/init.d/$service"]
    ],
    before     => Anchor['teamcity::agent::end'],
  }
}