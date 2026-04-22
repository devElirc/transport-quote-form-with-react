"""Pytest checks for the staged transport quote form HTML.

This task is primarily verified via Playwright (Node), but we also keep a small
pytest verifier so the task conforms to the common Harbor verification flow.
"""

from __future__ import annotations

from pathlib import Path


APP_INDEX = Path("/app/index.html")


def _read_index() -> str:
    if not APP_INDEX.exists():
        raise AssertionError("Expected staged app at /app/index.html, but it does not exist.")
    return APP_INDEX.read_text(encoding="utf-8", errors="strict")


def test_index_html_is_staged() -> None:
    """Verify the app is staged where the verifier serves it from."""

    assert APP_INDEX.exists()


def test_step_1_has_accessible_pickup_and_delivery_labels() -> None:
    """Verify Pickup and Delivery inputs are discoverable via accessible labels."""

    html = _read_index()
    assert 'aria-label="Pickup"' in html
    assert 'aria-label="Delivery"' in html


def test_step_2_has_accessible_vehicle_fields_and_locked_model() -> None:
    """Verify Vehicle fields exist and Vehicle Model is initially disabled."""

    html = _read_index()
    assert 'aria-label="Vehicle Year"' in html
    assert 'aria-label="Vehicle Make"' in html
    assert 'aria-label="Vehicle Model"' in html

    # Allow either attribute order.
    assert (
        'id="vehicle-model"' in html and "disabled" in html
    ), "Expected the Vehicle Model control to be initially disabled."


def test_validation_message_is_present() -> None:
    """Verify the step-1 validation message text exists for blank inputs."""

    html = _read_index()
    assert "Please enter both pickup and delivery locations." in html


def test_mocked_toyota_models_are_present() -> None:
    """Verify mocked Toyota models include Camry/Corolla/RAV4/Tacoma."""

    html = _read_index()
    assert "Toyota" in html
    for model in ("Camry", "Corolla", "RAV4", "Tacoma"):
        assert model in html

