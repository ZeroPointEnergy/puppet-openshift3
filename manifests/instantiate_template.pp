define openshift3::instantiate_template ($template_namespace = 'openshift', $template_parameters = "", $resource_namespace = 'default') {
  exec { "instantiate template ${title}":
    provider    => 'shell',
    environment => 'HOME=/root',
    cwd         => "/root",
    command     => "oc process logging-deployer-template -n ${template_namespace} -v '${template_parameters}' | oc create -n ${resource_namespace} -f -",
#    unless      => "oc get ${namespace_opt} ${resource} -o json | jq '.items[] | select(.roleRef.name == \"${title}\").userNames' | grep -q '\"${user}\"'",
    timeout     => 300,
    logoutput   => on_failure,
  }
}
