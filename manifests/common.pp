class teamcity::common(
  $group = 'teamcity'
) {
  anchor { 'teamcity::common::start': }

  group { $group:
    ensure => present,
    system => true
  } ->

  user { $user:
    ensure  => present,
    system  => true,
    home    => $home,
    gid     => $teamcity::common::group
  }

  anchor { 'teamcity::common::end': }
}