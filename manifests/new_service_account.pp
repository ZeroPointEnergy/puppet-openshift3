define openshift3::new_service_account ($namespace = 'default') {
  if $namespace {
    $namespace_opt = "--namespace=${namespace}"
  } else {
    $namespace_opt =""
  }

  exec { "oc create with new sa ${title}":
    provider    => 'shell',
    environment => 'HOME=/root',
    cwd         => "/root",
    command     => "echo '{\"kind\":\"ServiceAccount\",\"apiVersion\":\"v1\",\"metadata\":{\"name\":\"${title}\"}}' | oc create ${namespace_opt} -f -",
    unless      => "oc get sa ${namespace_opt} ${title}",
    timeout     => 60,
  }
}
