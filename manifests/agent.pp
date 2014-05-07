class teamcity::agent(
  $user            = 'teamcity-agent',
  $server_url      = 'http://10.10.21.42',
  $agent_name      = $::hostname,
  $own_port        = 9090,
  $own_address     = '',         # default to empty string to let build agent detect it
  $home            = '/opt/teamcity-agent',
  $agent_opts      = '',         # TODO: expose in teamcity-agent.erb
  $agent_mem_opts  = '-Xmx384m', # TODO: expose in teamcity-agent.erb
  $properties      = {},
  $manage_firewall = hiera('manage_firewall', false)
) {
  $service         = 'teamcity-agent'
  $bin_dir         = "$home/bin"
  $work_dir        = "$home/work"
  $temp_dir        = "$home/temp"
  $system_dir      = "$home/system"
  $conf_dir        = "$home/conf"
  $plugins_dir     = "$home/plugins"
  $lib_dir         = "$home/lib"
  $launcher_dir    = "$home/launcher"
  $contrib_dir     = "$home/contrib"

  anchor { 'teamcity::agent::start': }

  class {'teamcity::common' : } ->
  class {'teamcity::agent::install' : } ->
  class {'teamcity::agent::config' : } ->
  class {'teamcity::agent::service' : } ->
  Class['teamcity::agent']

  include teamcity::agent::env

  teamcity::agent::env::bash_profile { 'env:WORK_DIR':
    content => "export AGENT_WORK_DIR=\"$work_dir\""
  }

  $has_done_chown = '/etc/teamcity-agent.chown'

  if $manage_firewall {
    firewall { "101 allow agent-connections:$own_port":
      proto   => 'tcp',
      state   => ['NEW'],
      dport   => $own_port,
      action  => 'accept',
      require => Anchor['teamcity::agent::start'],
      before  => Anchor['teamcity::agent::end'],
    } 
  }

  anchor { 'teamcity::agent::end': }
}
