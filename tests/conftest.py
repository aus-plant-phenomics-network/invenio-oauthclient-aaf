"""Pytest configuration for invenio-oauthclient-aaf tests."""

import pytest
from flask import Flask


@pytest.fixture
def app():
    """Create Flask application for testing."""
    flask_app = Flask("testapp")
    flask_app.config.update(
        {
            "TESTING": True,
            "SECRET_KEY": "test-secret-key",
        }
    )
    return flask_app


@pytest.fixture
def app_context(app):  # pylint: disable=redefined-outer-name
    """Create Flask application context."""
    with app.app_context():
        yield app
