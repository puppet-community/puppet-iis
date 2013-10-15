define iis::manage_site($site_path, $app_pool, $host_header = '', $site_name = $title, $port = '80', $ip_address = '*', $ensure = 'present') {
  include 'iis::param::powershell'

  validate_re($ensure, '^(present|installed|absent|purged)$', 'ensure must be one of \'present\', \'installed\', \'absent\', \'purged\'')

  if ($ensure in ['present','installed']) {
    iis::createpath { "${site_name}-${site_path}":
      site_path => $site_path
    }

    exec { "CreateSite-${site_name}" :
      command   => "${iis::param::powershell::command} -Command \"Import-Module WebAdministration; New-WebSite -Name \\\"${site_name}\\\" -Port ${port} -IP ${ip_address} -HostHeader \\\"${host_header}\\\" -PhysicalPath \\\"${site_path}\\\" -ApplicationPool \\\"${app_pool}\\\"\"",
      path      => "${iis::param::powershell::path};${::path}",
      onlyif    => "${iis::param::powershell::command} -Command \"Import-Module WebAdministration; if((Test-Path \"IIS:\\Sites\\${site_name}\")) { exit 1 } else { exit 0 }\"",
      logoutput => true,
      require   => [ Iis::Createpath["${site_name}-${site_path}"], Iis::Manage_app_pool[$app_pool] ],
    }
  } else {
    exec { "DeleteSite-${site_name}" :
      command   => "${iis::param::powershell::command} -Command \"Import-Module WebAdministration; Remove-WebSite -Name \\\"${site_name}\\\"\"",
      path      => "${iis::param::powershell::path};${::path}",
      onlyif    => "${iis::param::powershell::command} -Command \"Import-Module WebAdministration; if(!(Test-Path \"IIS:\\Sites\\${site_name}\")) { exit 1 } else { exit 0 }\"",
      logoutput => true,
    }
  }
}
