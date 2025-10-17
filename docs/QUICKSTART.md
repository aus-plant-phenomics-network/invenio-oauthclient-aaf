# Quick Start Guide

This guide will help you quickly set up AAF authentication for your InvenioRDM instance.

## Prerequisites

- A running InvenioRDM instance (v11 or later recommended)
- AAF Federation Manager access
- Python 3.9+

## Step 1: Install the Package

### Option A: Install from PyPI

```bash
cd your-inveniordm-instance
pipenv install invenio-oauthclient-aaf
```

### Option B: Install from source

```bash
cd your-inveniordm-instance
git clone https://github.com/aus-plant-phenomics-network/invenio-oauthclient-aaf.git
pipenv install -e ./invenio-oauthclient-aaf
```

## Step 2: Register with AAF

1. Log in to the [AAF Federation Manager](https://manager.aaf.edu.au/)
2. Register a new service with these details:
   - **Service Name**: Your InvenioRDM instance name
   - **Redirect URI**: `https://your-domain.com/oauth/authorized/aaf/`
   - **Scopes**: `openid profile email`
3. Note down your **Client ID** and **Client Secret**

## Step 3: Configure InvenioRDM

Edit your `invenio.cfg`:

```python
# Import the AAF remote app
from invenio_oauthclient_aaf import AAF_REMOTE_APP

# Configure AAF OAuth
OAUTHCLIENT_REMOTE_APPS = {
    "aaf": AAF_REMOTE_APP,
}

# Set your AAF credentials (DO NOT commit these!)
AAF_APP_CREDENTIALS = {
    "consumer_key": "your-aaf-client-id-here",
    "consumer_secret": "your-aaf-client-secret-here",
}
```

## Step 4: Restart Services

```bash
invenio-cli services stop
invenio-cli services start
```

## Step 5: Test the Integration

1. Navigate to your InvenioRDM login page
2. You should see a "Login with AAF" button
3. Click it and authenticate with your AAF credentials
4. You should be redirected back and logged in!

## Optional Configuration

### Use Sandbox for Testing

```python
from invenio_oauthclient_aaf import AAF_SANDBOX_REMOTE_APP

OAUTHCLIENT_REMOTE_APPS = {
    "aaf": AAF_SANDBOX_REMOTE_APP,
}
```

### Disable Local Login

```python
# Only allow AAF login
ACCOUNTS_LOCAL_LOGIN_ENABLED = False
SECURITY_REGISTERABLE = False
SECURITY_RECOVERABLE = False
SECURITY_CHANGEABLE = False
```

### Auto-redirect to AAF

```python
from invenio_oauthclient.views.client import auto_redirect_login

ACCOUNTS_LOGIN_VIEW_FUNCTION = auto_redirect_login
OAUTHCLIENT_AUTO_REDIRECT_TO_EXTERNAL_LOGIN = True
```

### Customize User Confirmation

The default configuration already includes:

- `auto_confirm: True` - Automatically confirms user email
- `send_register_msg: False` - Doesn't send registration emails

To customize these settings, use the `AAFSettingsHelper` class:

```python
from invenio_oauthclient_aaf import AAFSettingsHelper

aaf = AAFSettingsHelper(
    title="AAF",
    description="Australian Access Federation",
    signup_options={
        "auto_confirm": False,  # Require manual confirmation
        "send_register_msg": True,  # Send registration emails
    }
)

OAUTHCLIENT_REMOTE_APPS = {
    "aaf": aaf.remote_app,
}
```

## Troubleshooting

### Common Issues

**"No access token received"**

- Verify your Client ID and Secret are correct
- Check that the redirect URI in AAF matches exactly

**"AAF did not provide user email"**

- Ensure the `email` scope is requested
- Check AAF returns the email attribute

**Login button doesn't appear**

- Verify the package is installed: `pip list | grep aaf`
- Check `OAUTHCLIENT_REMOTE_APPS` configuration
- Restart services

## Next Steps

- Customize attribute mapping (see README.md)
- Set up automatic user role assignment
- Configure session timeouts
- Review security settings

## Need Help?

- Check the [full documentation](../README.md)
- Open an issue on [GitHub](https://github.com/aus-plant-phenomics-network/invenio-oauthclient-aaf/issues)
- Contact AAF support: support@aaf.edu.au
