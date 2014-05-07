class teamcity::agent::config {
  exec { 'teamcity::agent chown':
    command     => "/bin/chown -R ${user}:${teamcity::common::group} ${home}* && /bin/touch $has_done_chown",
    creates     => $has_done_chown,
    subscribe   => Class['teamcity::agent::install'],
    require     => [
    Anchor['teamcity::agent::start'],
    User[$user],
    File[$home]
    ],
    before  => Anchor['teamcity::agent::end'],
  }

  file { "$home/conf/buildAgent.properties":
    ensure  => present,
    replace => false,
    content => template('teamcity/buildAgent.properties.erb'),
    owner   => $user,
    group   => $teamcity::common::group,
    mode    => '0644',
    require => [
    Anchor['teamcity::agent::start'],
    Exec['teamcity::agent chown']
    ],
    before  => Anchor['teamcity::agent::end'],
  }
}