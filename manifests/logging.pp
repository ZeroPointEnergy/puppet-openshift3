class openshift3::logging {

  new_project { "logging": } ->
  
  new_service_account { "logging-deployer":
    namespace => "logging",
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
    template_parameters => "KIBANA_HOSTNAME=kibana.${::openshift3::app_domain},ES_CLUSTER_SIZE=1,PUBLIC_MASTER_URL=https://${::openshift3::master}:8443,ES_INSTANCE_RAM=512MB",
    resource_namespace => "logging",
  }
}
