include git

exec { 'clone-my-repo':
    command => '/usr/bin/git clone https://github.com/RedXIV2/terraform.git -o repo1'
}

exec { 'clone-kubernetes-repo':
    command => '/usr/bin/git clone https://github.com/kubernetes/kubernetes -o repo2'
}
