// Grey Matter configuration for Edge

package greymatter

let Name = "edge"
let EgressToRedisName = "\(Name)_egress_to_redis"

edge_config: [
	#domain & {
		domain_key:   Name
		_force_https: defaults.enable_edge_tls
	},
	#listener & {
		listener_key:                Name
		_gm_observables_topic:       Name
		_is_ingress:                 true
		_enable_oidc_authentication: false
		_oidc_endpoint:              defaults.oidc.endpoint
		_oidc_service_url:           "https://\(defaults.oidc.domain):10808"
		_oidc_provider:              "\(defaults.oidc.endpoint)/auth/realms/\(defaults.oidc.realm)"
		_oidc_client_secret:         defaults.oidc.client_secret
		_oidc_cookie_domain:         defaults.oidc.domain
		_oidc_realm:                 defaults.oidc.realm
	},
	// This cluster must exist (though it never receives traffic)
	// so that Catalog will be able to look-up edge instances
	#cluster & {cluster_key: Name},

	// egress->redis
	#domain & {domain_key: EgressToRedisName, port: defaults.ports.redis_ingress},
	#cluster & {
		cluster_key:  EgressToRedisName
		name:         defaults.redis_cluster_name
		_spire_self:  Name
		_spire_other: defaults.redis_cluster_name
	},
	#route & {route_key: EgressToRedisName},
	#listener & {
		listener_key:  EgressToRedisName
		ip:            "127.0.0.1" // egress listeners are local-only
		port:          defaults.ports.redis_ingress
		_tcp_upstream: defaults.redis_cluster_name
	},

	#proxy & {
		proxy_key: Name
		domain_keys: [Name, EgressToRedisName]
		listener_keys: [Name, EgressToRedisName]
	},
]
