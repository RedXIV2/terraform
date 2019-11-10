define myuser(
  $password,
  $expiry = '2020-03-22',
  $shell  = '/bin/bash',
) {
  user { $title:
    ensure           => present,
    managehome       => true,
    comment          => 'Puppet managed user',
    home             => "/home/${title}",
    shell            => $shell,
    expiry           => $expiry,
    password         => $password,
    password_min_age => '30',
    password_max_age => '60',
  }
  exec { "chage-${title}":
    command => "/usr/bin/chage -d 0 ${title}",
    require => User["${title}"]
  } 
}
