@redis-session-manager
Feature: redis-session-manager

    Scenario: Configure with REDIS
	Given redis installed
	And  sysadmin start redis
	"""
        Given tcserver installed
        And instance dir does not exist
        When sysadmin applies template redis-session-manager
        When sysadmin applies template bio
        And sysadmin configures template bio bio.http.port random_http_port 
        And sysadmin creates instance
        And sysadmin starts instance
        Then server startup <outcome> 
	"""
