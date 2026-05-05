#!/usr/bin/env python3
"""Google Workspace OAuth2 setup for Rebar (per-client).

Adapted from the Hermes Agent `productivity/google-workspace` skill, but
parameterized for Rebar's per-client wiring instead of `$HERMES_HOME`. The
shell wrapper (`scripts/google-workspace/setup-oauth.sh`) resolves
`clients/<client>/client.yaml` and passes paths/scopes in via CLI flags.

Commands:
  setup.py --check      [common-args]                  # exit 0 if auth valid, 1 otherwise
  setup.py --auth-url   [common-args] [--format json]  # print OAuth URL (or JSON)
  setup.py --auth-code CODE [common-args] [--format json]  # exchange code for token
  setup.py --revoke     [common-args]                  # revoke and delete token

Common args (provided by the wrapper):
  --client-secret PATH   absolute path to Desktop OAuth client_secret JSON
  --token-path PATH      where to write/read the per-client token
  --pending-path PATH    where to persist PKCE state between auth-url and auth-code
  --scopes LIST          comma-separated list of OAuth scopes

Dependencies: stdlib + google-auth-oauthlib (which pulls in google-auth).
"""

from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path


def _eprint(msg: str) -> None:
    print(msg, file=sys.stderr)


def _emit(payload: dict, fmt: str) -> None:
    if fmt == "json":
        print(json.dumps(payload))
    else:
        for k, v in payload.items():
            print(f"{k}: {v}")


def _normalize_authorized_user_payload(payload: dict) -> dict:
    normalized = dict(payload)
    if not normalized.get("type"):
        normalized["type"] = "authorized_user"
    return normalized


def _load_token_payload(path: Path) -> dict:
    try:
        return json.loads(path.read_text())
    except Exception:
        return {}


def _missing_scopes_from_payload(payload: dict, scopes: list[str]) -> list[str]:
    raw = payload.get("scopes") or payload.get("scope")
    if not raw:
        return []
    granted = {s.strip() for s in (raw.split() if isinstance(raw, str) else raw) if s.strip()}
    return sorted(scope for scope in scopes if scope not in granted)


def check_auth(token_path: Path, scopes: list[str]) -> bool:
    if not token_path.exists():
        print(f"NOT_AUTHENTICATED: No token at {token_path}")
        return False

    try:
        from google.oauth2.credentials import Credentials
        from google.auth.transport.requests import Request
    except ImportError as e:
        _eprint(f"ERROR: google-auth not installed: {e}")
        _eprint("Install with: pip install google-auth-oauthlib")
        return False

    try:
        creds = Credentials.from_authorized_user_file(str(token_path))
    except Exception as e:
        print(f"TOKEN_CORRUPT: {e}")
        return False

    payload = _load_token_payload(token_path)

    if creds.valid:
        missing = _missing_scopes_from_payload(payload, scopes)
        if missing:
            print(f"AUTHENTICATED (partial): Token valid but missing {len(missing)} scopes:")
            for s in missing:
                print(f"  - {s}")
        print(f"AUTHENTICATED: Token valid at {token_path}")
        return True

    if creds.expired and creds.refresh_token:
        try:
            creds.refresh(Request())
            token_path.write_text(
                json.dumps(
                    _normalize_authorized_user_payload(json.loads(creds.to_json())),
                    indent=2,
                )
            )
            missing = _missing_scopes_from_payload(_load_token_payload(token_path), scopes)
            if missing:
                print(f"AUTHENTICATED (partial): Token refreshed but missing {len(missing)} scopes:")
                for s in missing:
                    print(f"  - {s}")
            print(f"AUTHENTICATED: Token refreshed at {token_path}")
            return True
        except Exception as e:
            print(f"REFRESH_FAILED: {e}")
            return False

    print("TOKEN_INVALID: Re-run setup.")
    return False


REDIRECT_URI = "http://localhost:1"


def _save_pending_auth(pending_path: Path, *, state: str, code_verifier: str) -> None:
    pending_path.parent.mkdir(parents=True, exist_ok=True)
    pending_path.write_text(
        json.dumps(
            {
                "state": state,
                "code_verifier": code_verifier,
                "redirect_uri": REDIRECT_URI,
            },
            indent=2,
        )
    )


def _load_pending_auth(pending_path: Path) -> dict:
    if not pending_path.exists():
        _eprint(f"ERROR: No pending OAuth session at {pending_path}. Run --auth-url first.")
        sys.exit(1)
    try:
        data = json.loads(pending_path.read_text())
    except Exception as e:
        _eprint(f"ERROR: Could not read pending OAuth session: {e}")
        sys.exit(1)
    if not data.get("state") or not data.get("code_verifier"):
        _eprint("ERROR: Pending OAuth session is missing PKCE data. Run --auth-url again.")
        sys.exit(1)
    return data


def _extract_code_and_state(code_or_url: str) -> tuple[str, str | None]:
    if not code_or_url.startswith("http"):
        return code_or_url, None
    from urllib.parse import parse_qs, urlparse

    parsed = urlparse(code_or_url)
    params = parse_qs(parsed.query)
    if "code" not in params:
        _eprint("ERROR: No 'code' parameter found in URL.")
        sys.exit(1)
    state = params.get("state", [None])[0]
    return params["code"][0], state


def get_auth_url(
    *,
    client_secret_path: Path,
    pending_path: Path,
    scopes: list[str],
    fmt: str,
) -> None:
    if not client_secret_path.exists():
        _eprint(f"ERROR: client_secret JSON not found at {client_secret_path}")
        sys.exit(1)

    try:
        from google_auth_oauthlib.flow import Flow
    except ImportError as e:
        _eprint(f"ERROR: google-auth-oauthlib not installed: {e}")
        sys.exit(1)

    flow = Flow.from_client_secrets_file(
        str(client_secret_path),
        scopes=scopes,
        redirect_uri=REDIRECT_URI,
        autogenerate_code_verifier=True,
    )
    auth_url, state = flow.authorization_url(
        access_type="offline",
        prompt="consent",
    )
    _save_pending_auth(pending_path, state=state, code_verifier=flow.code_verifier)
    _emit({"auth_url": auth_url, "pending_path": str(pending_path)}, fmt)


def exchange_auth_code(
    code_or_url: str,
    *,
    client_secret_path: Path,
    token_path: Path,
    pending_path: Path,
    scopes: list[str],
    fmt: str,
) -> None:
    if not client_secret_path.exists():
        _eprint(f"ERROR: client_secret JSON not found at {client_secret_path}")
        sys.exit(1)

    pending = _load_pending_auth(pending_path)
    raw_callback = code_or_url
    code, returned_state = _extract_code_and_state(code_or_url)
    if returned_state and returned_state != pending["state"]:
        _eprint("ERROR: OAuth state mismatch. Run --auth-url again to start a fresh session.")
        sys.exit(1)

    try:
        from google_auth_oauthlib.flow import Flow
    except ImportError as e:
        _eprint(f"ERROR: google-auth-oauthlib not installed: {e}")
        sys.exit(1)

    from urllib.parse import parse_qs, urlparse

    granted_scopes = list(scopes)
    if isinstance(raw_callback, str) and raw_callback.startswith("http"):
        params = parse_qs(urlparse(raw_callback).query)
        scope_val = (params.get("scope") or [""])[0].strip()
        if scope_val:
            granted_scopes = scope_val.split()

    flow = Flow.from_client_secrets_file(
        str(client_secret_path),
        scopes=granted_scopes,
        redirect_uri=pending.get("redirect_uri", REDIRECT_URI),
        state=pending["state"],
        code_verifier=pending["code_verifier"],
    )

    try:
        os.environ["OAUTHLIB_RELAX_TOKEN_SCOPE"] = "1"
        flow.fetch_token(code=code)
    except Exception as e:
        _eprint(f"ERROR: Token exchange failed: {e}")
        _eprint("The code may have expired. Run --auth-url to get a fresh URL.")
        sys.exit(1)

    creds = flow.credentials
    payload = _normalize_authorized_user_payload(json.loads(creds.to_json()))

    actually_granted: list[str] = []
    if hasattr(creds, "granted_scopes") and creds.granted_scopes:
        actually_granted = list(creds.granted_scopes)
    if actually_granted:
        payload["scopes"] = actually_granted
    elif granted_scopes != scopes:
        payload["scopes"] = granted_scopes

    missing = _missing_scopes_from_payload(payload, scopes)

    token_path.parent.mkdir(parents=True, exist_ok=True)
    token_path.write_text(json.dumps(payload, indent=2))
    try:
        pending_path.unlink()
    except FileNotFoundError:
        pass

    _emit(
        {
            "status": "ok",
            "token_path": str(token_path),
            "missing_scopes": missing,
        },
        fmt,
    )


def revoke(token_path: Path, pending_path: Path, scopes: list[str]) -> None:
    if not token_path.exists():
        print("No token to revoke.")
        return

    try:
        from google.oauth2.credentials import Credentials
        from google.auth.transport.requests import Request
    except ImportError as e:
        _eprint(f"ERROR: google-auth not installed: {e}")
        sys.exit(1)

    try:
        creds = Credentials.from_authorized_user_file(str(token_path), scopes)
        if creds.expired and creds.refresh_token:
            creds.refresh(Request())

        import urllib.request

        urllib.request.urlopen(
            urllib.request.Request(
                f"https://oauth2.googleapis.com/revoke?token={creds.token}",
                method="POST",
                headers={"Content-Type": "application/x-www-form-urlencoded"},
            )
        )
        print("Token revoked with Google.")
    except Exception as e:
        print(f"Remote revocation failed (token may already be invalid): {e}")

    try:
        token_path.unlink()
    except FileNotFoundError:
        pass
    try:
        pending_path.unlink()
    except FileNotFoundError:
        pass
    print(f"Deleted {token_path}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Google Workspace OAuth setup for Rebar (per-client)")
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--check", action="store_true", help="Exit 0 if authenticated, 1 otherwise")
    mode.add_argument("--auth-url", action="store_true", help="Print OAuth URL")
    mode.add_argument("--auth-code", metavar="CODE_OR_URL", help="Exchange auth code/URL for token")
    mode.add_argument("--revoke", action="store_true", help="Revoke and delete stored token")

    parser.add_argument("--client-secret", required=True, metavar="PATH",
                        help="Path to Desktop OAuth client_secret JSON")
    parser.add_argument("--token-path", required=True, metavar="PATH",
                        help="Path where the per-client token is stored")
    parser.add_argument("--pending-path", required=True, metavar="PATH",
                        help="Path where PKCE pending state is stored between auth-url and auth-code")
    parser.add_argument("--scopes", required=True, metavar="LIST",
                        help="Comma-separated list of OAuth scopes")
    parser.add_argument("--format", choices=("text", "json"), default="text",
                        help="Output format for --auth-url and --auth-code")

    args = parser.parse_args()

    client_secret_path = Path(args.client_secret).expanduser()
    token_path = Path(args.token_path).expanduser()
    pending_path = Path(args.pending_path).expanduser()
    scopes = [s.strip() for s in args.scopes.split(",") if s.strip()]
    if not scopes:
        _eprint("ERROR: --scopes must contain at least one scope.")
        sys.exit(2)

    if args.check:
        sys.exit(0 if check_auth(token_path, scopes) else 1)
    elif args.auth_url:
        get_auth_url(
            client_secret_path=client_secret_path,
            pending_path=pending_path,
            scopes=scopes,
            fmt=args.format,
        )
    elif args.auth_code:
        exchange_auth_code(
            args.auth_code,
            client_secret_path=client_secret_path,
            token_path=token_path,
            pending_path=pending_path,
            scopes=scopes,
            fmt=args.format,
        )
    elif args.revoke:
        revoke(token_path, pending_path, scopes)


if __name__ == "__main__":
    main()
