# Usage Examples

This document provides practical examples of using the `invenio-oauthclient-aaf` package with the `AAFSettingsHelper` class.

## Basic Usage

### Simple Configuration

```python
# invenio.cfg

from invenio_oauthclient_aaf import AAF_REMOTE_APP

OAUTHCLIENT_REMOTE_APPS = {
    "aaf": AAF_REMOTE_APP,
}

AAF_APP_CREDENTIALS = {
    "consumer_key": "your-client-id",
    "consumer_secret": "your-client-secret",
}
```

## Using AAFSettingsHelper

### Custom Title and Description

```python
from invenio_oauthclient_aaf import AAFSettingsHelper

aaf = AAFSettingsHelper(
    title="University Login",
    description="Login with your university credentials",
)

OAUTHCLIENT_REMOTE_APPS = {
    "aaf": aaf.remote_app,
}

AAF_APP_CREDENTIALS = {
    "consumer_key": "your-client-id",
    "consumer_secret": "your-client-secret",
}
```

### Custom Scopes

Request additional user attributes:

```python
from invenio_oauthclient_aaf import AAFSettingsHelper

aaf = AAFSettingsHelper(
    title="AAF",
    description="Australian Access Federation",
    request_token_params={
        "scope": "openid profile email eduPersonAffiliation eduPersonEntitlement",
    },
)

OAUTHCLIENT_REMOTE_APPS = {
    "aaf": aaf.remote_app,
}
```

### Force Re-authentication

Force users to re-authenticate on each login:

```python
from invenio_oauthclient_aaf import AAFSettingsHelper

aaf = AAFSettingsHelper(
    title="AAF (Secure)",
    description="Secure login with AAF",
    request_token_params={
        "scope": "openid profile email",
        "prompt": "login",  # Force re-authentication
    },
)

OAUTHCLIENT_REMOTE_APPS = {
    "aaf": aaf.remote_app,
}
```

### Custom Icon

Customize the login button icon:

```python
from invenio_oauthclient_aaf import AAFSettingsHelper

aaf = AAFSettingsHelper(
    title="AAF",
    description="Australian Access Federation",
    icon="fa fa-graduation-cap",  # Custom FontAwesome icon
)

OAUTHCLIENT_REMOTE_APPS = {
    "aaf": aaf.remote_app,
}
```

## Advanced Customization

### Custom Account Setup Handler

The `account_setup` handler is called after user login. You can override it for custom post-login actions:

```python
# myapp/handlers.py

def custom_account_setup(remote, token, resp):
    """Perform custom actions after user login."""
    # Add custom logic here, e.g.:
    # - Assign user to specific groups
    # - Log authentication events
    # - Update user metadata
    pass


# invenio.cfg

from invenio_oauthclient_aaf import AAFSettingsHelper

class CustomAAFHelper(AAFSettingsHelper):
    def get_handlers(self):
        handlers = super().get_handlers()
        handlers["signup_handler"]["setup"] = "myapp.handlers:custom_account_setup"
        return handlers

aaf = CustomAAFHelper()

OAUTHCLIENT_REMOTE_APPS = {
    "aaf": aaf.remote_app,
}
```

### Custom Signup Options

Configure automatic confirmation and notifications:

```python
from invenio_oauthclient_aaf import AAFSettingsHelper

aaf = AAFSettingsHelper(
    signup_options={
        "auto_confirm": True,       # Automatically confirm user email (default)
        "send_register_msg": False, # Don't send registration email (default)
    }
)

OAUTHCLIENT_REMOTE_APPS = {
    "aaf": aaf.remote_app,
}
```

## Testing Configurations

### Sandbox Environment

Use the pre-configured sandbox instance:

```python
from invenio_oauthclient_aaf import AAF_SANDBOX_REMOTE_APP

OAUTHCLIENT_REMOTE_APPS = {
    "aaf": AAF_SANDBOX_REMOTE_APP,
}

AAF_APP_CREDENTIALS = {
    "consumer_key": "test-client-id",
    "consumer_secret": "test-client-secret",
}
```

Or create a custom sandbox configuration:

```python
from invenio_oauthclient_aaf import AAFSettingsHelper

aaf_test = AAFSettingsHelper(
    title="AAF Test",
    description="AAF Test Environment",
    base_url="https://central.test.aaf.edu.au",
    access_token_url="https://central.test.aaf.edu.au/oidc/token",
    authorize_url="https://central.test.aaf.edu.au/oidc/authorize",
    app_key="AAF_TEST_CREDENTIALS",
)

OAUTHCLIENT_REMOTE_APPS = {
    "aaf": aaf_test.remote_app,
}

AAF_TEST_CREDENTIALS = {
    "consumer_key": "test-client-id",
    "consumer_secret": "test-client-secret",
}
```

### Switch Between Environments

Use environment variables to switch between production and sandbox:

```python
import os
from invenio_oauthclient_aaf import AAF_REMOTE_APP, AAF_SANDBOX_REMOTE_APP

# Determine environment
aaf_env = os.environ.get("AAF_ENVIRONMENT", "production")

if aaf_env == "sandbox":
    remote_app = AAF_SANDBOX_REMOTE_APP
else:
    remote_app = AAF_REMOTE_APP

OAUTHCLIENT_REMOTE_APPS = {
    "aaf": remote_app,
}
```

## Troubleshooting Examples

### Enable Debug Logging

```python
import logging

# Enable debug logging for AAF
LOGGING_CONSOLE_LEVEL = logging.DEBUG

# Or configure specific logger
LOGGING = {
    'version': 1,
    'loggers': {
        'invenio_oauthclient_aaf': {
            'level': 'DEBUG',
        },
    },
}
```

### Verify Configuration

```python
# Script to verify AAF configuration
from invenio_oauthclient_aaf import AAF_HELPER, AAF_REMOTE_APP

# Check helper configuration
print(f"Base URL: {AAF_HELPER.base_url}")

# Check remote app structure
print(f"\nRemote App Keys: {AAF_REMOTE_APP.keys()}")
print(f"Title: {AAF_REMOTE_APP['title']}")
print(f"Description: {AAF_REMOTE_APP['description']}")
print(f"Icon: {AAF_REMOTE_APP.get('icon')}")

# Check handlers
print(f"\nHandlers: {AAF_REMOTE_APP['params']['handlers']}")
```

## Best Practices

1. **Use environment variables** for credentials, never commit them to version control
2. **Test in sandbox** before deploying to production using `AAF_SANDBOX_REMOTE_APP`
3. **Enable auto-confirm** for trusted identity providers like AAF (enabled by default)
4. **Request only necessary scopes** to minimize data exposure (default: `openid profile email`)
5. **Use descriptive titles** to help users identify the correct login method
6. **Monitor logs** during initial deployment to catch configuration issues
7. **Use the pre-configured remote apps** (`AAF_REMOTE_APP`, `AAF_SANDBOX_REMOTE_APP`) for simplicity - they handle userinfo URL construction automatically

## See Also

- [Quick Start Guide](QUICKSTART.md)
- [Main README](../README.md)
- [AAF Documentation](https://aaf.edu.au/)
- [InvenioRDM Authentication Docs](https://inveniordm.docs.cern.ch/customize/authentication/)
