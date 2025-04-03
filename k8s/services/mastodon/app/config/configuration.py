"""Netbox configuration"""

ALLOWED_HOSTS = ["netbox.lama.tel"]

DATABASE = {
    "NAME": "netbox",
    "USER": "{{ .username }}",
    "PASSWORD": "{{ .password }}",
    "HOST": "postgresql.fsn.lama.tel",
    "OPTIONS": {
        "sslmode": "prefer",
    },
}

REDIS = {
    "tasks": {
        "HOST": "redis.fsn.lama.tel",
        "PORT": 6385,
        "DATABASE": 0,
    },
    "caching": {
        "HOST": "redis.fsn.lama.tel",
        "PORT": 6385,
        "DATABASE": 1,
    },
}

SECRET_KEY = "{{ .secret_key }}"

EXEMPT_VIEW_PERMISSIONS = ["*"]

SECURE_SSL_REDIRECT = True
SESSION_COOKIE_SECURE = True

PLUGINS = ["netbox_bgp"]

TIME_ZONE = "Europe/Paris"

REMOTE_AUTH_ENABLED = True
REMOTE_AUTH_BACKEND = "social_core.backends.open_id_connect.OpenIdConnectAuth"

SOCIAL_AUTH_OIDC_ENDPOINT = "https://auth.lama-corp.space/application/o/netbox/"
SOCIAL_AUTH_OIDC_KEY = "{{ .client_id }}"
SOCIAL_AUTH_OIDC_SECRET = "{{ .client_secret }}"
LOGOUT_REDIRECT_URL = "https://auth.lama-corp.space/application/o/netbox/end-session/"
SOCIAL_AUTH_OIDC_SCOPE = ["openid", "profile", "email", "roles"]

SOCIAL_AUTH_PIPELINE = (
    ###################
    # Default pipelines
    ###################
    # Get the information we can about the user and return it in a simple
    # format to create the user instance later. In some cases the details are
    # already part of the auth response from the provider, but sometimes this
    # could hit a provider API.
    "social_core.pipeline.social_auth.social_details",
    # Get the social uid from whichever service we"re authing thru. The uid is
    # the unique identifier of the given user in the provider.
    "social_core.pipeline.social_auth.social_uid",
    # Verifies that the current auth process is valid within the current
    # project, this is where emails and domains whitelists are applied (if
    # defined).
    "social_core.pipeline.social_auth.auth_allowed",
    # Checks if the current social-account is already associated in the site.
    "social_core.pipeline.social_auth.social_user",
    # Make up a username for this person, appends a random string at the end if
    # there"s any collision.
    "social_core.pipeline.user.get_username",
    # Send a validation email to the user to verify its email address.
    # Disabled by default.
    # "social_core.pipeline.mail.mail_validation",
    # Associates the current social details with another user account with
    # a similar email address. Disabled by default.
    # "social_core.pipeline.social_auth.associate_by_email",
    # Create a user account if we haven't found one yet.
    "social_core.pipeline.user.create_user",
    # Create the record that associates the social account with the user.
    "social_core.pipeline.social_auth.associate_user",
    # Populate the extra_data field in the social record with the values
    # specified by settings (and the default ones like access_token, etc).
    "social_core.pipeline.social_auth.load_extra_data",
    # Update the user record with any changed info from the auth service.
    "social_core.pipeline.user.user_details",
    ###################
    # Custom pipelines
    ###################
    # Save extra info
    "netbox.custom_pipeline.save_all_claims_as_extra_data",
    # Set Groups
    "netbox.custom_pipeline.update_groups",
    # Set Roles
    "netbox.custom_pipeline.update_roles",
)
