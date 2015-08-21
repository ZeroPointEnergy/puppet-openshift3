define openshift3::oc_replace ($namespace = 'default', $resource = undef, $unless = undef, $refreshonly = undef, $logoutput = false) {
  if $namespace {
    $namespace_opt = "--namespace=${namespace}"
  } else {
    $namespace_opt =""
  }

  if $resource {
    case $title {
      /^([0-9a-zA-Z_.\[\]]+)\s*=\s*(-?[0-9]+|".+"|{.+}|true|false)$/:            { $condition = "$1 == $2" }
      /^([0-9a-zA-Z_.\[\]]+)\s*\+=\s*(\[-?[0-9]+\]|\["[^"]+"\])$/:  { $condition = "$1 | contains($2)" }
      default:                                                { fail("Unsupported expression: $title") }
    }

    exec { "oc_replace $title":
      provider => 'shell',
      environment => 'HOME=/root',
      cwd     => "/root",
      command => "oc get ${namespace_opt} '${resource}' -o json | jq '$title' | oc update ${namespace_opt} '${resource}' -f -",
      unless => "oc get ${namespace_opt} '${resource}' -o json | [ `jq '$condition'` == true ]",
      timeout => 600,
      refreshonly => $refreshonly,
      logoutput => $logoutput,
    }
  } else {
    exec { "oc_replace $title":
      provider => 'shell',
      environment => 'HOME=/root',
      cwd     => "/root",
      command => "oc update ${namespace_opt} -f '${title}'",
      unless => $unless,
      timeout => 600,
      refreshonly => $refreshonly,
      logoutput => $logoutput,
    }
  }
}
