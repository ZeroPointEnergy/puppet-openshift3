class openshift3::logging {

  if $::openshift3::deployment_type == "enterprise" {
    $image_prefix = 'registry.access.redhat.com/openshift3/'
  } else {
    $image_prefix = 'openshift/origin-'
  }

  new_project { "logging": } ->

  new_secret { "logging-deployer":
    namespace => "logging",
    source => "/dev/null",
  } ->
  
  new_service_account { "logging-deployer":
    namespace => "logging",
  } ->

  add_secret_to_sa { "logging-deployer":
    namespace => "logging",
    service_account => "logging-deployer",
  } ->

  add_role_to_user { "edit":
    namespace => "logging",
    user => "system:serviceaccount:logging:logging-deployer",
  } ->
    
  add_user_to_scc { "system:serviceaccount:logging:logging-deployer":
    scc => "privileged",
  } ->
  
  add_role_to_user { "cluster-reader":
    role_type => "cluster",
    user => "system:serviceaccount:logging:aggregated-logging-fluentd",
  } ->

  instantiate_template { "logging-deployer-template":
    template_namespace => "openshift",
    template_parameters => "KIBANA_HOSTNAME=kibana.${::openshift3::app_domain},ES_CLUSTER_SIZE=1,PUBLIC_MASTER_URL=https://${::openshift3::master}:8443,ES_INSTANCE_RAM=1G",
    resource_namespace => "logging",
  }

  instantiate_template { "logging-support-template":
    template_namespace => "logging",
    resource_namespace => "logging",
  }

#,IMAGE_PREFIX=${image_prefix}
}
